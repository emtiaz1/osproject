#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Update package repository and install dnsmasq
echo "Updating package repository and installing dnsmasq..."
apt-get update -y && apt-get install dnsmasq -y

# Backup the existing dnsmasq configuration
DNSMASQ_CONF="/etc/dnsmasq.conf"
BACKUP_CONF="/etc/dnsmasq.conf.bak"

if [ -f "$DNSMASQ_CONF" ]; then
  echo "Backing up existing dnsmasq configuration..."
  cp $DNSMASQ_CONF $BACKUP_CONF
fi

# Create a new dnsmasq configuration
echo "Creating a new dnsmasq configuration..."
cat > $DNSMASQ_CONF <<EOF
# DNS server configuration
no-resolv
server=8.8.8.8   # Google Public DNS
server=1.1.1.1   # Cloudflare DNS
listen-address=127.0.0.1
bind-interfaces
log-queries
log-facility=/var/log/dnsmasq.log
EOF

# Restart dnsmasq to apply changes
echo "Restarting dnsmasq service..."
systemctl restart dnsmasq

# Enable dnsmasq to start on boot
echo "Enabling dnsmasq to start on boot..."
systemctl enable dnsmasq

# Check if dnsmasq is running
if systemctl is-active --quiet dnsmasq; then
  echo "DNS server is running successfully!"
else
  echo "Failed to start the DNS server. Check logs for details."
  exit 1
fi

echo "Setup complete. You can test the DNS server by setting 127.0.0.1 as your DNS resolver."

