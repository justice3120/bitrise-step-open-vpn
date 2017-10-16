#!/bin/bash
set -eux

case "$OSTYPE" in
  linux*)
    echo "Configuring for Ubuntu"

    echo ${ca_crt} | base64 -d > /etc/openvpn/ca.crt
    echo ${client_crt} | base64 -d > /etc/openvpn/client.crt
    echo ${client_key} | base64 -d > /etc/openvpn/client.key

    cat <<EOF > /etc/openvpn/client.conf
client
dev tun
proto udp
remote ${host} 1194
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
ca ca.crt
cert client.crt
key client.key
EOF

    ls -l /etc/openvpn

    service openvpn start client
    sleep 10

    ifconfig
    if ifconfig | grep utun0 > /dev/null
    then
      echo "VPN connection succeeded"
    else
      echo "VPN connection failed!"
      exit 1
    fi
    ;;
  darwin*)
    echo "Configuring for Mac OS"

    echo ${ca_crt} | base64 -D -o ca.crt > /dev/null 2>&1
    echo ${client_crt} | base64 -D -o client.crt > /dev/null 2>&1
    echo ${client_key} | base64 -D -o client.key > /dev/null 2>&1

    sudo openvpn --client --dev tun --proto udp --remote ${host} 1194 --resolv-retry infinite --nobind --persist-key --persist-tun --comp-lzo --verb 3 --ca ca.crt --cert client.crt --key client.key > /dev/null 2>&1 &

    sleep 5

    if ifconfig -l | grep utun0 > /dev/null
    then
      echo "VPN connection succeeded"
    else
      echo "VPN connection failed!"
      exit 1
    fi
    ;;
  *)
    echo "Unknown operative system: $OSTYPE, exiting"
    exit 1
    ;;
esac
