#!/bin/bash

# Download Swarmbytes package
wget -O swarmbytes_1.16.0_amd64.deb https://cdn.discordapp.com/attachments/1109741145807925281/1116193648359505940/swarmbytes_1.16.0_amd64.deb

# Install Swarmbytes package
dpkg -i swarmbytes_1.16.0_amd64.deb

# Set ulimit
ulimit -n 65535

# Read the number of PPPoE connections from user
read -p "Enter the number of PPPoE connections you want to create: " num_pppoe

# Generate a list of IP addresses
ip_array=()
for ((i=1; i<=$num_pppoe; i++)); do
    sudo ip route add default dev pppoe$i metric $((100+$i))
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

# Delete the config file if it exists
if [ -f "$file_path" ]; then
    sudo rm "$file_path"
fi

# Write the YAML content to the file
echo "api_key: \"084cb71691b275b06a30c18ac0c9426849294ffe\"
bind_ips:" > "$file_path"

for ip in "${ip_array[@]}"; do
    echo "  - $ip" >> "$file_path"
done

echo "
http_port: 8000
child_spawn_delay: 1000" >> "$file_path"

echo "File created successfully at $file_path"

# Set DNS server to Google DNS
#echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Run swarmbytes command
swarmbytes

# Remove Swarmbytes package
rm swarmbytes_1.16.0_amd64.deb

echo "Swarmbytes installation and execution completed successfully."
