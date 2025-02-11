#!/bin/bash

# Display a header for the system report
echo "########################################################"
echo "###                      fio                         ###"
echo "########################################################"
echo ""
echo " System information as of $(date)"
echo ""

# System load
load=$(uptime | awk '{print $10}')
echo "  System load:             $load"

# Disk usage
disk_usage=$(df -h / | awk 'NR==2 {print $5}')
disk_total=$(df -h / | awk 'NR==2 {print $2}')
echo "  Usage of /:              $disk_usage of $disk_total"

# Memory usage
memory_usage=$(free -m | awk 'NR==2 {print $3*100/$2}')
echo "  Memory usage:            $memory_usage%"

# Swap usage
swap_usage=$(free -m | awk 'NR==3 {print $3*100/$2}')
echo "  Swap usage:              $swap_usage%"

# Processes count
process_count=$(ps aux | wc -l)
echo "  Processes:               $process_count"

# Number of logged-in users
users_logged=$(who | wc -l)
echo "  Users logged in:         $users_logged"

# Get the first active main network interface (eth, enp, etc.)
active_interface=$(ip link show | grep -E '^[0-9]+: (eth|enp)[^:]*' | awk '{print $2}' | sed 's/://')

if [ -z "$active_interface" ]; then
    echo "No active main network interface found"
    exit 1
fi
echo "Active network interface: $active_interface"

# Network information for IPv4
ipv4=$(ip -4 addr show "$active_interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -z "$ipv4" ]; then
    echo "  No IPv4 address found for $active_interface"
else
    echo "  IPv4 address for $active_interface: $ipv4"
fi

# Network information for IPv6
ipv6_addresses=$(ip -6 addr show "$active_interface" | grep -oP '(?<=inet6\s)[a-f0-9:]+')
if [ -z "$ipv6_addresses" ]; then
    echo "  No IPv6 address found for $active_interface"
else
    echo "$ipv6_addresses" | while read -r address; do
        echo "  IPv6 address for $active_interface: $address"
    done
fi

echo ""

# Last login information
last_login=$(last -n 1 | grep -v 'reboot' | head -n 1 | awk '{print $4, $5, $6, $7, $9}')
last_from=$(last -n 1 | grep -v 'reboot' | head -n 1 | awk '{print $3}')
echo "Last login: $last_login from $last_from"
