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
import random

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



cmd = ns.core.CommandLine()
cmd.verbose = "True"
cmd.nWifi = 25 #quantidade de nos
cmd.Parse(sys.argv) #Obrigatorio para utilizar o ns.visualizer

#Talvez sem necessidades
verbose = cmd.verbose
nWifi = int(cmd.nWifi)

# Melhorar isso
if verbose == "True":
	ns.core.LogComponentEnable("UdpEchoClientApplication", ns.core.LOG_LEVEL_INFO)
	ns.core.LogComponentEnable("UdpEchoServerApplication", ns.core.LOG_LEVEL_INFO)
	ns.core.LogComponentEnable("OnOffApplication", ns.core.LOG_LEVEL_ALL)


wifiStaNodes = ns.network.NodeContainer()
wifiStaNodes.Create(nWifi)  #Cria os nós
wifiApNode = ns.network.NodeContainer()
wifiApNode.Create(1)  #Cria o AP

channel = ns.wifi.YansWifiChannelHelper.Default()
phy = ns.wifi.YansWifiPhyHelper.Default() # isso faz com que eles compartilhem o mesmo meio fisico
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
mobility.SetPositionAllocator (
					"ns3::GridPositionAllocator",
					"MinX", ns.core.DoubleValue(0.0),
					"MinY", ns.core.DoubleValue (0.0),
					"DeltaX", ns.core.DoubleValue(15.0),
					"DeltaY", ns.core.DoubleValue(15.0),
                    "GridWidth", ns.core.UintegerValue(5),
					"LayoutType", ns.core.StringValue("RowFirst")
					)


mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel")
mobility.Install(wifiApNode)
mobility.Install(wifiStaNodes)

stack = ns.internet.InternetStackHelper() #instala a pilha de protocolos
stack.Install(wifiApNode)
stack.Install(wifiStaNodes)

address = ns.internet.Ipv4AddressHelper()
address.SetBase(ns.network.Ipv4Address("198.162.1.0"), ns.network.Ipv4Mask("255.255.255.0"))
ApInterfaces = address.Assign(apDevices)
wifiInterfaces = address.Assign(staDevices)



for x in xrange(1):

	#aleatorio
	server = random.randrange(nWifi)

	#Comunicação
	echoServer = ns.applications.UdpEchoServerHelper(9) #porta de comunicação
	serverApps = echoServer.Install(wifiStaNodes.Get(server)) # O nó que vai ser o servidor e vai responder as requsições dos clientes
	initial_comunnication =  float(random.randrange(9)) #Minha edição
	serverApps.Start(ns.core.Seconds(initial_comunnication))
	serverApps.Stop(ns.core.Seconds(10.0))


	echoClient = ns.applications.UdpEchoClientHelper(wifiInterfaces.GetAddress(server), 9) #Pega o IP do nó que vai receber a mensagem a porta que ele vai receber
	echoClient.SetAttribute("MaxPackets", ns.core.UintegerValue(1))
	echoClient.SetAttribute("Interval", ns.core.TimeValue(ns.core.Seconds (0.4)))
	echoClient.SetAttribute("PacketSize", ns.core.UintegerValue(1024))

	clientApps = echoClient.Install(wifiStaNodes.Get(random.randrange(nWifi))) # o Nó que vai ser o cliente, ele vai enviar os dados
	clientApps.Start(ns.core.Seconds(initial_comunnication))
	clientApps.Stop(ns.core.Seconds(10.0))

# ns.internet.Ipv4GlobalRoutingHelper.PopulateRoutingTables() # faz a comunicação pra gerar as tabelas de roteamento

ns.core.Simulator.Stop(ns.core.Seconds(30.0)) #tempo sa simulação

# wifi.EnablePcap ("Teste", staDevices.Get(1), True);
phy.EnablePcap ("Teste", apDevices.Get(0))

ns.core.Simulator.Run()
ns.core.Simulator.Destroy()
