#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]; then
echo "[!] Please run as root"
exit 1
fi

if ! grep -qi fedora /etc/os-release; then
echo "[!] TorSurf currently supports Fedora only"
exit 1
fi

echo "[+] Installing TorSurf dependencies..."

dnf install -y 
tor 
nftables 
curl 
jq 
iproute 
procps-ng 
bind-utils

systemctl enable tor.service
systemctl enable nftables.service

echo
echo "[+] Installation complete"
echo "[+] Installed:"
echo "    - Tor"
echo "    - nftables"
echo "    - curl"
echo "    - jq"
echo "    - iproute"
echo "    - procps-ng"
echo "    - bind-utils"
echo
echo "[+] Ready for TorSurf"
