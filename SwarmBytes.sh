#!/bin/bash

# Update package lists and install required packages
sudo apt update && sudo apt install pppoeconf iproute2 -y

# Display detected primary interfaces
echo "Detected Primary Interfaces: "
ls /sys/class/net | grep -v lo

# Read the physical interface from user
read -p "Enter the physical interface name: " physical_interface

# Set physical interface up
sudo ip link set "$physical_interface" up

# Read the number of PPPoE connections from user
read -p "Enter the number of PPPoE connections you want to create: " num_pppoe

# Read username from user
read -p "Enter your username: " username

# Read password from user (password won't be displayed)
read -s -p "Enter your password: " password
echo
# Read API key from user
read -p "Enter your SwarmBytes API key: " api_key
# Set credentials in pap-secrets
sudo sh -c "echo '\"$username\" * \"$password\"' > /etc/ppp/pap-secrets"

# Set file permissions for pap-secrets
sudo chmod 600 /etc/ppp/pap-secrets

# Create macvlan interfaces, set them up, and start PPPoE connections
for i in $(seq 1 $num_pppoe); do
    sudo ip link add link "$physical_interface" macvlan$i type macvlan mode bridge
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
done

# Generate a list of IP addresses
ip_array=()
for ((i=1; i<=$num_pppoe; i++)); do
    ip=$(ip -4 addr show pppoe$i | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    if [ -n "$ip" ]; then
        ip_array+=("$ip")
    fi
done

# Define the folder path
folder_path="/etc/swarmbytes"

# Create the folder if it doesn't exist
mkdir -p "$folder_path"

# Define the file path
file_path="$folder_path/config.yaml"

# Write the YAML content to the file
echo "api_key: \"$api_key\"
bind_ips:" > "$file_path"

for ip in "${ip_array[@]}"; do
    echo "  - $ip" >> "$file_path"
done

echo "
http_port: 8000
child_spawn_delay: 1000" >> "$file_path"

echo "File created successfully at $file_path"

# Set DNS server to Google DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
