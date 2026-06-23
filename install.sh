#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run as root (sudo ./install.sh)"
    exit 1
fi

if ! grep -qi fedora /etc/os-release; then
    echo "[!] TorSurf currently supports Fedora only"
    exit 1
fi

echo "[+] Installing core system dependencies..."
dnf install -y tor nftables curl jq iproute procps-ng bind-utils python3 python3-pip

echo "[+] Installing UI dependencies..."
pip3 install rich asciichartpy requests

echo "[+] Configuring Tor daemon for transparent routing..."
# Ensure TransPort and DNSPort configurations are in torrc if not present
if ! grep -q "TransPort 9040" /etc/tor/torrc; then
    cat <<EOF >> /etc/tor/torrc

# TorSurf Configuration
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 5353
EOF
fi

echo "[+] Deploying system binaries..."
cp torsurf-core /usr/local/bin/torsurf-core
cp torsurf /usr/local/bin/torsurf

chmod +x /usr/local/bin/torsurf-core
chmod +x /usr/local/bin/torsurf

echo "[+] Enabling services..."
systemctl enable tor.service
systemctl enable nftables.service

echo -e "\n[+] TorSurf installed successfully! Run 'torsurf start' as a normal user."