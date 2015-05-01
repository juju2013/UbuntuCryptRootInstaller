#! /bin/bash

. /vars.sh

cat << EOF
******************************************************************************
*** Good day, welcome to the ubuntu trusty server install CD
      Before all: I'll give you a chance to choose your keyboard layout
******************************************************************************
EOF
read -p "please entry the 2 letters country code for your keyboard: " kbd
loadkeys $kbd
read -p "your keyboard layout is $kbd now, you can test and presse enter to continue:" zz

echo "You should now change you root password."
passwd

echo ""
echo "Brinking up network"
dhclient eth0
systemctl restart sshd.service


IP=`ip -4 a show dev eth0 | grep inet | cut -d " " -f 6 `
cat << EOF
******************************************************************************
install summary : 
 Disk to install : ${DISK}
 installer IP : ${IP}

if OK, please do ssh root@${IP}, then lauch /root/setup1.sh
if not, please change /vars.sh and/or correct error manually

I\'ll giving you a console shell any way ...
EOF

echo "Downloading install script ..."
wget raw.githubusercontent.com/${REPO}/install-stage1.sh
/bin/bash

echo "You can now ssh root@your_host and launch ./install-stage1.sh"

