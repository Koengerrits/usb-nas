#!/bin/sh

echo "Mounting USB drives..."
mkdir -p /mnt/usb1 /mnt/usb2

# Zoek twee USB-sticks
USB_DEV1=$(lsblk -o NAME,MOUNTPOINT | grep -v "MOUNTPOINT" | grep -E "sd[b-z] " | awk '{print $1}' | head -n 1)
USB_DEV2=$(lsblk -o NAME,MOUNTPOINT | grep -v "MOUNTPOINT" | grep -E "sd[b-z] " | awk '{print $1}' | tail -n 1)

if [ -n "$USB_DEV1" ]; then
    mount /dev/$USB_DEV1 /mnt/usb1
    echo "USB drive 1 mounted at /mnt/usb1"
else
    echo "No USB drive 1 found!"
fi

if [ -n "$USB_DEV2" ] && [ "$USB_DEV1" != "$USB_DEV2" ]; then
    mount /dev/$USB_DEV2 /mnt/usb2
    echo "USB drive 2 mounted at /mnt/usb2"
else
    echo "No USB drive 2 found!"
fi

echo "Setting up Samba..."
mkdir -p /var/log/samba

# Samba-configuratie
cat <<EOF > /etc/samba/smb.conf
[global]
   workgroup = ${WORKGROUP}
   security = user
   map to guest = Bad User
   guest account = nobody
   log file = /var/log/samba/log.%m

[${SHARE_NAME1}]
   path = /mnt/usb1
   read only = no
   browsable = yes
   guest ok = no
   valid users = ${SAMBA_USERNAME}

[${SHARE_NAME2}]
   path = /mnt/usb2
   read only = no
   browsable = yes
   guest ok = no
   valid users = ${SAMBA_USERNAME}
EOF

# Maak Samba-gebruiker aan
(echo "${SAMBA_PASSWORD}"; echo "${SAMBA_PASSWORD}") | smbpasswd -s -a ${SAMBA_USERNAME}
smbpasswd -e ${SAMBA_USERNAME}

# Start Samba
smbd --foreground --no-process-group
