/* -*-  Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2005,2006,2007 INRIA
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *
 */


 #include "ns3/core-module.h"
 #include "ns3/network-module.h"
 #include "ns3/applications-module.h"
 #include "ns3/mobility-module.h"
 #include "ns3/config-store-module.h"
 #include "ns3/wifi-module.h"
 #include "ns3/internet-module.h"
 #include "ns3/athstats-helper.h"
 #include "ns3/random-variable-stream.h"








//
// #include "ns3/olsr-routing-protocol.h"
// #include "ns3/olsr-helper.h"
//
// #include "ns3/packet-sink.h"
// #include "ns3/packet-socket-helper.h"
// #include "ns3/mesh-helper.h"
// #include "ns3/config-store-module.h"
// #include "ns3/netanim-module.h"





 #include <iostream>

 using namespace ns3;

 static bool g_verbose = true;

 void
   DevTxTrace (std::string context, Ptr<const Packet> p)
 {
   if (g_verbose)
     {

       std::cout << " TX p: " << *p << std::endl;
     }
 }
 void
 DevRxTrace (std::string context, Ptr<const Packet> p)
 {
   if (g_verbose)
     {
       std::cout << " RX p: " << *p << std::endl;
     }
 }
 void
 PhyRxOkTrace (std::string context, Ptr<const Packet> packet, double snr, WifiMode mode, enum WifiPreamble preamble)
 {
   if (g_verbose)
     {
       std::cout << "PHYRXOK mode=" << mode << " snr=" << snr << " " << *packet << std::endl;
     }
 }
 void
 PhyRxErrorTrace (std::string context, Ptr<const Packet> packet, double snr)
 {
   if (g_verbose)
     {
       std::cout << "PHYRXERROR snr=" << snr << " " << *packet << std::endl;
     }
 }
 void
 PhyTxTrace (std::string context, Ptr<const Packet> packet, WifiMode mode, WifiPreamble preamble, uint8_t txPower)
 {
   if (g_verbose)
     {
       std::cout << "PHYTX mode=" << mode << " " << *packet << std::endl;
     }
 }
 void
 PhyStateTrace (std::string context, Time start, Time duration, enum WifiPhy::State state)
 {
   if (g_verbose)
     {
       std::cout << " state=" << state << " start=" << start << " duration=" << duration << std::endl;
     }
 }

 static void
 SetPosition (Ptr<Node> node, Vector position)
 {
   Ptr<MobilityModel> mobility = node->GetObject<MobilityModel> ();
   mobility->SetPosition (position);
 }

 static Vector
 GetPosition (Ptr<Node> node)
 {
   Ptr<MobilityModel> mobility = node->GetObject<MobilityModel> ();
   return mobility->GetPosition ();
 }

 static void
 AdvancePosition (Ptr<Node> node)
 {
   Vector pos = GetPosition (node);
   pos.x += 5.0;
   if (pos.x >= 210.0)
     {
       return;
     }
   SetPosition (node, pos);

   if (g_verbose)
     {
       //std::cout << "x="<<pos.x << std::endl;
     }
   Simulator::Schedule (Seconds (1.0), &AdvancePosition, node);
 }



 int main (int argc, char *argv[])
 {
   CommandLine cmd;
   cmd.AddValue ("verbose", "Print trace information if true", g_verbose);

   cmd.Parse (argc, argv);

   Packet::EnablePrinting ();

   // enable rts cts all the time.
   Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", StringValue ("0"));
   // disable fragmentation
   Config::SetDefault ("ns3::WifiRemoteStationManager::FragmentationThreshold", StringValue ("2200"));





   WifiHelper wifi;
   MobilityHelper mobility;
   NodeContainer stas;
   NodeContainer ap;
   NetDeviceContainer staDevs, apDevs;
   PacketSocketHelper packetSocket;

   YansWifiPhyHelper wifiPhy;
   YansWifiChannelHelper wifiChannel;


   stas.Create (20); //TODO
   ap.Create (1);

   // give packet socket powers to nodes.
   packetSocket.Install (stas);
   packetSocket.Install (ap);

   WifiMacHelper wifiMac;
   wifiPhy = YansWifiPhyHelper::Default ();
   wifiChannel = YansWifiChannelHelper::Default ();
   wifiPhy.SetChannel (wifiChannel.Create ());


   Ssid ssid = Ssid ("wifi-default");


   wifi.SetRemoteStationManager ("ns3::ArfWifiManager");
   // setup stas.
   wifiMac.SetType ("ns3::StaWifiMac","Ssid", SsidValue (ssid));
   staDevs = wifi.Install (wifiPhy, wifiMac, stas);
   // setup ap.
   wifiMac.SetType ("ns3::ApWifiMac","Ssid", SsidValue (ssid));
   apDevs = wifi.Install (wifiPhy, wifiMac, ap);



   mobility.SetPositionAllocator ("ns3::GridPositionAllocator",
                                  "MinX", DoubleValue (0.0),
                                  "MinY", DoubleValue (0.0),
                                  "DeltaX", DoubleValue (20.0),
                                  "DeltaY", DoubleValue (20.0),
                                  "GridWidth", UintegerValue (5),
                                  "LayoutType", StringValue ("RowFirst"));
   mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
   mobility.Install (ap);
   mobility.Install (stas);


   InternetStackHelper stack;
   stack.Install (ap);
   stack.Install (stas);


    // Ipv4AddressHelper address;
    // Ipv4InterfaceContainer wifiInterfaces;
    // address.SetBase ("10.1.2.0", "255.255.255.0");
    // wifiInterfaces = address.Assign(apDevs);
    // wifiInterfaces = address.Assign(staDevs);

     InetSocketAddress socket = InetSocketAddress (Ipv4Address::GetAny(), 80);



    uint32_t packets = 1500;

    Config::SetDefault ("ns3::TcpSocket::SegmentSize", UintegerValue (1460));
    Config::SetDefault ("ns3::TcpSocket::RcvBufSize", UintegerValue (900000));
    Config::SetDefault ("ns3::TcpSocket::SndBufSize", UintegerValue (900000));

    Address sinkLocalAddress (InetSocketAddress(Ipv4Address::GetAny(), 9));
    PacketSinkHelper sinkHelper ("ns3::TcpSocketFactory",sinkLocalAddress);

    ApplicationContainer sinkApp = sinkHelper.Install(stas.Get(2)); //TODO value

    sinkApp.Start (Seconds (0.001));
    sinkApp.Stop (Seconds (10.0));

    // Create the OnOff applications to send TCP to the server
    OnOffHelper sourceHelper ("ns3::TcpSocketFactory", Address());
    sourceHelper.SetAttribute ("OnTime", StringValue ("ns3::ConstantRandomVariable[Constant=1.0]"));
    sourceHelper.SetAttribute ("OffTime", StringValue ("ns3::ConstantRandomVariable[Constant=5.0]"));

    AddressValue remoteAddress (InetSocketAddress(wifiInterfaces.GetAddress (5), 9)); //TODO value
    sourceHelper.SetAttribute ("Remote", remoteAddress);
    sourceHelper.SetAttribute ("DataRate", DataRateValue(DataRate("11Mbps")));
    sourceHelper.SetAttribute ("PacketSize", UintegerValue (packets));





























//
//    Ipv4AddressHelper address;
//    address.SetBase ("192.168.1.0", "255.255.255.0");
//    address.Assign (apDevs);
//    address.Assign (staDevs);
//
//
//    PacketSocketAddress socket;
//    socket.SetSingleDevice (staDevs.Get (0)->GetIfIndex ());
//    socket.SetPhysicalAddress (staDevs.Get (1)->GetAddress ());
//    socket.SetProtocol (1);
//
//    OnOffHelper onoff ("ns3::PacketSocketFactory", Address (socket));
//    onoff.SetConstantRate (DataRate ("500kb/s"));
//
//    ApplicationContainer apps = onoff.Install (stas.Get (0));
//    apps.Start (Seconds (1.0));
//    apps.Stop (Seconds (10.0));
//
//    Simulator::Stop (Seconds (10.0));
//
//    Config::Connect ("/NodeList/*/DeviceList/*/Mac/MacTx", MakeCallback (&DevTxTrace));
//    Config::Connect ("/NodeList/*/DeviceList/*/Mac/MacRx", MakeCallback (&DevRxTrace));
//    //Config::Connect ("/NodeList/*/DeviceList/*/Phy/State/RxOk", MakeCallback (&PhyRxOkTrace));
//    //Config::Connect ("/NodeList/*/DeviceList/*/Phy/State/RxError", MakeCallback (&PhyRxErrorTrace));
//    //Config::Connect ("/NodeList/*/DeviceList/*/Phy/State/Tx", MakeCallback (&PhyTxTrace));
//    //Config::Connect ("/NodeList/*/DeviceList/*/Phy/State/State", MakeCallback (&PhyStateTrace));
//
//    //AthstatsHelper athstats;
// //    athstats.EnableAthstats ("athstats-sta", stas);
// //    athstats.EnableAthstats ("athstats-ap", ap);

  //  Ipv4GlobalRoutingHelper::PopulateRoutingTables ();

   Simulator::Run ();

   Simulator::Destroy ();

   return 0;
 }
