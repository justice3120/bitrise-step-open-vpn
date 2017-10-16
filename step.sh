#!/bin/bash
set -eu

RETRY_COUNT=5
RETRY_INTERVAL=1

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

    set +e
    COUNT=0
    while true; do
      if ifconfig -l | grep utun0 > /dev/null; then
        break
      fi
      if [ $COUNT -eq $RETRY_COUNT ]; then
        echo "VPN connection failed!"
        exit 1
      fi
      COUNT=`expr $COUNT + 1`
      sleep $RETRY_INTERVAL
    done
    set -e

    ;;
  *)
    echo "Unknown operative system: $OSTYPE, exiting"
    exit 1
    ;;
esac
