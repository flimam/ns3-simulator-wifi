#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  args[1] = "5"
}

rw_cbr   <- "RandomWalk_cbr.csv"
cp_cbr   <- "ConstantPosition_cbr.csv"
rw_pulse <- "RandomWalk_pulse.csv"
cp_pulse <- "ConstantPosition_pulse_cbr.csv"
n_cbr    <- "Nearest_node_cbr.csv"
n_pulse  <- "Nearest_node_pulse.csv"
f_cbr    <- "Farthest_node_cbr.csv"
f_pulse  <- "Farthest_node_pulse.csv"

cube_rw_cbr <- array(dim=c(8, 3, args[1]))
cube_cp_cbr <- array(dim=c(8, 3, args[1]))
cube_rw_pulse <- array(dim=c(8, 3, args[1]))
cube_cp_pulse <- array(dim=c(8, 3, args[1]))
cube_n_cbr <- array(dim=c(8, 4, args[1]))
cube_n_pulse <- array(dim=c(8, 4, args[1]))
cube_f_cbr <- array(dim=c(8, 4, args[1]))
cube_f_pulse <- array(dim=c(8, 4, args[1]))

for (i in 1:args[1]){
  # print(paste("Execute ", i, sep=" "))
  # system(paste("Rscript script_de_execucao.R", i, sep=" "))
  cube_rw_cbr[1:8,1:3,i] <- data.matrix( read.csv(file=paste(i, rw_cbr, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_cp_cbr[1:8,1:3,i] <- data.matrix( read.csv(file=paste(i, cp_cbr, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_rw_pulse[1:8,1:3,i] <- data.matrix( read.csv(file=paste(i, rw_pulse, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_cp_pulse[1:8,1:3,i] <- data.matrix( read.csv(file=paste(i, cp_pulse, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_n_cbr[1:8,1:4,i] <- data.matrix( read.csv(file=paste(i, n_cbr, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
  cube_n_pulse[1:8,1:4,i] <- data.matrix( read.csv(file=paste(i, n_pulse , sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
  cube_f_cbr[1:8,1:4,i] <- data.matrix( read.csv(file=paste(i, f_cbr,sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
  cube_f_pulse[1:8,1:4,i] <- data.matrix( read.csv(file=paste(i, f_pulse, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
}
nodes <- array(1:8)*5

#
# pdf("Delay_static.pdf")
# plot(cp_cbr[,1], cp_cbr[,3], xlab='Número de nós', ylim=c(min(range(cp_cbr[,3]), range(n_cbr[,4]), range(f_cbr[,4]), range(cp_pulse[,3]), range(n_pulse[,4]), range(f_pulse[,4])), max(range(cp_cbr[,3]), range(n_cbr[,4]), range(f_cbr[,4]), range(cp_pulse[,3]), range(n_pulse[,4]), range(f_pulse[,4]))), ylab='Delay em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay')
# points(n_cbr[,1], n_cbr[,4], type='b', col='green', lwd=2, pch=18)
# points(f_cbr[,1], f_cbr[,4], type='b', col='red', lwd=2, pch=17)
# points(cp_pulse[,1], cp_pulse[,3], type='b', col='orange', lwd=2, pch=16)
# points(n_pulse[,1], n_pulse[,4], type='b', col='purple', lwd=2, pch=15)
# points(f_pulse[,1], f_pulse[,4], type='b', col='yellow', lwd=2, pch=14)
# grid(col='black')
# legend('topleft', legend=c('CBR/Média', 'CBR/Nearest', 'CBR/Farthest', 'Rajada/Média', 'Rajada/Nearest', 'Rajada/Farthest'), lwd=2, pch=c(19, 18, 17, 16, 15, 14), title='Protocolo/Parametro', bg='white', col=c('blue', 'green', 'red', 'orange', 'purple', 'yellow'))
# dev.off()
#
# pdf("LostPackets_static.pdf")
# plot(cp_cbr[,1], cp_cbr[,4], xlab='Número de nós', ylim=c(min(range(cp_cbr[,4]), range(n_cbr[,5]), range(f_cbr[,5]), range(cp_pulse[,4]), range(n_pulse[,5]), range(f_pulse[,5])), max(range(cp_cbr[,4]), range(n_cbr[,5]), range(f_cbr[,5]), range(cp_pulse[,4]), range(n_pulse[,5]), range(f_pulse[,5]))), ylab='Perca de pacotes', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay')
# points(n_cbr[,1], n_cbr[,5], type='b', col='green', lwd=2, pch=18)
# points(f_cbr[,1], f_cbr[,5], type='b', col='red', lwd=2, pch=17)
# points(cp_pulse[,1], cp_pulse[,4], type='b', col='orange', lwd=2, pch=16)
# points(n_pulse[,1], n_pulse[,5], type='b', col='purple', lwd=2, pch=15)
# points(f_pulse[,1], f_pulse[,5], type='b', col='yellow', lwd=2, pch=14)
# grid(col='black')
# legend('topleft', legend=c('CBR/Média', 'CBR/Nearest', 'CBR/Farthest', 'Rajada/Média', 'Rajada/Nearest', 'Rajada/Farthest'), lwd=2, pch=c(19, 18, 17, 16, 15, 14), title='Protocolo/Parametro', bg='white', col=c('blue', 'green', 'red', 'orange', 'purple', 'yellow'))
# dev.off()
#
# #Graficos principais
# pdf("Throughput_CBR_pulse.pdf")
# plot(cp_cbr[,1], cp_cbr[,2], xlab='Número de nós', ylim=c(min(range(cp_cbr[,2]), range(cp_pulse[,2]), range(rw_cbr[,2]), range(rw_pulse[,2])), max(range(cp_cbr[,2]), range(cp_pulse[,2]), range(rw_cbr[,2]), range(rw_pulse[,2]))), ylab='Throughput médio em kbts', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Throughput médio')
# points(rw_cbr[,1], rw_cbr[,2], type='b', col='green', lwd=2, pch=18)
# points(cp_pulse[,1], cp_pulse[,2], type='b', col='red', lwd=2, pch=17)
# points(rw_pulse[,1], rw_pulse[,2], type='b', col='orange', lwd=2, pch=16)
# grid(col='black')
# legend('topleft', legend=c('CBR/staticos', 'CBR/móveis', 'Rajada/estáticos', 'Rajada/móveis'), lwd=2, pch=c(19, 18, 17, 16), title='Protocolo/mobilidade dos nós', bg='white', col=c('blue','green', 'red', 'orange'))
# dev.off()
#
# pdf("Delay_CBR_pulse.pdf")
# plot(cp_cbr[,1], cp_cbr[,3], xlab='Número de nós', ylim=c(min(range(cp_cbr[,3]), range(cp_pulse[,3]), range(rw_cbr[,3]), range(rw_pulse[,3])), max(range(cp_cbr[,3]), range(cp_pulse[,3]), range(rw_cbr[,3]), range(rw_pulse[,3]))), ylab='Delay médio em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay médio')
# points(rw_cbr[,1], rw_cbr[,3], type='b', col='green', lwd=2, pch=18)
# points(cp_pulse[,1], cp_pulse[,3], type='b', col='red', lwd=2, pch=17)
# points(rw_pulse[,1], rw_pulse[,3], type='b', col='orange', lwd=2, pch=16)
# grid(col='black')
# legend('topleft', legend=c('CBR/staticos', 'CBR/móveis', 'Rajada/estáticos', 'Rajada/móveis'), lwd=2, pch=c(19, 18, 17, 16), title='Protocolo/mobilidade dos nós', bg='white', col=c('blue','green', 'red', 'orange'))
# dev.off()
#
# pdf("LostPackets_CBR_pulse.pdf")
# plot(cp_cbr[,1], cp_cbr[,4], xlab='Número de nós', ylim=c(min(range(cp_cbr[,4]), range(cp_pulse[,4]), range(rw_cbr[,4]), range(rw_pulse[,4])), max(range(cp_cbr[,4]), range(cp_pulse[,4]), range(rw_cbr[,4]), range(rw_pulse[,4]))), ylab='Perca média de pacotes', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Perca média de pacotes (valores absolutos)')
# points(rw_cbr[,1], rw_cbr[,4], type='b', col='green', lwd=2, pch=18)
# points(cp_pulse[,1], cp_pulse[,4], type='b', col='red', lwd=2, pch=17)
# points(rw_pulse[,1], rw_pulse[,4], type='b', col='orange', lwd=2, pch=16)
# grid(col='black')
# legend('topleft', legend=c('CBR/staticos', 'CBR/móveis', 'Rajada/estáticos', 'Rajada/móveis'), lwd=2, pch=c(19, 18, 17, 16), title='Protocolo/mobilidade dos nós', bg='white', col=c('blue','green', 'red', 'orange'))
# dev.off()
#
# #Graficos individuais para o primeiro cenario(sem mobilidade)
# pdf("Throughput_static_CBR.pdf")
# plot(cp_cbr[,1], cp_cbr[,2], xlab='Número de nós', ylim=c(min(range(cp_cbr[,2]), range(n_cbr[,3]), range(f_cbr[,3])), max(range(cp_cbr[,2]), range(n_cbr[,3]), range(f_cbr[,3]))), ylab='Throughput em kbts', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Throughput CBR')
# points(n_cbr[,1], n_cbr[,3], type='b', col='green', lwd=2, pch=18)
# points(f_cbr[,1], f_cbr[,3], type='b', col='red', lwd=2, pch=17)
# grid(col='black')
# legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
# dev.off()
#



pdf("Throughput_static_pulse.pdf")
plot(nodes, cube_cp_pulse[,1,1], xlab='Número de nós', ylim=c(min(range(cube_cp_pulse[,1,1]), range(cube_n_pulse[,2,1]), range(cube_f_pulse[,2,1])), max(range(cube_cp_pulse[,1,1]), range(cube_n_pulse[,2,1]), range(cube_f_pulse[,2,1]))), ylab='Throughput em kbits', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Throughput pulse')
arrows(nodes,cube_cp_pulse[,1,1]-10,nodes,cube_cp_pulse[,1,1]+10, col="blue", code=3,angle=90,length=0.05)
points(nodes, cube_n_pulse[,2,1], type='b', col='green', lwd=2, pch=18)
arrows(nodes,cube_n_pulse[,2,1]-10,nodes,cube_n_pulse[,2,1]+10, col='green', code=3,angle=90,length=0.05)
points(nodes, cube_f_pulse[,2,1], type='b', col='red', lwd=2, pch=17)
arrows(nodes,cube_f_pulse[,2,1]-10,nodes,cube_f_pulse[,2,1]+10, col='red',  code=3,angle=90,length=0.05)
# grid(col='black')
legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
dev.off()


#
# pdf("DelayPackets_static_CBR.pdf")
# plot(cp_cbr[,1], cp_cbr[,3], xlab='Número de nós', ylim=c(min(range(cp_cbr[,3]), range(n_cbr[,4]), range(f_cbr[,4])), max(range(cp_cbr[,3]), range(n_cbr[,4]), range(f_cbr[,4]))), ylab='Delay em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay CBR')
# points(n_cbr[,1], n_cbr[,4], type='b', col='green', lwd=2, pch=18)
# points(f_cbr[,1], f_cbr[,4], type='b', col='red', lwd=2, pch=17)
# grid(col='black')
# legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
# dev.off()
#
# pdf("DelayPackets_static_pulse.pdf")
# plot(cp_pulse[,1], cp_pulse[,3], xlab='Número de nós', ylim=c(min(range(cp_pulse[,3]), range(n_pulse[,4]), range(f_pulse[,4])), max(range(cp_pulse[,3]), range(n_pulse[,4]), range(f_pulse[,4]))), ylab='Delay em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay pulse')
# points(n_pulse[,1], n_pulse[,4], type='b', col='green', lwd=2, pch=18)
# points(f_pulse[,1], f_pulse[,4], type='b', col='red', lwd=2, pch=17)
# grid(col='black')
# legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
# dev.off()
#
# pdf("LostPackets_static_CBR.pdf")
# plot(cp_cbr[,1], cp_cbr[,4], xlab='Número de nós', ylim=c(min(range(cp_cbr[,4]), range(n_cbr[,5]), range(f_cbr[,5])), max(range(cp_cbr[,4]), range(n_cbr[,5]), range(f_cbr[,5]))), ylab='LostPackets em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='LostPackets CBR')
# points(n_cbr[,1], n_cbr[,5], type='b', col='green', lwd=2, pch=18)
# points(f_cbr[,1], f_cbr[,5], type='b', col='red', lwd=2, pch=17)
# grid(col='black')
# legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
# dev.off()
#
# pdf("LostPackets_static_pulse.pdf")
# plot(cp_pulse[,1], cp_pulse[,4], xlab='Número de nós', ylim=c(min(range(cp_pulse[,4]), range(n_pulse[,5]), range(f_pulse[,5])), max(range(cp_pulse[,4]), range(n_pulse[,5]), range(f_pulse[,3]))), ylab='LostPackets em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='LostPackets pulse')
# points(n_pulse[,1], n_pulse[,5], type='b', col='green', lwd=2, pch=18)
# points(f_pulse[,1], f_pulse[,5], type='b', col='red', lwd=2, pch=17)
# grid(col='black')
# legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
# dev.off()
















# ic.m <- function(x, conf = 0.95){
#   n <- length(x)
#   media <- mean(x)
#   variancia <- var(x)
#   quantis <- qt(c((1-conf)/2, 1 - (1-conf)/2), df = n-1)
#   ic <- media + quantis * sqrt(variancia/n)
#   return(ic)
# }
#
# teste <- c(4,5,3,6)
# n <- length(teste)
# media <- mean(teste)
# variancia <- var(teste)
# conf <- 0.95
#
# result <- (conf/2) * (variancia/sqrt(n))
#
# print (4-result)
# print (4+result)
# print (media+result)
# print (media-result)
#
# print (ic.m(teste))
#
#
# pdf("DelayPackets_static_pulse.pdf")
# plot(teste[2], teste[2], xlab='Número de nós', ylim=c(min(range(teste)), max(range(teste))), ylab='Delay em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay pulse')
# grid(col='black')
# arrows(bp,media+result,bp,media-result, code=3,angle=90,length=0.05)
# legend('topleft', legend=c('Média'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
# dev.off()
#
# system("open DelayPackets_static_pulse.pdf")
#
#
# count <- 4
#
# m = matrix(8, 3, count)
#
# arq <- read.csv(file="teste_ConstantPosition_pulse_cbr.csv", sep=";", header=F, colClasses=c("NULL", NA, NA,NA))
# print (m)
# # teste <- array( dim=c(8,3,count))
# # print (teste)
