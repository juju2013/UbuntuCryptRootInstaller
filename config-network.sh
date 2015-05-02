#! /bin/bash


. /vars.sh
cat << EOF
*****************************************************************************
OK, let's configure target network now
EOF

read -p "What'll be your IP address? " IP
read -p "                IP mask   ? " MASK
read -p "                default GW? " GW
read -p "                DNS server? " DNS
read -p "                hostname  ? " HOST

cat > /etc/network/interfaces <<EOF
auto eth0
  iface eth0 inet static
  address $IP
  netmask $MASK
  gateway $GW
EOF

#osl=`dd if=/dev/urandom bs=1K count=1 2>/dev/null| sha1sum | cut -d ' ' -f 1`
#HOST=${osl:3:8}
echo $HOST > /etc/hostname
echo "127.0.0.1		localhost ${HOST}" >> /etc/hosts
echo "New hostname is ${HOST}"

echo "***** Now preparing boot"
cat /etc/default/grub |sed -e 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=""/' > /etc/default/grub

cat /tmp/*.authorized_keys > /etc/initramfs-tools/root/.ssh/authorized_keys

inf=/etc/initramfs-tools/initramfs.conf
echo "IP=${IP}::${GW}:${MASK}::eth0:off" >> $inf
ing=/usr/share/initramfs-tools/scripts/init-bottom/dropbear
echo "ifconfig eth0 0.0.0.0 down" >> $ing

update-initramfs -u -k all


