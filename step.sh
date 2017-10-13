#!/bin/bash
set -ex

case "$OSTYPE" in
  linux*)
    ;;
  darwin*)
    echo "Configuring for Mac OS"

    brew install openvpn

    echo ${ca_crt} | base64 -D -o ca.crt
    echo ${client_crt} | base64 -D -o client.crt
    echo ${client_key} | base64 -D -o client.key

    sudo openvpn --client --dev tun --proto udp --remote ${host} 1194 --resolv-retry infinite --nobind --persist-key --persist-tun --comp-lzo --verb 3 --ca ca.crt --cert client.crt --key client.key &
    sleep 5

    ;;
  *)
    echo "Unknown operative system: $OSTYPE, exiting"
    exit 1
    ;;
esac
