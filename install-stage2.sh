#! /bin/bash

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PS1='chroot > '

echo "Inside the chroot now."
. /vars.sh

cp /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo 'LANG="en_US.UTF-8"' >  /etc/default/locale
echo 'Europe/Paris' > /etc/timezone
locale-gen en_US.UTF-8
dpkg-reconfigure -f non-interactive tzdata


BLKID3=`blkid | grep ${DISK}3 | cut -d " " -f 2`
echo "${CRYPTROOT}	${BLKID3}	none	luks" > /etc/crypttab

BLKID1=`blkid | grep ${DISK}1 | cut -d " " -f 2`
cat > /etc/fstab <<EOF
/dev/mapper/${CRYPTROOT}	/	btrfs	defaults,subvol=root	0	1
/dev/mapper/${CRYPTROOT}	/home	btrfs	defaults,subvol=home	0	1
${BLKID1}			/boot	ext2	defaults		0	1
EOF


echo "deb http://fr.archive.ubuntu.com/ubuntu trusty main universe multiverse restricted" > /etc/apt/sources.list
apt-get update
apt-get upgrade
apt-get install cryptsetup openssh-server btrfs-tools grub2 language-pack-en-base linux-image-3.13.0-24-generic tmux htop openntpd docker.io
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
done;


