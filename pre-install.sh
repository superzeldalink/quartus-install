#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with sudo or as root."
  exit 1
fi

# Check if the system is Debian or Ubuntu
if ! (cat /etc/os-release | grep -E -q 'ID=(debian|ubuntu)'); then
  echo "This script is intended for Debian and Ubuntu systems only."
  exit 1
fi

# Check if macOS version is greater than or equal to 13
if [ $# -ne 1 ] || [ "$1" -lt 13 ]; then
  echo "Usage: $0 <macOS_version (>=13)>"
  exit 1
fi

macOS_version="$1"

# Rest of the script (same as before)
preserve_option="yes"

if [ "$macOS_version" -eq 13 ]; then
  preserve_option="no"
fi

# Install packages
apt install -y spice-vdagent binfmt-support git aria2

# Mount rosetta binary
mount -t virtiofs rosetta /media/rosetta

# Update binfmts
/usr/sbin/update-binfmts --install rosetta /media/rosetta/rosetta --magic "\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00" --mask "\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff" --credentials yes --preserve "$preserve_option" --fix-binary yes

# Add lines to /etc/fstab
echo "rosetta /media/rosetta virtiofs ro,nofail 0 0" >> /etc/fstab
echo "share /media/share virtiofs rw,nofail 0 0" >> /etc/fstab

# Add architecture and update
dpkg --add-architecture amd64
apt update

# Install libc6:amd64
apt install -y libc6:amd64

# Display completion message
echo "Script completed. Please restart the VM for changes to take effect."
