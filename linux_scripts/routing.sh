#!/bin/bash

sudo route add -net 10.0.0.0 netmask 255.0.0.0 dev eth1
sudo route add -net 81.5.64.0 netmask 255.255.240.0 dev eth1
sudo route add -host 81.5.91.75 dev eth1 #radio
sudo route add -net 172.16.0.0 netmask 255.240.0.0 dev eth1
sudo route add -net 192.168.0.0 netmask 255.255.0.0 dev eth1
sudo route add -net 192.188.189.0 netmask 255.255.255.0 dev eth1
sudo route add -net 193.125.142.0 netmask 255.255.254.0 dev eth1
sudo route add -net 194.85.80.0 netmask 255.255.255.0 dev eth1
sudo pon hephaestus
sudo route del default
sudo route add default gw 192.168.2.1 dev ppp0
