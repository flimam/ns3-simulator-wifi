if(file.exists("RandomWalk_cbr.csv"))
  file.remove("RandomWalk_cbr.csv")
if(file.exists("ConstantPosition_cbr.csv"))
  file.remove("ConstantPosition_cbr.csv")
file.create("ConstantPosition_cbr.csv")
if(file.exists("RandomWalk_pulse.csv"))
  file.remove("RandomWalk_pulse.csv")
if(file.exists("ConstantPosition_pulse_cbr.csv"))
  file.remove("ConstantPosition_pulse_cbr.csv")

for (i in seq(from=5, to=40, by=5)){
  print(paste ('Nos=',  i))
  print("CBR e nos fixos")
  system(paste("NS_GLOBAL_VALUE=\"RngRun=3\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=20 --traffic=true --mobility=false --printLog=false\"", collapse=", ", sep=""))
#  print("CBR e nos moveis")
#  system(paste("NS_GLOBAL_VALUE=\"RngRun=3\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=120 --traffic=true --mobility=true\" --printLog=false\"", collapse=", ", sep=""))
#  print("Rajada e nos fixos")
#  system(paste("NS_GLOBAL_VALUE=\"RngRun=3\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=120 --traffic=false --mobility=false\" --printLog=false\"", collapse=", ", sep=""))
#  print("Rajada e nos moveis")
#  system(paste("NS_GLOBAL_VALUE=\"RngRun=3\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=120 --traffic=false --mobility=true\" --printLog=false\"", collapse=", ", sep=""))
}

#rw_cbr <- read.csv("RandomWalk_cbr.csv", header=F, sep=";")
cp_cbr <- read.csv("ConstantPosition_cbr.csv", header=F, sep=";")
#rw_pulse <- read.csv("RandomWalk_pulse.csv", header=F, sep=";")
#cp_pulse <- read.csv("ConstantPosition_pulse_cbr.csv", header=F, sep=";")

plot(cp_cbr[,1], cp_cbr[,2])

#pdf("Throughput.pdf")

#dev.off()

#pdf("DelayPackets.pdf")
#dev.off()

#pdf("LostPackets.pdf")
#dev.off()

