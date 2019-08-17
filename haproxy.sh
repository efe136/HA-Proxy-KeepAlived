#!/bin/sh

# Name:        haproxy.sh
#
# Author:      Efkan Isazade

#sudo su
cd ~ ;
echo "enter the ip address of webserver1: "
read webserver1
echo "enter the ip address of webserver2: "
read webserver2

yum -y install make gcc perl pcre-devel zlib-devel wget openssl-devel readline-devel; #required epel-release
yum -y install lua; #required haproxy source
yum -y install haproxy; #required haproxy source
lua -v # check version
haproxy -vv # check version
id -u haproxy &> /dev/null || useradd -s /usr/sbin/nologin -r haproxy; #add a haproxy no login user
cd ~/etc/haproxy;
cp haproxy.cfg haproxy.cfg_bac;
#cat > ~/haproxyconfigfile.txt <<'endmsg'
cat <<EOT >> haproxy.cfg

global
   log /dev/log local0
   log /dev/log local1 notice
   chroot /var/lib/haproxy
   stats timeout 30s
   user haproxy
   group haproxy
   daemon

defaults
   log global
   mode http
   option httplog
   option dontlognull
   retries                 1
   timeout http-request    1s
   #timeout queue           1m
   timeout connect         1s
   timeout client          1s
   timeout server          1s
   timeout http-keep-alive 1s
   timeout check           1s
   #maxconn                 2048


#frontend
#---------------------------------
frontend http_front
bind *:80
stats uri /haproxy?stats
default_backend http_back

#round robin balancing backend http
#-----------------------------------
backend http_back
balance roundrobin
#balance leastconn
#balance source
mode http
#option httpchk GET / HTTP/1.1
#http-check expect status 200
   server webserver1 $webserver1:8080 check
   server webserver2 $webserver2:8080 check
                                              
EOT
#other script lines here
#endmsg

#sed -i 's/webserver1_ip_address/$webserver1/g' /etc/haproxy/haproxy.conf
#sed -i 's/webserver1_ip_address/$webserver1/g' /etc/haproxy/haproxy.conf

haproxy -f /etc/haproxy/haproxy.cfg -c; #To test haproxy configuration

systemctl enable haproxy;
systemctl start haproxy;
echo "enter to see haproxy status: ";
systemctl status haproxy;
