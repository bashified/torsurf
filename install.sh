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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "[+] Installing core platform packages..."
dnf install -y tor nftables curl jq iproute procps-ng bind-utils bc

echo "[+] Injecting transparent routing layers to /etc/tor/torrc..."
if ! grep -q "TransPort 9040" /etc/tor/torrc; then
    cat <<EOF >> /etc/tor/torrc

# TorSurf Configuration
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 5353
EOF
fi

echo "[+] Registering binaries to global system path (/usr/local/bin/)..."
cp "$SCRIPT_DIR/utils/torsurf-core" /usr/local/bin/torsurf-core
cp "$SCRIPT_DIR/torsurf" /usr/local/bin/torsurf

chmod +x /usr/local/bin/torsurf-core
chmod +x /usr/local/bin/torsurf

echo "[+] Preparing network interface hooks..."
systemctl enable tor.service
systemctl enable nftables.service

echo -e "\n[+] Installation Complete!"
echo "You can now open any terminal window and simply type: torsurf"