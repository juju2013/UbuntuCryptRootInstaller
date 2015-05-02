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
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -qN ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -qN ''
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -qN ''
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -qN ''

k1=`ssh-keygen -lqf /etc/ssh/ssh_host_dsa_key.pub`
k2=`ssh-keygen -lqf /etc/ssh/ssh_host_rsa_key.pub`
k3=`ssh-keygen -lqf /etc/ssh/ssh_host_ecdsa_key.pub`
k4=`ssh-keygen -lqf /etc/ssh/ssh_host_ed25519_key.pub`
cat << EOF
*****************************************************************************
***** Please note down the new installed ssh host keys :
        DSA key : $k1
        RSA key : $k2
      ECDSA key : $k3
    ED25519 key : $k4

You should add them to your ssh's known_hosts file later
EOF
read -p "presse ENTER to continue" ff
chown -R 0:0 /root

