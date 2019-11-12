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
        maxconn 15000           # Max simultaneous connections from an upstream server
        spread-checks 5         # Distribute health checks with some randomness
        stats   socket /var/run/haproxy.stats
        chroot      /var/lib/haproxy
        pidfile     /var/run/haproxy.pid
        log 127.0.0.1 local0
        log 127.0.0.1 local1 notice

defaults
        log global
        mode http
        option httplog
        option dontlognull
        option abortonclose     # abort request if client closes output channel while waiting
        option redispatch       # any server can handle any session
        option httpclose        # add "Connection:close" header if it is missing
        retries                 3
        timeout http-request    10s
        timeout connect         5s
        timeout client          50s
        timeout server          30s
        timeout http-keep-alive 1s
        timeout check           5s
        timeout queue           5s  # maximum time to wait in the queue for a connection slot to be free
        timeout tunnel          2m  # maximum inactivity time on the client and server side for tunnels
        timeout client-fin      1s  # inactivity timeout on the client side for half-closed connections
        timeout server-fin      1s  # inactivity timeout on the server side for half-closed connections

        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

frontend http_front
        bind *:80
        stats uri /haproxy?stats
        mode http
        default_backend http_back

backend http_back
        #balance roundrobin
        balance leastconn
        mode http
        cookie JSESSIONID prefix
        option forwardfor
        option httpchk HEAD / HTTP/1.0
        http-check expect status 200
        server webserver1 $webserver1:8080 weight 1 check inter 1000 rise 5 fall 1    # ip_address_of_1st_webserver
        server webserver2 $webserver2:8080 weight 1 check inter 1000 rise 5 fall 1    # ip_address_of_2nd_webserver
                                              
EOT


haproxy -f /etc/haproxy/haproxy.cfg -c; #To test haproxy configuration

systemctl enable haproxy;
systemctl start haproxy;
echo "enter to see haproxy status: ";
systemctl status haproxy;
