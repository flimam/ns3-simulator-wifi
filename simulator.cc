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


 int main (int argc, char *argv[])
 {
   CommandLine cmd;
   cmd.AddValue ("verbose", "Print trace information if true", g_verbose);

   cmd.Parse (argc, argv);

   Packet::EnablePrinting ();

   // enable rts cts all the time.
  //  Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", StringValue ("0"));
   // disable fragmentation
  //  Config::SetDefault ("ns3::WifiRemoteStationManager::FragmentationThreshold", StringValue ("2200"));





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


   // 6. Install TCP/IP stack & assign IP addresses
   InternetStackHelper internet;
   internet.Install (ap);
   internet.Install (stas);
   Ipv4AddressHelper ipv4;
   ipv4.SetBase ("10.0.0.0", "255.0.0.0");
   Ipv4InterfaceContainer apDevsInt = ipv4.Assign (apDevs);
   Ipv4InterfaceContainer staDevsInt = ipv4.Assign (staDevs);

   // 7. Install applications: two CBR streams each saturating the channel
   ApplicationContainer cbrApps;
   uint16_t cbrPort = 12345;
   OnOffHelper onOffHelper ("ns3::TcpSocketFactory", InetSocketAddress (staDevsInt.GetAddress (6), cbrPort));
   onOffHelper.SetAttribute ("PacketSize", UintegerValue (1400));
   onOffHelper.SetAttribute ("OnTime",  StringValue ("ns3::ConstantRandomVariable[Constant=1]"));
   onOffHelper.SetAttribute ("OffTime", StringValue ("ns3::ConstantRandomVariable[Constant=0]"));

   // flow 1:  node 0 -> node 1
   onOffHelper.SetAttribute ("DataRate", StringValue ("3000000bps"));
   onOffHelper.SetAttribute ("StartTime", TimeValue (Seconds (1.000000)));
   cbrApps.Add (onOffHelper.Install (stas.Get (0)));

   // flow 2:  node 2 -> node 1
   /** \internal
    * The slightly different start times and data rates are a workaround
    * for \bugid{388} and \bugid{912}
    */
   onOffHelper.SetAttribute ("DataRate", StringValue ("3001100bps"));
   onOffHelper.SetAttribute ("StartTime", TimeValue (Seconds (1.001)));
   cbrApps.Add (onOffHelper.Install (stas.Get (2)));




   Simulator::Run ();

   Simulator::Destroy ();

   return 0;
 }
