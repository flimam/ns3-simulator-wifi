/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */

#include "ns3/core-module.h"
#include "ns3/propagation-module.h"
#include "ns3/network-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"
#include "ns3/internet-module.h"
#include "ns3/flow-monitor-module.h"
#include "ns3/wifi-module.h"
#include <iostream>
#include <sstream>
#include <math.h>

using namespace ns3;
using namespace std;

//running settings
uint32_t nNodes = 5; //GLOBAL
static bool printLog = true;
bool enableCtsRts = false;
bool traffic = true;
bool mobility = false;
uint32_t packetsize;
double runningTime = 60.0;
double offTime = 0.001;
double onTime = 0.001;

size_t nearestNode = -1;
size_t farthestNode = -1;
double dnearestNode;
double dfarthestNode;
char prefix[150] = "";


double calcDistance (uint32_t x1, uint32_t y1, uint32_t x2, uint32_t y2){
  return sqrt( (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
}

void findNode(uint32_t ApX, uint32_t ApY, uint32_t NodeX, uint32_t NodeY, size_t id){
  double result = calcDistance(ApX, ApY, NodeX, NodeY);
  if(id == 0){
    nearestNode = id;
    farthestNode = id;
    dnearestNode = result;
    dfarthestNode = result;
  }
  else{
    if(result > dfarthestNode){
      farthestNode = id;
      dfarthestNode = result;
    }
    if(result < dnearestNode){
      nearestNode = id;
      dnearestNode = result;
    }
  }
}

int myRand(int min, int max){

  Ptr<UniformRandomVariable> x = CreateObject<UniformRandomVariable> ();
  x->SetAttribute ("Min", DoubleValue (min));
  x->SetAttribute ("Max", DoubleValue (max));

  int value = x->GetValue ();

  return value;
}

double myprobability(){

  Ptr<UniformRandomVariable> x = CreateObject<UniformRandomVariable> ();

  return x->GetValue ();
}

void setMobility(NodeContainer &apnode, NodeContainer &nodes) {

  MobilityHelper mobilityh;
  //List of points
  Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator> ();
  //Set apnode static
  uint32_t ApX = 50;
  uint32_t ApY = 50;
  positionAlloc->Add (Vector (ApX, ApY, 0.0));
  mobilityh.SetPositionAllocator (positionAlloc);
  mobilityh.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
  mobilityh.Install (apnode);
  //Set station node static
  if(mobility){
    //Set nodes with mobility
    // Rectangle area = Rectangle (-5000, 5000, -5000, 5000); //Area of mobility
    // mobilityh.SetMobilityModel ("ns3::RandomWalk2dMobilityModel","Bounds", RectangleValue (area));

    // MobilityHelper mobility;
    mobilityh.SetMobilityModel ("ns3::GaussMarkovMobilityModel",
      "Bounds", BoxValue (Box (0, 200, 0, 200, 0, 1)),
      "TimeStep", TimeValue (Seconds (0.5)),
      "Alpha", DoubleValue (0.85),
      "MeanVelocity", StringValue ("ns3::UniformRandomVariable[Min=2|Max=7]"),
      "MeanDirection", StringValue ("ns3::UniformRandomVariable[Min=0|Max=6.2]"),
      "MeanPitch", StringValue ("ns3::UniformRandomVariable[Min=0.05|Max=0.05]"),
      "NormalVelocity", StringValue ("ns3::NormalRandomVariable[Mean=0.0|Variance=0.0|Bound=0.0]"),
      "NormalDirection", StringValue ("ns3::NormalRandomVariable[Mean=0.0|Variance=0.2|Bound=0.4]"),
      "NormalPitch", StringValue ("ns3::NormalRandomVariable[Mean=0.0|Variance=0.02|Bound=0.04]"));
    mobilityh.SetPositionAllocator ("ns3::RandomBoxPositionAllocator",
      "X", StringValue ("ns3::UniformRandomVariable[Min=0|Max=150]"),
      "Y", StringValue ("ns3::UniformRandomVariable[Min=0|Max=150]"),
      "Z", StringValue ("ns3::UniformRandomVariable[Min=0|Max=1]"));


  }
  for (size_t i = 0; i < nNodes; i++) {
    uint32_t NodeX = myRand(0, 100);
    uint32_t NodeY = myRand(0, 100);
    findNode(ApX, ApY, NodeX, NodeY, i);
    positionAlloc = CreateObject<ListPositionAllocator> ();
    positionAlloc->Add (Vector (NodeX, NodeY, 0.0));
    mobilityh.SetPositionAllocator (positionAlloc);
    mobilityh.Install (nodes.Get(i));
  }
  //cout << "Mais Distante: " << farthestNode << "     com a distancia de " << dfarthestNode << "." << std::endl;
  //cout << "Mais Proximo : " << nearestNode << "    com a distancia de " << dnearestNode << "." << std::endl;
  //Set list of points

}

void installP2PDevices(NodeContainer &p2pnode, NetDeviceContainer &p2pdevice){

  PointToPointHelper pointToPoint;
  pointToPoint.SetDeviceAttribute ("DataRate", StringValue ("5Mbps"));
  // pointToPoint.SetChannelAttribute ("Delay", StringValue ("1ms"));
  p2pdevice = pointToPoint.Install (p2pnode);
}

void installWirelesp2pdevice(NodeContainer &apnode, NodeContainer &nodes, NetDeviceContainer &apdevice, NetDeviceContainer &devices){

  // 5. Install wireless devices
  WifiHelper wifi;
  wifi.SetStandard (WIFI_PHY_STANDARD_80211b);
  wifi.SetRemoteStationManager ("ns3::ArfWifiManager");

  YansWifiChannelHelper wifiChannel;
  wifiChannel = YansWifiChannelHelper::Default ();

  YansWifiPhyHelper wifiPhy =  YansWifiPhyHelper::Default ();
  wifiPhy.SetChannel (wifiChannel.Create ());

  Ssid ssid = Ssid ("wifi-default");

  WifiMacHelper wifiMac;
  wifiMac.SetType ("ns3::StaWifiMac","Ssid", SsidValue (ssid));
  devices = wifi.Install (wifiPhy, wifiMac, nodes);
  // setup ap.
  wifiMac.SetType ("ns3::ApWifiMac","Ssid", SsidValue (ssid));
  apdevice = wifi.Install (wifiPhy, wifiMac, apnode);
}

void installInternetProtocol(NodeContainer &apnode, NodeContainer &nodes, NodeContainer &p2pnode, NetDeviceContainer &apdevice, NetDeviceContainer &devices, NetDeviceContainer &p2pdevice, Ipv4InterfaceContainer &apdeviceIP, Ipv4InterfaceContainer &devicesIP, Ipv4InterfaceContainer &p2pdeviceIP){

  // 6. Install TCP/IP stack & assign IP addresses
  InternetStackHelper internet;
  internet.Install (nodes);
  internet.Install (apnode);
  internet.Install (p2pnode.Get(0));

  Ipv4AddressHelper ipv4;
  ipv4.SetBase ("198.162.10.0", "255.255.255.0");
  apdeviceIP = ipv4.Assign (apdevice);
  devicesIP = ipv4.Assign (devices);

  ipv4.SetBase ("10.1.1.0", "255.255.255.0");
  p2pdeviceIP = ipv4.Assign (p2pdevice);
}

void installUDPCommunication(NodeContainer &nodes, Ipv4InterfaceContainer &p2pdeviceIP){
  ApplicationContainer cbrApps;

  //onTime and OffTime settings
  std::ostringstream ossOnTime;
  ossOnTime << "ns3::ConstantRandomVariable[Constant=" << onTime << "]";
  std::ostringstream ossOffTime;
  ossOffTime << "ns3::ConstantRandomVariable[Constant=" << offTime << "]";

  for (uint32_t i = 0; i < nNodes; i++){
    OnOffHelper onOffHelper ("ns3::UdpSocketFactory", InetSocketAddress (p2pdeviceIP.GetAddress(0), i+1000));
    onOffHelper.SetAttribute ("PacketSize", UintegerValue (packetsize));
    onOffHelper.SetAttribute ("OnTime",StringValue(ossOnTime.str()));
    onOffHelper.SetAttribute ("OffTime",StringValue(ossOffTime.str()));

    onOffHelper.SetAttribute ("DataRate", StringValue ("512kbps"));
    cbrApps.Add (onOffHelper.Install (nodes.Get(i)));
  }

  // Start and stop time of application
  cbrApps.Start(Seconds(1.0));
  cbrApps.Stop(Seconds(runningTime+1));
}

void installTCPCommunication(NodeContainer &nodes, NodeContainer &p2pnode, Ipv4InterfaceContainer &p2pdeviceIP){
  ApplicationContainer serverApp;
  ApplicationContainer sinkApp;

  std::ostringstream ossOnTime;
  ossOnTime << "ns3::ConstantRandomVariable[Constant=" << onTime << "]";
  std::ostringstream ossOffTime;
  ossOffTime << "ns3::ConstantRandomVariable[Constant=" << offTime << "]";

  /* Install TCP/UDP Transmitter on the station */
  for (uint32_t i = 0; i < nNodes; i++){
  /* Install TCP Receiver on the access point */
    PacketSinkHelper sinkHelper ("ns3::TcpSocketFactory", InetSocketAddress (p2pdeviceIP.GetAddress(0), i+10000));
    sinkApp = sinkHelper.Install (nodes.Get(i));
    sinkApp.Add (sinkHelper.Install (p2pnode.Get(0)));
    sinkApp.Start (Seconds (0.0));
    OnOffHelper server ("ns3::TcpSocketFactory", (InetSocketAddress (p2pdeviceIP.GetAddress(0), i+10000)));
    server.SetAttribute ("PacketSize", UintegerValue (1484));
    server.SetAttribute ("OnTime", StringValue(ossOnTime.str()));
    server.SetAttribute ("OffTime", StringValue(ossOffTime.str()));
    server.SetAttribute ("DataRate", StringValue ("512kbps"));
    serverApp = server.Install (nodes.Get(i));
    serverApp.Start (Seconds (1));
  }
    serverApp.Stop(Seconds(runningTime+1));
}

void buildStatistics(FlowMonitorHelper &flowmon, Ptr<FlowMonitor> &monitor, Ipv4InterfaceContainer &devicesIP, Ipv4InterfaceContainer &p2pdeviceIP){

  double throughput = 0;
  double delay = 0;
  double meanThroughput = 0.0;
  double meanDelayPackets = 0.0;
  double meanLostPackets = 0.0;
  int count = 0;
  FILE *f;

  monitor->CheckForLostPackets();
  FlowMonitor::FlowStatsContainer stats = monitor->GetFlowStats ();

  Ptr<Ipv4FlowClassifier> classifier = DynamicCast<Ipv4FlowClassifier> (flowmon.GetClassifier ());

  for (map<FlowId, FlowMonitor::FlowStats>::const_iterator i=stats.begin (); i != stats.end (); ++i, count++){

    Ipv4FlowClassifier::FiveTuple t = classifier->FindFlow (i->first);
    if (t.destinationAddress == p2pdeviceIP.GetAddress(0)){
      throughput = (i->second.txBytes * 8) / ((i->second.timeLastTxPacket - i->second.timeFirstTxPacket).GetSeconds());

      if(printLog){
        cout << "Flowid              = " << i->first << endl;
        cout << "Source Address      = " << t.sourceAddress << endl;
        cout << "Destination Address = " << t.destinationAddress << endl;
        cout << "First Tx Packet     = " << i->second.timeFirstTxPacket.GetSeconds() << endl;
        cout << "First Rx Packet     = " << i->second.timeFirstRxPacket.GetSeconds() << endl;
        cout << "Last Tx Packet      = " << i->second.timeLastTxPacket.GetSeconds() << endl;
        cout << "Last Rx Packet      = " << i->second.timeLastRxPacket.GetSeconds() << endl;
        cout << "Tx Packets          = " << i->second.txPackets << endl;
        cout << "RX Packets          = " << i->second.rxPackets << endl;
        cout << "Lost Packets        = " << i->second.lostPackets << endl;
        cout << "Tx Bytes            = " << i->second.txBytes << endl;
        cout << "RX bytes            = " << i->second.rxBytes << endl;
        cout << "Delay Sum           = " << i->second.delaySum.GetSeconds() << endl;
        cout << "Delay/Packet (mean) = " << i->second.delaySum.GetSeconds()/i->second.rxPackets << endl;
        cout << "Received Throughput = " << throughput << " bps" << " " << throughput/1024 << " kbps" << endl << endl;
      }

      throughput = ((throughput > 0) ? throughput : 0);
      meanThroughput += throughput;
      delay = i->second.delaySum.GetSeconds()/i->second.rxPackets;
      delay = ((delay > 0) ? delay : 0);
      meanDelayPackets += delay;
      meanLostPackets += i->second.lostPackets;

      if(!mobility){
        if(devicesIP.GetAddress(nearestNode) == t.sourceAddress){
          if(traffic){
            std::stringstream ss;
            ss <<prefix<<"_"<<"Nearest_node_cbr.csv";
            f = fopen(ss.str().c_str(), "a");
            fprintf(f, "%d;%.2f;%.2f;%.2f;%d\n", nNodes, dnearestNode, throughput/1024, delay, i->second.lostPackets);
          }
          else{
            std::stringstream ss;
            ss <<prefix<<"_"<<"Nearest_node_pulse.csv";
            f = fopen(ss.str().c_str(), "a");
            fprintf(f, "%d;%.2f;%.2f;%.2f;%d\n", nNodes, dnearestNode, throughput/1024, delay, i->second.lostPackets);
          }
          fclose(f);
        }
        else if (devicesIP.GetAddress(farthestNode) == t.sourceAddress){
          if(traffic){
            std::stringstream ss;
            ss <<prefix<<"_"<<"Farthest_node_cbr.csv";
            f = fopen(ss.str().c_str(), "a");
            fprintf(f, "%d;%.2f;%.2f;%.2f;%d\n", nNodes, dfarthestNode, throughput/1024, delay, i->second.lostPackets);
          }
          else{
            std::stringstream ss;
            ss <<prefix<<"_"<<"Farthest_node_pulse.csv";
            f = fopen(ss.str().c_str(), "a");
            fprintf(f, "%d;%.2f;%.2f;%.2f;%d\n", nNodes, dfarthestNode, throughput/1024, delay, i->second.lostPackets);
          }
          fclose(f);
        }
      }
    }
  }

  meanThroughput /= nNodes;
  meanDelayPackets /= nNodes;
  meanLostPackets /= nNodes;

  cout << "Throughput (mean)   : " << meanThroughput/1024 << " kbps"<< endl;
  cout << "Delay Packets (mean): " << meanDelayPackets << endl;
  cout << "Lost Packets (mean) : " << meanLostPackets << endl;

  // if udp/cbr
  if(traffic){
    if(mobility){
      std::stringstream ss;
      ss <<prefix<<"_"<<"RandomWalk_cbr.csv";
      f = fopen(ss.str().c_str(), "a");
      fprintf(f, "%d;%.2f;%.2f;%.2f\n", nNodes, meanThroughput/1024, meanDelayPackets, meanLostPackets);
    }
    else{
      std::stringstream ss;
      ss <<prefix<<"_"<<"ConstantPosition_cbr.csv";
      f = fopen(ss.str().c_str(), "a");
      fprintf(f, "%d;%.2f;%.2f;%.2f\n", nNodes, meanThroughput/1024, meanDelayPackets, meanLostPackets);
    }
  }
  else{
    if(mobility){
      std::stringstream ss;
      ss <<prefix<<"_"<<"RandomWalk_pulse.csv";
      f = fopen(ss.str().c_str(), "a");
      fprintf(f, "%d;%.2f;%.2f;%.2f\n", nNodes, meanThroughput/1024, meanDelayPackets, meanLostPackets);
    }
    else{
      std::stringstream ss;
      ss <<prefix<<"_"<<"ConstantPosition_pulse_cbr.csv";
      f = fopen(ss.str().c_str(), "a");
      fprintf(f, "%d;%.2f;%.2f;%.2f\n", nNodes, meanThroughput/1024, meanDelayPackets, meanLostPackets);
    }
  }
  fclose(f);
}

void run (){
  //TODO TODO TODO
  // 0. Enable or disable CTS/RTS
  // Hidden station experiment with RTS/CTS disabled, if enableCtsRts is FALSE
  UintegerValue ctsThr = (enableCtsRts ? UintegerValue (100) : UintegerValue (2200));
  Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", ctsThr);

  NodeContainer apnode, nodes, p2pnode;
  NetDeviceContainer apdevice, devices, p2pdevice;
  Ipv4InterfaceContainer apdeviceIP, devicesIP, p2pdeviceIP;

  //Create nodes
  p2pnode.Create (2);
  apnode = p2pnode.Get(1);
  nodes.Create (nNodes);

  // if value TRUE, exist mobility, else, not exist mobility.
  setMobility(apnode, nodes);

  installP2PDevices(p2pnode, p2pdevice);

  installWirelesp2pdevice(apnode, nodes, apdevice, devices);

  installInternetProtocol(apnode, nodes, p2pnode, apdevice, devices, p2pdevice, apdeviceIP, devicesIP, p2pdeviceIP);

  /* Populate routing table */
  Ipv4GlobalRoutingHelper::PopulateRoutingTables ();

  // if udp/cbr
  if(traffic)
    installUDPCommunication(nodes, p2pdeviceIP);
  else
    installTCPCommunication(nodes, p2pnode, p2pdeviceIP);

  // Install FlowMonitor on all nodes
  FlowMonitorHelper flowmon;
  Ptr<FlowMonitor> monitor = flowmon.InstallAll ();

  // Simulation running time
  Simulator::Stop (Seconds (runningTime+2));
  Simulator::Run ();

  // execute magic of the flowmon
  monitor->SerializeToXmlFile("wifiinfra.xml", true, true);
  buildStatistics(flowmon, monitor, devicesIP, p2pdeviceIP);

  // Cleanup
  Simulator::Destroy ();
}

int main (int argc, char **argv){

  CommandLine cmd;

  cmd.AddValue("nodes", "Number of sta nodes", nNodes);
  cmd.AddValue("runningTime", "Application running time in seconds", runningTime);
  cmd.AddValue("traffic", "Traffic (CBR=true, pulse=false)", traffic);
  cmd.AddValue("mobility", "Mobile nodes (true/false)", mobility);
  cmd.AddValue("printLog", "Print Statistics? (true/false)", printLog);
  cmd.AddValue("prefix", "Name prefix of the file ", prefix);

  cmd.Parse (argc, argv);

  if(traffic){
    packetsize = 484;
    onTime = 0.001;
    offTime = 0.001;
  }
  else{
    packetsize = 1484;
    onTime = 2.0;
    offTime = 3.0;
  }

  run ();

  return 0;
}
