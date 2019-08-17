###!bin/bash
# Name:        keepalived.sh
#
# Author:      Efkan Isazade

cd ~ ;
yum -y install keepalived;
mv /etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf_bac;
touch /etc/keepalived/keepalived.conf;
echo "enter your interface name";
read interface;
echo "enter priority. 101 for master loadbalancer or 100 for Backup loadbalancer";
read priority;
echo "enter the virtual IP address" ;
read virtual_ip;
cat <<END >>/etc/keepalived/keepalived.conf;

vrrp_script chk_haproxy {
  script "killall -0 haproxy" # check the haproxy process
  interval 2 # every 2 seconds
  weight 2 # add 2 points if OK
}

vrrp_instance VI_1 {
    state MASTER
    interface $interface   	#put your  interface name here. [to see interface name: $  ip a ]
    virtual_router_id 51
    priority $priority            # 101 for master. 100 for backup. [priority of master> priority of backup]
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111   #password
    }
    virtual_ipaddress {
       $virtual_ip  #0.0.0.0         	# use the virtual ip address. 
    }
}
END

systemctl start keepalived;
systemctl enable keepalived;
echo "enter to see keepalived status"
systemctl status keepalived;
