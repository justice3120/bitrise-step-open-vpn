#!/bin/bash
set -eu

case "$OSTYPE" in
  linux*)
    echo "Configuring for Ubuntu"

    sudo apt-get install openvpn > /dev/null 2>&1

    echo ${ca_crt} | base64 -D -o /etc/openvpn/ca.crt > /dev/null 2>&1
    echo ${client_crt} | base64 -D -o /etc/openvpn/client.crt > /dev/null 2>&1
    echo ${client_key} | base64 -D -o /etc/openvpn/client.key > /dev/null 2>&1

    ls /etc/openvpn/

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

    service openvpn start /dev/null 2>&1
    sleep 5

    ifconfig -l
    if ifconfig -l | grep utun0 > /dev/null
    then
      echo "VPN connection succeeded"
    else
      echo "VPN connection failed!"
      exit 1
    fi
    ;;
  darwin*)
    echo "Configuring for Mac OS"

    brew install openvpn > /dev/null 2>&1

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
