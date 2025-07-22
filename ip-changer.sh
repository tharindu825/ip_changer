#!/bin/bash

[[ "$UID" -ne 0 ]] && {
    echo "Script must be run as root."
    exit 1
}

install_packages() {
    local distro
    distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    distro=${distro//\"/}
    
    case "$distro" in
        *"Ubuntu"* | *"Debian"*)
            apt-get update
            apt-get install -y curl tor tor-geoipdb
            ;;
        *"Fedora"* | *"CentOS"* | *"Red Hat"* | *"Amazon Linux"*)
            yum update
            yum install -y curl tor
            ;;
        *"Arch"*)
            pacman -S --noconfirm curl tor
            ;;
        *)
            echo "Unsupported distribution: $distro. Please install curl and tor manually."
            exit 1
            ;;
    esac
}

if ! command -v curl &> /dev/null || ! command -v tor &> /dev/null; then
    echo "Installing curl and tor"
    install_packages
fi

if ! systemctl --quiet is-active tor.service; then
    echo "Starting tor service"
    systemctl start tor.service
fi

# Configure Tor as a transparent proxy
configure_transparent_proxy() {
    echo "Configuring Tor as a transparent proxy"
    echo "TransPort 9040" >> /etc/tor/torrc
    echo "VirtualAddrNetworkIPv4 10.192.0.0/10" >> /etc/tor/torrc
    echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
    echo "DNSPort 53" >> /etc/tor/torrc

    # Set up iptables rules
    iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 53 -j REDIRECT --to-ports 53
    iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 53
    iptables -t nat -A PREROUTING -i eth0 -p tcp --syn -j REDIRECT --to-ports 9040

    # Save iptables rules (adjust for your system, e.g., use 'iptables-persistent' on Debian)
    if command -v iptables-save &> /dev/null; then
        iptables-save > /etc/iptables/rules.v4
    fi

    systemctl restart tor.service
}

# Check if transparent proxy is configured, configure if not
if ! grep -q "TransPort 9040" /etc/tor/torrc; then
    configure_transparent_proxy
fi

get_ip() {
    local url get_ip ip
    url="https://checkip.amazonaws.com"
    get_ip=$(curl -s -x socks5h://127.0.0.1:9050 "$url")
    ip=$(echo "$get_ip" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
    echo "$ip"
}

change_ip() {
    echo "Reloading tor service"
    systemctl reload tor.service
    sleep 2  # Wait for new circuit
    echo -e "\033[34mNew IP address: $(get_ip)\033[0m"
}

clear
cat << EOF
  ___ ____        ____ _   _    _    _   _  ____ _____ ____
 |_ _|  _ \      / ___| | | |  / \  | \ | |/ ___| ____|  _ \
  | || |_) |____| |   | |_| | / _ \ |  \| | |  _|  _| | |_) |
  | ||  __/_____| |___|  _  |/ ___ \| |\  | |_| | |___|  _ <
 |___|_|         \____|_| |_/_/   \_\_| \_|\____|_____|_| \_\

EOF

echo "Note: For browser anonymity, use the Tor Browser or configure your browser to use 127.0.0.1:9050 as a SOCKS5 proxy."
echo "To disable leaks, disable WebRTC (e.g., in Firefox: about:config, set media.peerconnection.enabled to false)."

while true; do
    read -rp $'\033[34mEnter time interval in seconds (type 0 for infinite IP changes): \033[0m' interval
    read -rp $'\033[34mEnter number of times to change IP address (type 0 for infinite IP changes): \033[0m' times

    if [ "$interval" -eq "0" ] || [ "$times" -eq "0" ]; then
        echo "Starting infinite IP changes"
        while true; do
            change_ip
            interval=$(shuf -i 30-60 -n 1)  # Increased interval to reduce network strain
            sleep "$interval"
        done
    else
        for ((i=0; i<times; i++)); do
            change_ip
            sleep "$interval"
        done
    fi
done
