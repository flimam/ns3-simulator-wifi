# -*- coding: utf-8 -*-
# -*-  Mode: Python; -*-
# /*
#  * This program is free software; you can redistribute it and/or modify
#  * it under the terms of the GNU General Public License version 2 as
#  * published by the Free Software Foundation;
#  *
#  * This program is distributed in the hope that it will be useful,
#  * but WITHOUT ANY WARRANTY; without even the implied warranty of
#  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  * GNU General Public License for more details.
#  *
#  * You should have received a copy of the GNU General Public License
#  * along with this program; if not, write to the Free Software
#  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#  *
#  * Ported to Python by Mohit P. Tahiliani
#  */

import ns.core
import ns.network
import ns.point_to_point
import ns.applications
import ns.wifi
import ns.visualizer
import ns.mobility
import ns.csma
import ns.internet
import sys

# // Default Network Topology
# //
# //   Wifi 10.1.3.0
# //                 AP
# //  *    *    *    *
# //  |    |    |    |    10.1.1.0
# // n5   n6   n7   n0 -------------- n1   n2   n3   n4
# //                   point-to-point  |    |    |    |
# //                                   ================
# //                                     LAN 10.1.2.0

cmd = ns.core.CommandLine()
cmd.nCsma = 3
cmd.verbose = "True"
cmd.nWifi = 25 #quantidade de nos
cmd.AddValue("nCsma", "Number of \"extra\" CSMA nodes/devices")
cmd.AddValue("nWifi", "Number of wifi STA devices")
cmd.AddValue("verbose", "Tell echo applications to log if true")

cmd.Parse(sys.argv) #

nCsma = int(cmd.nCsma)
verbose = cmd.verbose
nWifi = int(cmd.nWifi)

# if nWifi > 18:
# 	print "Number of wifi nodes "+ str(nWifi)+ " specified exceeds the mobility bounding box"
# 	sys.exit(1)

if verbose == "True":
	ns.core.LogComponentEnable("UdpEchoClientApplication", ns.core.LOG_LEVEL_INFO)
	ns.core.LogComponentEnable("UdpEchoServerApplication", ns.core.LOG_LEVEL_INFO)

p2pNodes = ns.network.NodeContainer()
p2pNodes.Create(2) # Acho que crio os dos nós p2p -- Crio 2

pointToPoint = ns.point_to_point.PointToPointHelper()
pointToPoint.SetDeviceAttribute("DataRate", ns.core.StringValue("5Mbps"))
pointToPoint.SetChannelAttribute("Delay", ns.core.StringValue("2ms"))

p2pDevices = pointToPoint.Install(p2pNodes) # ligo os dois p2p

csmaNodes = ns.network.NodeContainer() #Cria o LAN
csmaNodes.Add(p2pNodes.Get(1)) # Adiciono o nó um do p2p  para a LAN
csmaNodes.Create(nCsma)

csma = ns.csma.CsmaHelper()
csma.SetChannelAttribute("DataRate", ns.core.StringValue("100Mbps"))
csma.SetChannelAttribute("Delay", ns.core.TimeValue(ns.core.NanoSeconds(6560)))

csmaDevices = csma.Install(csmaNodes) # crio os nós que são ligados

wifiStaNodes = ns.network.NodeContainer()
wifiStaNodes.Create(nWifi)  #Cria os nós
wifiApNode = p2pNodes.Get(0) # determina o nós AP

channel = ns.wifi.YansWifiChannelHelper.Default()
phy = ns.wifi.YansWifiPhyHelper.Default()
phy.SetChannel(channel.Create()) # determina um canal (eu acho)

wifi = ns.wifi.WifiHelper()
wifi.SetRemoteStationManager("ns3::AarfWifiManager")

mac = ns.wifi.WifiMacHelper()
ssid = ns.wifi.Ssid("ns-3-ssid")

mac.SetType("ns3::StaWifiMac", "Ssid", ns.wifi.SsidValue(ssid), "ActiveProbing", ns.core.BooleanValue(False))
staDevices = wifi.Install(phy, mac, wifiStaNodes)

mac.SetType("ns3::ApWifiMac","Ssid", ns.wifi.SsidValue (ssid))
apDevices = wifi.Install(phy, mac, wifiApNode)

mobility = ns.mobility.MobilityHelper()
mobility.SetPositionAllocator ("ns3::GridPositionAllocator", "MinX", ns.core.DoubleValue(0.0),
								"MinY", ns.core.DoubleValue (0.0), "DeltaX", ns.core.DoubleValue(15.0), "DeltaY", ns.core.DoubleValue(15.0),
                                 "GridWidth", ns.core.UintegerValue(5), "LayoutType", ns.core.StringValue("RowFirst"))

mobility.SetMobilityModel ("ns3::RandomWalk2dMobilityModel", "Bounds", ns.mobility.RectangleValue(ns.mobility.Rectangle (-500, 500, -500, 500)))
mobility.Install(wifiStaNodes)

mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel")
mobility.Install(wifiApNode)
# mobility.Install(wifiStaNodes)



stack = ns.internet.InternetStackHelper() #instala a pilha de protocolos
stack.Install(csmaNodes)
stack.Install(wifiApNode)
stack.Install(wifiStaNodes)

address = ns.internet.Ipv4AddressHelper()
address.SetBase(ns.network.Ipv4Address("10.1.1.0"), ns.network.Ipv4Mask("255.255.255.0"))
p2pInterfaces = address.Assign(p2pDevices)

address.SetBase(ns.network.Ipv4Address("10.1.2.0"), ns.network.Ipv4Mask("255.255.255.0"))
csmaInterfaces = address.Assign(csmaDevices)

address.SetBase(ns.network.Ipv4Address("10.1.3.0"), ns.network.Ipv4Mask("255.255.255.0"))
address.Assign(staDevices)
address.Assign(apDevices)




echoServer = ns.applications.UdpEchoServerHelper(9) #porta de comunicação
serverApps = echoServer.Install(csmaNodes.Get(nCsma)) # O nó que vai ser o servidor e vai responder as requsições dos clientes
# print nCsma , type(nCsma)
# serverApps = echoServer.Install(csmaNodes.Get(0)) #TODO testar pra ver se mudou o server
serverApps.Start(ns.core.Seconds(1.0))
serverApps.Stop(ns.core.Seconds(4.0))




echoClient = ns.applications.UdpEchoClientHelper(csmaInterfaces.GetAddress(nCsma), 9) #Pega o IP do nó que vai receber a mensagem a porta que ele vai receber
echoClient.SetAttribute("MaxPackets", ns.core.UintegerValue(100))
echoClient.SetAttribute("Interval", ns.core.TimeValue(ns.core.Seconds (0.4)))
echoClient.SetAttribute("PacketSize", ns.core.UintegerValue(1024))

clientApps = echoClient.Install(wifiStaNodes.Get(4)) # o Nó que vai ser o cliente, ele vai enviar os dados 
clientApps.Start(ns.core.Seconds(2.0))
clientApps.Stop(ns.core.Seconds(20.0))

ns.internet.Ipv4GlobalRoutingHelper.PopulateRoutingTables() # faz a comunicação pra gerar as tabelas de roteamento

ns.core.Simulator.Stop(ns.core.Seconds(30.0)) #tempo sa simulação

#I don't no
pointToPoint.EnablePcapAll ("third")
phy.EnablePcap ("third", apDevices.Get(0))
csma.EnablePcap ("third", csmaDevices.Get(0), True)

ns.core.Simulator.Run()
ns.core.Simulator.Destroy()
