#!/bin/bash

# Update package lists and install required packages
sudo apt update && sudo apt install pppoeconf iproute2 -y

# Set physical interface ens19 up
sudo ip link set ens19 up

# Read the number of PPPoE connections from user
read -p "Enter the number of PPPoE connections you want to create: " num_pppoe

# Read username from user
read -p "Enter your username: " username

# Read password from user (password won't be displayed)
read -s -p "Enter your password: " password
echo

# Set credentials in pap-secrets
sudo sh -c "echo '\"$username\" * \"$password\"' > /etc/ppp/pap-secrets"

# Set file permissions for pap-secrets
sudo chmod 600 /etc/ppp/pap-secrets

# Create macvlan interfaces, set them up, and start PPPoE connections
for i in $(seq 1 $num_pppoe); do
    sudo ip link add link eth1 macvlan$i type macvlan mode bridge
    sudo ip link set macvlan$i up

    # Create PPPoE configuration file and set credentials
    sudo sh -c "echo '
hide-password
lcp-echo-interval 20
lcp-echo-failure 3
connect /bin/true
noauth
persist
mtu 1500
ifname pppoe$i
noaccomp
default-asyncmap
plugin rp-pppoe.so macvlan$i
user \"$username\"
+ipv6
updetach
maxfail 2
' > /etc/ppp/peers/macvlan$i"

    # Start PPPoE connection
    sudo pon macvlan$i

    # Add default route for PPPoE connection
    sudo ip route add default dev pppoe$i metric $((100+$i))

    # Get IPv4 address of pppoe interface
    echo "pppoe$i: $(ip -4 addr show pppoe$i | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
done

# Set DNS server to Google DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
