//Port
ApplicationContainer apps;
int serverports[4]={9000, 9001, 9002, 9003};
for (int i=0; i<4; i++)
{
  OnOffHelper onoff ("ns3::UdpSocketFactory", InetSocketAddress ("10.1.2.2", serverports[i]));
  onoff.SetAttribute ("OnTime", StringValue ("Constant:1.0"));
  onoff.SetAttribute ("OffTime", StringValue ("Constant:0.0"));
  apps = onoff.Install (Nodes.Get (0));
  apps.Start (Seconds (1+i));
  apps.Stop (Seconds (10));
}
