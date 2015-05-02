#! /bin/bash

. /vars.sh

cat << EOF
******************************************************************************
*** ATTENTION : this will erase ALL CONTENTS on ${DISK}
*** ARE YOU SUR ???
******************************************************************************
EOF
select rep in "YES" "NO" ; do 
	case $rep in
		YES ) break;;
		NO ) exit 0 ;;
	esac
done

echo "Formating disk ${DISK}"
parted -s ${DISK} mklabel msdos
parted -- ${DISK} unit MB mkpart primary ext2 2 200
parted -- ${DISK} unit MB mkpart primary linux-swap 200 2048
parted -- ${DISK} unit MB mkpart primary 2048 -0
dd if=/dev/zero of=${DISK}3 bs=1M count=10
cat << EOF
******************************************************************************
Too late now... new partition created !
We're going to FORMAT and CRYPT your root partition on ${DISK} 
Please keep your passphase SAFE, lose it and you'll lose all your data!
******************************************************************************
EOF
cryptsetup luksFormat ${DISK}3

cryptsetup open ${DISK}3 ${CRYPTROOT}

mkfs.btrfs  /dev/mapper/${CRYPTROOT}
mkfs.ext2 ${DISK}1
mount /dev/mapper/${CRYPTROOT} /mnt
btrfs sub create ${CHROOT}/home
btrfs sub create ${CHROOT}/root

mount -o subvol=root /dev/mapper/${CRYPTROOT} ${CHROOT}
mkdir -p ${CHROOT}/home
mount -o subvol=home /dev/mapper/${CRYPTROOT} ${CHROOT}/home

echo "***** now installing ubuntu, go get a tea now *****"
debootstrap trusty ${CHROOT} http://fr.archive.ubuntu.com/ubuntu
mount --bind /dev ${CHROOT}/dev
mount --bind /dev/pts ${CHROOT}/dev/pts
mount -t proc proc ${CHROOT}/proc
mount -t sysfs sys ${CHROOT}/sys
mkdir -p ${CHROOT}/boot
mount ${DISK}1 ${CHROOT}/boot

echo "Copying host keys"
mkdir -p ${CHROOT}/etc/ssh
mkdir -p ${CHROOT}/etc/initramfs-tools/etc/ssh
cp /etc/ssh/ssh_host* ${CHROOT}/etc/ssh/
cp /etc/ssh/ssh_host* ${CHROOT}/etc/initramfs-tools/etc/ssh

echo "Downloading next stage script"
wget raw.githubusercontent.com/${REPO}/install-stage2.sh -O install-stage2.sh
chmod +x install-stage2.sh
cp install-stage2.sh ${CHROOT}/

echo "Going to chroot now..."
BLKID1=`blkid | grep ${DISK}1 | cut -d " " -f 2| cut -d \" -f 2`
BLKID3=`blkid | grep ${DISK}3 | cut -d " " -f 2| cut -d \" -f 2`
BLKIDROOT=`blkid | grep ${CRYPTROOT} | cut -d " " -f 2| cut -d \" -f 2`
cp /vars.sh ${CHROOT}/
cat >> ${CHROOT}/vars.sh << EOF
export BLKID1=${BLKID1}
export BLKID3=${BLKID3}
export BLKIDROOT=${BLKIDROOT}
EOF

cp *.authorized_keys ${CHROOT}/tmp/
chroot ${CHROOT} /bin/bash -c /install-stage2.sh

