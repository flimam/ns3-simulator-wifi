#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  args[1] = "0"
}

if(file.exists(paste(args[1],"RandomWalk_cbr.csv",sep="_")))
  file.remove(paste(args[1],"RandomWalk_cbr.csv",sep="_"))
if(file.exists(paste(args[1],"ConstantPosition_cbr.csv",sep="_")))
  file.remove(paste(args[1],"ConstantPosition_cbr.csv",sep="_"))
if(file.exists(paste(args[1],"RandomWalk_pulse.csv",sep="_")))
  file.remove(paste(args[1],"RandomWalk_pulse.csv",sep="_"))
if(file.exists(paste(args[1],"ConstantPosition_pulse_cbr.csv",sep="_")))
  file.remove(paste(args[1],"ConstantPosition_pulse_cbr.csv",sep="_"))
if(file.exists(paste(args[1],"Nearest_node_cbr.csv",sep="_")))
  file.remove(paste(args[1],"Nearest_node_cbr.csv",sep="_"))
if(file.exists(paste(args[1],"Nearest_node_pulse.csv",sep="_")))
  file.remove(paste(args[1],"Nearest_node_pulse.csv",sep="_"))
if(file.exists(paste(args[1],"Farthest_node_cbr.csv",sep="_")))
  file.remove(paste(args[1],"Farthest_node_cbr.csv",sep="_"))
if(file.exists(paste(args[1],"Farthest_node_pulse.csv",sep="_")))
  file.remove(paste(args[1],"Farthest_node_pulse.csv",sep="_"))

for (i in seq(from=5, to=40, by=5)){
  rand <- sample(1:9382, 1)
  print(paste ('Nos=',  i))
  print("CBR e nos fixos")
  system(paste("NS_GLOBAL_VALUE=\"RngRun=", rand,"\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=60 --traffic=true --mobility=false --printLog=false --prefix=\\\"",args[1],"\\\"   \"", collapse=", ", sep=""))
  print("CBR e nos moveis")
  system(paste("NS_GLOBAL_VALUE=\"RngRun=", rand,"\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=60 --traffic=true --mobility=true --printLog=false --prefix=\\\"",args[1],"\\\"    \"", collapse=", ", sep=""))
  print("Rajada e nos fixos")
  system(paste("NS_GLOBAL_VALUE=\"RngRun=", rand,"\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=60 --traffic=false --mobility=false --printLog=false --prefix=\\\"",args[1],"\\\"   \"", collapse=", ", sep=""))
  print("Rajada e nos moveis")
  system(paste("NS_GLOBAL_VALUE=\"RngRun=", rand,"\" ./waf --run \"scratch/wifiinfra --nodes=",i," --runningTime=60 --traffic=false --mobility=true --printLog=false --prefix=\\\"",args[1],"\\\"   \"", collapse=", ", sep=""))
}
