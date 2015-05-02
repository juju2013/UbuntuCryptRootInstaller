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

echo "Downloading next stage script"
wget raw.githubusercontent.com/${REPO}/install-stage2.sh -O install-stage2.sh
cp install-stage2.sh ${CHROOT}/

echo "Going to chroot now..."
chroot ${CHROOT} /bin/bash /install-stage2.sh

