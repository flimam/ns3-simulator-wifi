# coding: utf-8

'''
from:	examples/tutorial/fifth.cc
to:	fifth.py
time:	20101110.1948.

//         发送端                 接收端
//         node 0                 node 1
//   +----------------+    +----------------+
//   |    ns-3 TCP    |    |    ns-3 TCP    |
//   +----------------+    +----------------+
//   |    10.1.1.1    |    |    10.1.1.2    |
//   +----------------+    +----------------+
//   | point-to-point |    | point-to-point |
//   +----------------+    +----------------+
//           |                     |
//           +---------------------+
//                5 Mbps, 2 ms
//
//
// We want to look at changes in the ns-3 TCP congestion window.  We need
// to crank up a flow and hook the CongestionWindow attribute on the socket
// of the sender.  Normally one would use an on-off application to generate a
// flow, but this has a couple of problems.  First, the socket of the on-off
// application is not created until Application Start time, so we wouldn't be
// able to hook the socket (now) at configuration time.  Second, even if we
// could arrange a call after start time, the socket is not public so we
// couldn't get at it.
//
// So, we can cook up a simple version of the on-off application that does what
// we want.  On the plus side we don't need all of the complexity of the on-off
// application.  On the minus side, we don't have a helper, so we have to get
// a little more involved in the details, but this is trivial.
//
// So first, we create a socket and do the trace connect on it; then we pass
// this socket into the constructor of our simple application which we then
// install in the source node.
'''

import sys, ns3

class MyApp(ns3.Application):
	tid = ns3.TypeId("MyApp")
	tid.SetParent(ns3.Application.GetTypeId())
	m_socket = m_packetSize = m_nPackets = m_dataRate = m_packetsSent = 0
	m_peer = m_sendEvent = None
	m_running = False
	count_Setup = count_Start = count_Stop = count_SendPacket = count_ScheduleTx = count_GetSendPacket = count_GetTypeId = 0

	def __init__(self):
		super(MyApp, self).__init__()

	def Setup(self, socket, address, packetSize, nPackets, dataRate):
		self.count_Setup = self.count_Setup + 1
		self.m_socket = socket
		self.m_peer = address
		self.m_packetSize = packetSize
		self.m_nPackets = nPackets
		self.m_dataRate = dataRate

	def StartApplication(self):
		self.count_Start = self.count_Start + 1
		if self.m_nPackets > 0 and self.m_nPackets > self.m_packetsSent:
			self.m_running = True
			self.m_packetsSent = 0
			self.m_socket.Bind()
			self.m_socket.Connect(self.m_peer)
			self.SendPacket()
		else:
			self.StopApplication()

	def StopApplication(self):
		self.count_Stop = self.count_Stop + 1
		self.m_running = False
		if self.m_sendEvent != None and self.m_sendEvent.IsRunning() == True:
			ns3.Simulator.Cancel(self.m_sendEvent)
		if self.m_socket:
			self.m_socket.Close()

	def SendPacket(self):
		self.count_SendPacket = self.count_SendPacket + 1
		packet = ns3.Packet(self.m_packetSize)
		print 'SendPacket(): ' + str( ns3.Simulator.Now().GetSeconds()) + 's,\t send ' + str(self.m_packetsSent) + '#'
		self.m_socket.Send(packet)
		self.m_packetsSent = self.m_packetsSent + 1
		if self.m_packetsSent < self.m_nPackets:
			self.ScheduleTx()
		else:
			self.StopApplication()

	def ScheduleTx(self):
		self.count_ScheduleTx = self.count_ScheduleTx + 1
		if self.m_running:
			tNext = ns3.Seconds(self.m_packetSize * 8.0 / self.m_dataRate.GetBitRate())
			self.m_sendEvent = ns3.Simulator.Schedule(tNext, MyApp.SendPacket, self)

	def GetSendPacket(self):
		self.count_GetSendPacket = self.count_GetSendPacket + 1
		return self.m_packetsSent

	def GetTypeId(self):
		self.count_GetTypeId = self.count_GetTypeId + 1
		return self.tid

def CwndChange(app):
	# CwndChange():
	n = app.GetSendPacket()
	print 'CwndChange(): ' + str(ns3.Simulator.Now().GetSeconds()) + 's, \t sum(send packets) = ' + str(n)
	ns3.Simulator.Schedule(ns3.Seconds(0.3), CwndChange, app)

def print_stats(os, st):
	print >> os, "  Tx Bytes: ", st.txBytes
	print >> os, "  Rx Bytes: ", st.rxBytes
	print >> os, "  Tx Packets: ", st.txPackets
	print >> os, "  Rx Packets: ", st.rxPackets
	print >> os, "  Lost Packets: ", st.lostPackets
	if st.rxPackets > 0:
		print >> os, "  Mean{Delay}: ", (st.delaySum.GetSeconds() / st.rxPackets)
		print >> os, "  Mean{Jitter}: ", (st.jitterSum.GetSeconds() / (st.rxPackets-1))
		print >> os, "  Mean{Hop Count}: ", float(st.timesForwarded) / st.rxPackets + 1

	if st.rxPackets == 0:
		print >> os, "Delay Histogram"
		for i in range(st.delayHistogram.GetNBins()):
			print >> os, " ", i, "(", st.delayHistogram.GetBinStart(i), "-", st.delayHistogram.GetBinEnd(i), "): ", st.delayHistogram.GetBinCount(i)
		print >> os, "Jitter Histogram"
		for i in range(st.jitterHistogram.GetNBins()):
			print >> os, " ", i, "(", st.jitterHistogram.GetBinStart(i), "-", st.jitterHistogram.GetBinEnd(i), "): ", st.jitterHistogram.GetBinCount(i)
		print >> os, "PacketSize Histogram"
		for i in range(st.packetSizeHistogram.GetNBins()):
			print >> os, " ", i, "(", st.packetSizeHistogram.GetBinStart(i), "-", st.packetSizeHistogram.GetBinEnd(i), "): ", st.packetSizeHistogram.GetBinCount(i)

	for reason, drops in enumerate(st.packetsDropped):
		print "  Packets dropped by reason %i: %i" % (reason, drops)
	# for reason, drops in enumerate(st.bytesDropped):
		# print "Bytes dropped by reason %i: %i" % (reason, drops)


def main(argv):
	packetSize = 1040
	nPackets = 2
	dataRate = "1Mbps"

	ns3.LogComponentEnableAll(ns3.LOG_INFO)

	nodes = ns3.NodeContainer()
	nodes.Create(2)
	p2p = ns3.PointToPointHelper()
	p2p.SetDeviceAttribute("DataRate", ns3.StringValue("5Mbps"))
	p2p.SetChannelAttribute("Delay", ns3.StringValue("2ms"))
	devices = p2p.Install(nodes)
	stack = ns3.InternetStackHelper()
	stack.Install(nodes)
	address = ns3.Ipv4AddressHelper()
	address.SetBase(ns3.Ipv4Address("10.1.1.0"), ns3.Ipv4Mask("255.255.255.0"))
	interfaces = address.Assign(devices)

	# 节点n1的数据接收模型
	em = ns3.RateErrorModel()
	# ErrorUnit: 单位（缺省：字节）
	# em.SetUnit(EU_BYTE)
	# ErrorRate: 错误率
	em.SetRate(1e-5)
	# RanVar: 随机变量模型：(0, 1)分布
	# em.SetRandomVariable(ns3.UniformVariable(0.0, 1.0))
	devices.Get(1).SetAttribute("ReceiveErrorModel", ns3.PointerValue(em))

	# Application
	sinkPort = 8080
	# 节点n1，Serve Application
	packetSinkHelper = ns3.PacketSinkHelper("ns3::TcpSocketFactory", ns3.InetSocketAddress(ns3.Ipv4Address.GetAny(), sinkPort))
	sinkApps = packetSinkHelper.Install(nodes.Get(1))
	sinkApps.Start(ns3.Seconds(0.0))
	sinkApps.Stop(ns3.Seconds(10.0))
	# 节点n0，Client Application
	sinkAddress = ns3.Address(ns3.InetSocketAddress(interfaces.GetAddress(1), sinkPort))
  	ns3TcpSocket = ns3.Socket.CreateSocket(nodes.Get(0), ns3.TcpSocketFactory.GetTypeId());
	app = MyApp()
	# def Setup(self, socket, address, packetSize, nPackets, dataRate):
	app.Setup(ns3TcpSocket, sinkAddress, packetSize, nPackets, ns3.DataRate(dataRate))
	nodes.Get(0).AddApplication(app)
	app.SetStartTime(ns3.Seconds(1.0))
	app.SetStopTime(ns3.Seconds(10.0))

	ns3.Simulator.Schedule(ns3.Seconds(0.3), CwndChange, app)

	flowmon_helper = ns3.FlowMonitorHelper()
	monitor = flowmon_helper.InstallAll()
	monitor.SetAttribute("DelayBinWidth", ns3.DoubleValue(1e-3))
	monitor.SetAttribute("JitterBinWidth", ns3.DoubleValue(1e-3))
	monitor.SetAttribute("PacketSizeBinWidth", ns3.DoubleValue(20))

	p2p.EnablePcapAll("fifth")
	ascii = ns3.AsciiTraceHelper().CreateFileStream("fifth.tr")
	p2p.EnableAsciiAll(ascii)

	ns3.Simulator.Stop(ns3.Seconds(10.0))
	ns3.Simulator.Run()
	ns3.Simulator.Destroy()

	monitor.CheckForLostPackets()
	classifier = flowmon_helper.GetClassifier()
	for flow_id, flow_stats in monitor.GetFlowStats():
		t = classifier.FindFlow(flow_id)
		proto = {6: 'TCP', 17: 'UDP'} [t.protocol]
		print "FlowID: %i (%s %s/%s --> %s/%i)" % (flow_id, proto, t.sourceAddress, t.sourcePort, t.destinationAddress, t.destinationPort)
		print_stats(sys.stdout, flow_stats)

if __name__ == '__main__':
	main(sys.argv)
