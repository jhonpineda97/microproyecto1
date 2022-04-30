#!/bin/bash

#sudo apt-get update
#sudo apt-get upgrade
sudo apt-get install -y net-tools
sudo snap remove lxd
sudo snap install lxd --channel=4.0/stable
sleep 60

echo '' > /home/vagrant/web1.yml
echo 'config: {}
networks: []
storage_pools: []
profiles: []
cluster:
  server_name: web1
  enabled: true
  member_config:
  - entity: storage-pool
    name: local
    key: source
    value: ""
    description: '"source" property for storage pool "local"'
  cluster_address: 192.168.100.2:8443
  server_address: 192.168.100.3:8443
  cluster_password: "vagrant"
  cluster_certificate_path: ""
  cluster_token: ""
  cluster_certificate: "-----BEGIN CERTIFICATE-----

' > /home/vagrant/web1.yml
newgrp lxd
sleep 15

cp /home/vagrant/cluster.crt /home/vagrant/cluster_temp.crt
sed -i '1d' /home/vagrant/cluster_temp.crt
sed ':a;N;$!ba;s/\n/\n\n/g' /home/vagrant/cluster_temp.crt >> /home/vagrant/web1.yml
echo '"' >> /home/vagrant/web1.yml

sudo cat /home/vagrant/web1.yml | lxd init --preseed &>/dev/null
sleep 120

sudo lxc launch ubuntu:18.04 contenedor1 &>/dev/null
sleep 120

sudo lxc exec contenedor1 -- sudo apt update && apt upgrade
sleep 10

sudo lxc exec contenedor1 -- apt-get install -y net-tools
sleep 10

sudo lxc exec contenedor1 -- sudo apt install -y apache2
sleep 10

sudo lxc exec contenedor1 -- sudo systemctl enable apache2
sleep 20

sudo lxc exec contenedor1 -- sh -c "echo 'Hello from web1' > /var/www/html/index.html"
sleep 10

sudo lxc exec contenedor1 -- sudo systemctl start apache2
sleep 10

#lxc config device set web1 eth0 ipv4.address 240.3.0.123