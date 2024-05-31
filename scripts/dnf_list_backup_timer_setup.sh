#!/bin/bash

# Define paths
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SERVICE_DIR="/etc/systemd/system"
BACKUP_PACKAGE_LIST_SCRIPT_SRC="$SCRIPT_DIR/backup_package_list"
BACKUP_PACKAGE_LIST_SCRIPT_DEST="/usr/local/bin/backup_package_list"

# Check if the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please enter your password."
   exec sudo "$0" "$@"
   exit 1
fi

# Copy the script to /usr/local/bin
sudo cp "$BACKUP_PACKAGE_LIST_SCRIPT_SRC" "$BACKUP_PACKAGE_LIST_SCRIPT_DEST"

# Set executable permissions
sudo chmod +x "$BACKUP_PACKAGE_LIST_SCRIPT_DEST"

# Set SELinux context
sudo semanage fcontext -a -t bin_t "$BACKUP_PACKAGE_LIST_SCRIPT_DEST"
sudo restorecon -v "$BACKUP_PACKAGE_LIST_SCRIPT_DEST"

# Get the hostname and confirm with the user
hostname=$(hostname -s)
read -p "Detected hostname is '$hostname'. Do you want to use this? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    read -p "Enter the desired hostname: " hostname
fi

# Update the backup_package_list script with the correct hostname
sudo sed -i "s/myhost/$hostname/g" "$BACKUP_PACKAGE_LIST_SCRIPT_DEST"

# Create service file
echo "Creating service file..."
cat <<EOL | sudo tee $SERVICE_DIR/backup_package_list.service
[Unit]
Description=Backup Installed Package List

[Service]
Type=oneshot
ExecStart=$BACKUP_PACKAGE_LIST_SCRIPT_DEST

[Install]
WantedBy=multi-user.target
EOL

# Create timer file
echo "Creating timer file..."
cat <<EOL | sudo tee $SERVICE_DIR/backup_package_list.timer
[Unit]
Description=Run Backup Package List Script Daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOL

# Reload systemd and enable the timer
echo "Reloading systemd daemon and enabling timer..."
sudo systemctl daemon-reload
sudo systemctl enable backup_package_list.timer
sudo systemctl start backup_package_list.timer

systemctl list-timers --all
systemctl status backup_package_list.timer

echo "Setup complete. Backup Package List service and timer are now active."
