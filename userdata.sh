#!/bin/bash
hostnamectl --static set-hostname DNSSRV
sed -i "s/^127.0.0.1 localhost/127.0.0.1 localhost DNSSRV/g" /etc/hosts
apt-get update -y
apt-get install -y bind9 bind9-doc language-pack-ko
# named.conf.options
cat <<EOL> /etc/bind/named.conf.options
options {
directory "/var/cache/bind";
recursion yes;
allow-query { any; };
forwarders {
8.8.8.8;
};
forward only;
auth-nxdomain no;
};
zone "eyjo.internal" {
type forward;
forward only;
forwarders { 10.70.1.250; 10.70.2.250; };
};
zone "ap-northeast-2.compute.internal" {
type forward;
forward only;
forwarders { 10.70.1.250; 10.70.2.250; };
};
EOL

# named.conf.local
cat <<EOL> /etc/bind/named.conf.local
zone "idcneta.internal" {
type master;
file "/etc/bind/db.idcneta.internal"; # zone file path
};
zone "80.10.in-addr.arpa" {
type master;
file "/etc/bind/db.10.80";  # 10.80.0.0/16 subnet
};
EOL

# db.idcneta.internal
cat <<EOL> /etc/bind/db.idcneta.internal
\$TTL 30
@ IN SOA idcneta.internal. root.idcneta.internal. (
2019122114 ; serial
3600       ; refresh
900        ; retry
604800     ; expire
86400      ; minimum ttl
)
; dns server
@      IN NS ns1.idcneta.internal.
; ip address of dns server
ns1    IN A  10.80.1.200
; Hosts
websrv   IN A  10.80.1.100
dnssrv   IN A  10.80.1.200
EOL
# db.10.80
cat <<EOL> /etc/bind/db.10.80
\$TTL 30
@ IN SOA idcneta.internal. root.idcneta.internal. (
2019122114 ; serial
3600       ; refresh
900        ; retry
604800     ; expire
86400      ; minimum ttl
)
; dns server
@      IN NS ns1.idcneta.internal.
; ip address of dns server
3      IN PTR  ns1.idcneta.internal.
; A Record list
100.1    IN PTR  websrv.idcneta.internal.
200.1    IN PTR  dnssrv.idcneta.internal.
EOL
# bind9 service start
systemctl daemon-reload
systemctl restart bind9 && systemctl enable bind9