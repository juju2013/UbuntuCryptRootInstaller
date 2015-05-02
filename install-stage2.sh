#! /bin/bash

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PS1='chroot > '

echo "Inside the chroot now."
. /vars.sh
cat << EOF
******************************************************************************
*** Change the root password now
******************************************************************************
EOF
passwd

cp /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo 'LANG="en_US.UTF-8"' >  /etc/default/locale
echo 'Europe/Paris' > /etc/timezone
locale-gen en_US.UTF-8
dpkg-reconfigure -f non-interactive tzdata


echo "${CRYPTROOT}	UUID=${BLKID3}	none	luks" > /etc/crypttab

cat > /etc/fstab <<EOF
/dev/mapper/${CRYPTROOT}	/	btrfs	defaults,subvol=root	0	1
/dev/mapper/${CRYPTROOT}	/home	btrfs	defaults,subvol=home	0	1
UUID=${BLKID1}			/boot	ext2	defaults		0	1
EOF


echo "deb http://fr.archive.ubuntu.com/ubuntu trusty main universe multiverse restricted" > /etc/apt/sources.list
apt-get update
apt-get upgrade
apt-get install -y --force-yes cryptsetup openssh-server btrfs-tools grub2 linux-image-3.13.0-24-generic tmux htop openntpd docker.io dropbear
dpkg-reconfigure openssh-server dropbear
echo 'DOCKER_OPTS="-G docker"' >> /etc/default/docker

groupadd docker

echo "Creating target power users"
for fname in /tmp/*.authorized_keys; do
	bname=${fname##*/};
	uname=${bname%.*};
	useradd -m $uname;
	gpasswd -a $uname sudo;
	gpasswd -a $uname docker;
	mkdir -p /home/$uname/.ssh/;
	cat /tmp/${uname}.authorized_keys > /home/$uname/.ssh/authorized_keys;
	chmod 0755 /home/$uname/.ssh;
	chmod 0444 /home/$uname/.ssh/*;
	chown -R $uname:$uname /home/$uname;
	echo "set new password for ${uname} now."; passwd $uname
done;

cat << EOF
*****************************************************************************
OK, let's do some network configuration now
EOF

read -p "What'll be your IP address? " IP
read -p "                IP mask   ? " MASK
read -p "                default GW? " GW
read -p "                DNS server? " DNS

cat > /etc/network/interfaces <<EOF
auto eth0
  iface eth0 inet static
  address $IP
  netmask $MASK
  gateway $GW
EOF

osl=`dd if=/dev/urandom bs=1K count=1 2>/dev/null| sha1sum | cut -d ' ' -f 1`
HOST=${osl:3:8}
echo $HOST > /etc/hostname
echo "127.0.0.1		localhost ${HOST}" >> /etc/hosts

echo "NO_START=0" >> /etc/default/dropbear

echo "***** Now preparing boot"
cat /etc/default/grub |sed -e 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=""/' > /etc/default/grub

cat /tmp/*.authorized_keys > /etc/initramfs-tools/root/.ssh/authorized_keys

mkdir -p /etc/initramfs-tools/hooks/
wget raw.githubusercontent.com/${REPO}/crypt_unlock.sh -O /etc/initramfs-tools/hooks/crypt_unlock.sh
chmod +x /etc/initramfs-tools/hooks/crypt_unlock.sh

echo "IP=${IP}::${GW}:${MASK}::eth0:off" >> /etc/initramfs-tools/initramfs.conf
echo "ifconfig eth0 0.0.0.0" >> /usr/share/initramfs-tools/scripts/init-bottom/dropbear
/usr/lib/dropbear/dropbearconvert openssh dropbear /etc/ssh/ssh_host_rsa_key /etc/dropbear/dropbear_rsa_host_key
/usr/lib/dropbear/dropbearconvert openssh dropbear /etc/ssh/ssh_host_dsa_key /etc/dropbear/dropbear_dss_host_key
cp /etc/dropbear/*key /etc/initramfs-tools/etc/dropbear/


update-initramfs -u -v -k all
update-grub2 ${DISK}

echo "Post clean up ..."
cat /etc/default/dropbear | sed 's/NO_START=.*/NO_START=1/' > /etc/default/dropbear
update-rc.d -f dropbear remove

cat <<EOF
*****************************************************************************
*****************************************************************************
IT'S FINISHED !
You can remove the CD and reboot now
*****************************************************************************
*****************************************************************************
EOF

