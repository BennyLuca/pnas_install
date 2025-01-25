#!/bin/bash
#Versione 1.0
#   setup hostname
#   aggiornamto pi
#   formattazione e montaggio ssd
#   installazione filebrowser

echo PNAS INSTALL
echo
sleep 1

echo Change HOSTNAME to PNAS
sudo hostnamectl set-hostname pnas

cat << EOF > /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       pnas
EOF

sleep 1
####################################################################################################
echo
echo "1) ___________Update Raspberry___________"
echo
sudo apt update
sudo apt upgrade -y
sudo apt autoremove
sudo apt install ntfs-3g avahi-daemon -y
sleep 2
echo
echo "   _________Raspberry Aggiornato_________"
echo
####################################################################################################

read -r -p "Vuoi inizialiazzare l'SSD? [y/N]" -n 1

echo

if [[ "$REPLY" =~ ^[Yy]$ ]]; then

echo "2) ________________SSD INIT______________"

set -x

DEVICE="/dev/nvme0n1"

DISKID=$(blkid $DEVICE | cut -d' ' -f2 | cut -d\" -f2)

cat <<EOF | fdisk /dev/nvme0n1   #reads the disk utiliy
d

n   

p





w

EOF

echo

sleep 1

echo
echo "________ Format NTFS SSD ________"
echo

#sudo mkfs.ntfs /dev/nvme0n1

sleep 1

echo
echo "_________ Monto >L'SSD _________"
echo

sudo mkdir /SSD

sudo chmod 777 /SSD

sudo mount /dev/nvme0n1 /SSD

UUDI_SSD=$(sudo blkid | grep  "nvme0n1" | awk 'NR==1{print $3}' | tr --delete '"')
records="/etc/fstab"

add_book(){
    echo
    echo
    echo
    echo
    echo "${UUDI_SSD} /SSD ntfs defaults,auto,users,rw,nofail umask=777 0 0" >> "$records"  #this is my line 12
}

add_book

sudo systemctl daemon-reload

echo
echo "________________SSD INIT______________"
echo
fi
####################################################################################################


read -r -p "Vuoi installre Filebrowser? [y/N]" -n 1

echo
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
echo "3) _________Installo Filebrowser_________"

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash;

ip=$(hostname -I | tr --delete ' ')
cat << EOF > /etc/filebrowser.json
{
"port": 90,
"baseURL": "",
"address": "${ip}",
"log": "stdout",
"database": "/etc/filebrowser.db",
"root": "/SSD"
}
EOF

chmod 777 /etc/filebrowser.json

cat << EOF > /etc/systemd/system/filebrowser.service
[Unit]
Description=File Browser
After=network.target

[Service]
ExecStart=/usr/local/bin/filebrowser -c /etc/filebrowser.json

[Install]
WantedBy=multi-user.target
EOF



sudo systemctl enable filebrowser.service

sudo systemctl start filebrowser.service

sleep 10

sudo systemctl status filebrowser.service

sleep 3

echo
echo "________Filebrowser Installato________"
echo
fi
####################################################################################################


exit

