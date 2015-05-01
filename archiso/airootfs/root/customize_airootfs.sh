#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

systemctl enable pacman-init.service choose-mirror.service
systemctl set-default multi-user.target

mkdir -p /etc/ssh
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

dsakey=`ssh-keygen -lf /etc/ssh/ssh_host_dsa_key.pub`
rsakey=`ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub`
cat << EOF
*****************************************************************************
***** Please note down the new installed ssh host keys :
        DSA key : $dsakey
        RSA key : $rsakey

You should add them to your ssh's known_hosts file later
EOF
read -p "presse ENTER to continue" ff

