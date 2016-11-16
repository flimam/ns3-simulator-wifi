#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  args[1] = "5"
}

if (length(args)==1) {
  args[2] = T
}


calc_result <- function(cube){

  for (i in 1:nrow(cube) ){
    for (j in 1:ncol(cube)) {
      cube[i,j,1] <- mean(cube[i,j,2:(as.integer(args[1])+1)])
    }
  }
  return (cube)
}

calc_error <- function(matrix){
  result <- array(dim=c(nrow(matrix)))
  for(i in 1:nrow(matrix)){
    n <- length(matrix[i,2:(as.integer(args[1])+1)])
    sd <- sd(matrix[i,2:(as.integer(args[1])+1)])
    coef_de_conf <- 1.96
    result[i] <- (coef_de_conf) * (sd/sqrt(n))
  }
  return(result)
}

print_error <- function(error, vector, color){
  arrows(nodes, vector-error, nodes, vector+error, col=color, code=3,angle=90,length=0.05)
}


rw_cbr   <- "RandomWalk_cbr.csv"
cp_cbr   <- "ConstantPosition_cbr.csv"
rw_pulse <- "RandomWalk_pulse.csv"
cp_pulse <- "ConstantPosition_pulse_cbr.csv"
n_cbr    <- "Nearest_node_cbr.csv"
n_pulse  <- "Nearest_node_pulse.csv"
f_cbr    <- "Farthest_node_cbr.csv"
f_pulse  <- "Farthest_node_pulse.csv"

cube_rw_cbr <- array(dim=c(8, 3, as.integer(args[1])+1))
cube_cp_cbr <- array(dim=c(8, 3, as.integer(args[1])+1))
cube_rw_pulse <- array(dim=c(8, 3, as.integer(args[1])+1))
cube_cp_pulse <- array(dim=c(8, 3, as.integer(args[1])+1))
cube_n_cbr <- array(dim=c(8, 4, as.integer(args[1])+1))
cube_n_pulse <- array(dim=c(8, 4, as.integer(args[1])+1))
cube_f_cbr <- array(dim=c(8, 4, as.integer(args[1])+1))
cube_f_pulse <- array(dim=c(8, 4, as.integer(args[1])+1))





for (i in 1:args[1]){
  if (args[2]){
    print(paste("Execute ", i, sep=" "))
    system(paste("Rscript script_de_execucao.R", i, sep=" "))
  }
  cube_rw_cbr[1:8,1:3,i+1] <- data.matrix( read.csv(file=paste(i, rw_cbr, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_cp_cbr[1:8,1:3,i+1] <- data.matrix( read.csv(file=paste(i, cp_cbr, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_rw_pulse[1:8,1:3,i+1] <- data.matrix( read.csv(file=paste(i, rw_pulse, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_cp_pulse[1:8,1:3,i+1] <- data.matrix( read.csv(file=paste(i, cp_pulse, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA)) )
  cube_n_cbr[1:8,1:4,i+1] <- data.matrix( read.csv(file=paste(i, n_cbr, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
  cube_n_pulse[1:8,1:4,i+1] <- data.matrix( read.csv(file=paste(i, n_pulse , sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
  cube_f_cbr[1:8,1:4,i+1] <- data.matrix( read.csv(file=paste(i, f_cbr,sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
  cube_f_pulse[1:8,1:4,i+1] <- data.matrix( read.csv(file=paste(i, f_pulse, sep="_"), sep=";", header=F, colClasses=c("NULL", NA, NA,NA,NA)) )
}
nodes <- array(1:8)*5

cube_rw_cbr <- calc_result(cube_rw_cbr)
cube_cp_cbr <- calc_result(cube_cp_cbr)
cube_rw_pulse <- calc_result(cube_rw_pulse)
cube_cp_pulse <- calc_result(cube_cp_pulse)
cube_n_cbr <- calc_result(cube_n_cbr)
cube_n_pulse <- calc_result(cube_n_pulse)
cube_f_cbr <- calc_result(cube_f_cbr)
cube_f_pulse <- calc_result(cube_f_pulse)



pdf("Results/Delay_static.pdf")
plot(nodes, cube_cp_cbr[,2,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,2,1]), range(cube_n_cbr[,3,1]), range(cube_f_cbr[,3,1]), range(cube_cp_pulse[,2,1]), range(cube_n_pulse[,3,1]), range(cube_f_pulse[,3,1])), max(range(cube_cp_cbr[,2,1]), range(cube_n_cbr[,3,1]), range(cube_f_cbr[,3,1]), range(cube_cp_pulse[,2,1]), range(cube_n_pulse[,3,1]), range(cube_f_pulse[,3,1]))), ylab='Delay em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay')
print_error(calc_error(cube_cp_cbr[,2,]), cube_cp_cbr[,2,1], 'blue')

points(nodes, cube_n_cbr[,3,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_cbr[,3,]), cube_n_cbr[,3,1], 'green')

points(nodes, cube_f_cbr[,3,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_cbr[,3,]), cube_f_cbr[,3,1], 'red')

points(nodes, cube_cp_pulse[,2,1], type='b', col='orange', lwd=2, pch=16)
print_error(calc_error(cube_cp_pulse[,2,]), cube_cp_pulse[,2,1], 'orange')

points(nodes, cube_n_pulse[,3,1], type='b', col='purple', lwd=2, pch=15)
print_error(calc_error(cube_n_pulse[,3,]), cube_n_pulse[,3,1], 'purple')

points(nodes, cube_f_pulse[,3,1], type='b', col='yellow', lwd=2, pch=14)
print_error(calc_error(cube_f_pulse[,3,]), cube_f_pulse[,3,1], 'yellow')

# grid(col='black')
legend('bottomright', legend=c('CBR/Média', 'CBR/Nearest', 'CBR/Farthest', 'Rajada/Média', 'Rajada/Nearest', 'Rajada/Farthest'), lwd=2, pch=c(19, 18, 17, 16, 15, 14), title='Protocolo/Parametro', bg='white', col=c('blue', 'green', 'red', 'orange', 'purple', 'yellow'))
dev.off()



pdf("Results/LostPackets_static.pdf")
plot(nodes, cube_cp_cbr[,3,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,3,1]), range(cube_n_cbr[,4,1]), range(cube_f_cbr[,4,1]), range(cube_cp_pulse[,3,1]), range(cube_n_pulse[,4,1]), range(cube_f_pulse[,4,1])), max(range(cube_cp_cbr[,3,1]), range(cube_n_cbr[,4,1]), range(cube_f_cbr[,4,1]), range(cube_cp_pulse[,3,1]), range(cube_n_pulse[,4,1]), range(cube_f_pulse[,4,1]))), ylab='Perca de pacotes', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay')
print_error(calc_error(cube_cp_cbr[,3,]), cube_cp_cbr[,3,1], 'blue')

points(nodes, cube_n_cbr[,4,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_cbr[,4,]), cube_n_cbr[,4,1], 'green')

points(nodes, cube_f_cbr[,4,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_cbr[,4,]), cube_f_cbr[,4,1], 'red')

points(nodes, cube_cp_pulse[,3,1], type='b', col='orange', lwd=2, pch=16)
print_error(calc_error(cube_cp_pulse[,3,]), cube_cp_pulse[,3,1], 'orange')

points(nodes, cube_n_pulse[,4,1], type='b', col='purple', lwd=2, pch=15)
print_error(calc_error(cube_n_pulse[,4,]), cube_n_pulse[,4,1], 'purple')

points(nodes, cube_f_pulse[,4,1], type='b', col='yellow', lwd=2, pch=14)
print_error(calc_error(cube_f_pulse[,4,]), cube_f_pulse[,4,1], 'yellow')

# grid(col='black')
legend('topleft', legend=c('CBR/Média', 'CBR/Nearest', 'CBR/Farthest', 'Rajada/Média', 'Rajada/Nearest', 'Rajada/Farthest'), lwd=2, pch=c(19, 18, 17, 16, 15, 14), title='Protocolo/Parametro', bg='white', col=c('blue', 'green', 'red', 'orange', 'purple', 'yellow'))
dev.off()



#Graficos principais
pdf("Results/Throughput_CBR_pulse.pdf")
plot(nodes, cube_cp_cbr[,1,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,1,1]), range(cube_cp_pulse[,1,1]), range(cube_rw_cbr[,1,1]), range(cube_rw_pulse[,1,1])), max(range(cube_cp_cbr[,1,1]), range(cube_cp_pulse[,1,1]), range(cube_rw_cbr[,1,1]), range(cube_rw_pulse[,1,1]))), ylab='Throughput médio em kbts', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Throughput médio')
print_error(calc_error(cube_cp_cbr[,1,]), cube_cp_cbr[,1,1], 'blue')

points(nodes, cube_rw_cbr[,1,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_rw_cbr[,1,]), cube_rw_cbr[,1,1], 'green')

points(nodes, cube_cp_pulse[,1,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_cp_pulse[,1,]), cube_cp_pulse[,1,1], 'red')

points(nodes, cube_rw_pulse[,1,1], type='b', col='orange', lwd=2, pch=16)
print_error(calc_error(cube_rw_pulse[,1,]), cube_rw_pulse[,1,1], 'orange')

# grid(col='black')
legend('topleft', legend=c('CBR/staticos', 'CBR/móveis', 'Rajada/estáticos', 'Rajada/móveis'), lwd=2, pch=c(19, 18, 17, 16), title='Protocolo/mobilidade dos nós', bg='white', col=c('blue','green', 'red', 'orange'))
dev.off()



pdf("Results/Delay_CBR_pulse.pdf")
plot(nodes, cube_cp_cbr[,2,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,2,1]), range(cube_cp_pulse[,2,1]), range(cube_rw_cbr[,2,1]), range(cube_rw_pulse[,2,1])), max(range(cube_cp_cbr[,2,1]), range(cube_cp_pulse[,2,1]), range(cube_rw_cbr[,2,1]), range(cube_rw_pulse[,2,1]))), ylab='Delay médio em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay médio')
print_error(calc_error(cube_cp_cbr[,2,]), cube_cp_cbr[,2,1], 'blue')

points(nodes, cube_rw_cbr[,2,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_rw_cbr[,2,]), cube_rw_cbr[,2,1], 'green')

points(nodes, cube_cp_pulse[,2,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_cp_pulse[,2,]), cube_cp_pulse[,2,1], 'red')

points(nodes, cube_rw_pulse[,2,1], type='b', col='orange', lwd=2, pch=16)
print_error(calc_error(cube_rw_pulse[,2,]), cube_rw_pulse[,2,1], 'orange')

# grid(col='black')
legend('topleft', legend=c('CBR/staticos', 'CBR/móveis', 'Rajada/estáticos', 'Rajada/móveis'), lwd=2, pch=c(19, 18, 17, 16), title='Protocolo/mobilidade dos nós', bg='white', col=c('blue','green', 'red', 'orange'))
dev.off()




pdf("Results/LostPackets_CBR_pulse.pdf")
plot(nodes, cube_cp_cbr[,3,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,3,1]), range(cube_cp_pulse[,3,1]), range(cube_rw_cbr[,3,1]), range(cube_rw_pulse[,3,1])), max(range(cube_cp_cbr[,3,1]), range(cube_cp_pulse[,3,1]), range(cube_rw_cbr[,3,1]), range(cube_rw_pulse[,3,1]))), ylab='Perca média de pacotes', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Perca média de pacotes (valores absolutos)')
print_error(calc_error(cube_cp_cbr[,3,]), cube_cp_cbr[,3,1], 'blue')

points(nodes, cube_rw_cbr[,3,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_rw_cbr[,3,]), cube_rw_cbr[,3,1], 'green')

points(nodes, cube_cp_pulse[,3,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_cp_pulse[,3,]), cube_cp_pulse[,3,1], 'red')

points(nodes, cube_rw_pulse[,3,1], type='b', col='orange', lwd=2, pch=16)
print_error(calc_error(cube_rw_pulse[,3,]), cube_rw_pulse[,3,1], 'orange')

# grid(col='black')
legend('topleft', legend=c('CBR/staticos', 'CBR/móveis', 'Rajada/estáticos', 'Rajada/móveis'), lwd=2, pch=c(19, 18, 17, 16), title='Protocolo/mobilidade dos nós', bg='white', col=c('blue','green', 'red', 'orange'))
dev.off()






#Graficos individuais para o primeiro cenario(sem mobilidade)
pdf("Results/Throughput_static_CBR.pdf")
plot(nodes, cube_cp_cbr[,1,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,1,1]), range(cube_n_cbr[,2,1]), range(cube_f_cbr[,2,1])), max(range(cube_cp_cbr[,1,1]), range(cube_n_cbr[,2,1]), range(cube_f_cbr[,2,1]))), ylab='Throughput em kbts', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Throughput CBR')
print_error(calc_error(cube_cp_cbr[,1,]), cube_cp_cbr[,1,1], 'blue')

points(nodes, cube_n_cbr[,2,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_cbr[,2,]), cube_n_cbr[,2,1], 'green')

points(nodes, cube_f_cbr[,2,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_cbr[,2,]), cube_f_cbr[,2,1], 'red')

# grid(col='black')
legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
dev.off()



pdf("Results/Throughput_static_pulse.pdf")
plot(nodes, cube_cp_pulse[,1,1], xlab='Número de nós', ylim=c(min(range(cube_cp_pulse[,1,1]), range(cube_n_pulse[,2,1]), range(cube_f_pulse[,2,1])), max(range(cube_cp_pulse[,1,1]), range(cube_n_pulse[,2,1]), range(cube_f_pulse[,2,1]))), ylab='Throughput em kbits', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Throughput pulse')
print_error(calc_error(cube_cp_pulse[,1,]), cube_cp_pulse[,1,1], "blue")
points(nodes, cube_n_pulse[,2,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_pulse[,2,]), cube_n_pulse[,2,1], 'green')
points(nodes, cube_f_pulse[,2,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_pulse[,2,]), cube_f_pulse[,2,1], 'red')
legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
dev.off()


pdf("DelayPackets_static_CBR.pdf")
plot(nodes, cube_cp_cbr[,2,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,2,1]), range(cube_n_cbr[,3,1]), range(cube_f_cbr[,3,1])), max(range(cube_cp_cbr[,2,1]), range(cube_n_cbr[,3,1]), range(cube_f_cbr[,3,1]))), ylab='Delay em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay CBR')
print_error(calc_error(cube_cp_cbr[,2,]), cube_cp_cbr[,2,1], 'blue')

points(nodes, cube_n_cbr[,3,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_cbr[,3,]), cube_n_cbr[,3,1], 'green')

points(nodes, cube_f_cbr[,3,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_cbr[,3,]), cube_f_cbr[,3,1], 'red')

# grid(col='black')
legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
dev.off()



pdf("Results/DelayPackets_static_pulse.pdf")
plot(nodes, cube_cp_pulse[,2,1], xlab='Número de nós', ylim=c(min(range(cube_cp_pulse[,2,1]), range(cube_n_pulse[,3,1]), range(cube_f_pulse[,3,1])), max(range(cube_cp_pulse[,2,1]), range(cube_n_pulse[,3,1]), range(cube_f_pulse[,3,1]))), ylab='Delay em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='Delay pulse')
print_error(calc_error(cube_cp_pulse[,2,]), cube_cp_pulse[,2,1], 'blue')

points(nodes, cube_n_pulse[,3,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_pulse[,3,]), cube_n_pulse[,3,1], 'green')

points(nodes, cube_f_pulse[,3,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_pulse[,3,]), cube_f_pulse[,3,1], 'red')

# grid(col='black')
legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
dev.off()



pdf("Results/LostPackets_static_CBR.pdf")
plot(nodes, cube_cp_cbr[,3,1], xlab='Número de nós', ylim=c(min(range(cube_cp_cbr[,3,1]), range(cube_n_cbr[,4,1]), range(cube_f_cbr[,4,1])), max(range(cube_cp_cbr[,3,1]), range(cube_n_cbr[,4,1]), range(cube_f_cbr[,4,1]))), ylab='LostPackets em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='LostPackets CBR')
print_error(calc_error(cube_cp_cbr[,3,]), cube_cp_cbr[,3,1], 'blue')

points(nodes, cube_n_cbr[,4,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_cbr[,4,]), cube_n_cbr[,4,1], 'green')

points(nodes, cube_f_cbr[,4,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_cbr[,4,]), cube_f_cbr[,4,1], 'red')

# grid(col='black')
legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
dev.off()



pdf("Results/LostPackets_static_pulse.pdf")
plot(nodes, cube_cp_pulse[,3,1], xlab='Número de nós', ylim=c(min(range(cube_cp_pulse[,3,1]), range(cube_n_pulse[,4,1]), range(cube_f_pulse[,4,1])), max(range(cube_cp_pulse[,3,1]), range(cube_n_pulse[,4,1]), range(cube_f_pulse[,2,1]))), ylab='LostPackets em ms', xaxp=c(5,40,7), type="b", col="blue", lwd=2, pch=19, main='LostPackets pulse')
print_error(calc_error(cube_cp_pulse[,3,]), cube_cp_pulse[,3,1], 'blue')

points(nodes, cube_n_pulse[,4,1], type='b', col='green', lwd=2, pch=18)
print_error(calc_error(cube_n_pulse[,4,]), cube_n_pulse[,4,1], 'green')

points(nodes, cube_f_pulse[,4,1], type='b', col='red', lwd=2, pch=17)
print_error(calc_error(cube_f_pulse[,4,]), cube_f_pulse[,4,1], 'red')

# grid(col='black')
legend('topleft', legend=c('Média', 'Nearest', 'Farthest'), lwd=2, pch=c(19, 18, 17), title='Parametros', bg='white', col=c('blue', 'green', 'red'))
dev.off()
