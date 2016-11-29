#!/bin/sh

cd
cd ns3/ns-allinone-3.26/ns-3.26/
git clone https://github.com/FelipeLimaM/ns3-simulator-wifi.git repository
ln -s ~/ns3/ns-allinone-3.26/ns-3.26/repository/wifi_infra.cc scratch/wifiinfra.cc
ln -s ~/ns3/ns-allinone-3.26/ns-3.26/repository/script_de_execucao.R .
ln -s ~/ns3/ns-allinone-3.26/ns-3.26/repository/script_de_graficos.R .

exec bash
