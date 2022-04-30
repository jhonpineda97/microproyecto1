#!/bin/bash

#sudo apt-get update
#sudo apt-get upgrade
#sed -i 's/\r$//' filename
sudo apt-get install -y net-tools
sleep 10
sudo snap remove lxd
sudo snap install lxd --channel=4.0/stable
sleep 60

echo '' > /home/vagrant/principal.yml &>/dev/null
echo 'config:
  core.https_address: 192.168.100.2:8443
  core.trust_password: vagrant
networks:
- config:
    bridge.mode: fan
    fan.underlay_subnet: 192.168.100.0/24
  description: ""
  name: lxdfan0
  type: ""
storage_pools:
- config: {}
  description: ""
  name: local
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdfan0
      type: nic
    root:
      path: /
      pool: local
      type: disk
  name: default
cluster:
  server_name: principal
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""
  cluster_certificate_path: ""
  cluster_token: ""' > /home/vagrant/principal.yml
newgrp lxd
sleep 15

sudo cat /home/vagrant/principal.yml | lxd init --preseed &>/dev/null
sleep 120

cp /var/snap/lxd/common/lxd/cluster.crt /home/vagrant/
sleep 5

sudo lxc launch ubuntu:18.04 haproxy &>/dev/null
sleep 120

sudo lxc exec haproxy -- sudo apt update && apt upgrade
sleep 10

sudo lxc exec haproxy -- sudo apt-get install -y net-tools
sleep 10

sudo lxc exec haproxy -- sudo apt install -y haproxy
sleep 10

sudo lxc exec haproxy -- sudo systemctl enable haproxy
sleep 10