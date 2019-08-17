#!/bin/sh

# Name:        tes_haproxy.sh
#
# Author:      Efkan Isazade

#systemctl start haproxy;
#systemctl enable haproxy;

echo "enter haproxy loadbalancer ip address :"
read loadbalancer

echo "hit ctl+c when done";
while true; 
do
curl $loadbalancer:80 ;
sleep 1 ;
done
