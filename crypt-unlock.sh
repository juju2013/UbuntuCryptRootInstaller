#!/bin/sh

PREREQ="dropbear"

prereqs() {
echo "$PREREQ"
}

case "$1" in
prereqs)
prereqs
exit 0
;;
esac

. "${CONFDIR}/initramfs.conf"
. /usr/share/initramfs-tools/hook-functions

if [ "${DROPBEAR}" != "n" ] && [ -r "/etc/crypttab" ] ; then
cat > "${DESTDIR}/bin/unlock" << 'EOF'
#!/bin/sh
if PATH=/lib/unlock:/bin:/sbin /scripts/local-top/cryptroot; then
  kill `ps | grep cryptroot | grep -v "grep" | awk '{print \$1}'`
	kill -9 `ps | grep "\-sh" | grep -v "grep" | awk '{print \$1}'`
exit 0
fi
exit 1
EOF

chmod 755 "${DESTDIR}/bin/unlock"

mkdir -p "${DESTDIR}/lib/unlock"
cat > "${DESTDIR}/lib/unlock/plymouth" << EOF
#!/bin/sh
[ "\$1" == "--ping" ] && exit 1
/bin/plymouth "\$@"
EOF

chmod 755 "${DESTDIR}/lib/unlock/plymouth"

echo "*****************************************" >> ${DESTDIR}/etc/motd
echo "*****************************************" >> ${DESTDIR}/etc/motd
echo To unlock root-partition run "unlock" >> ${DESTDIR}/etc/motd
echo "*****************************************" >> ${DESTDIR}/etc/motd
echo "*****************************************" >> ${DESTDIR}/etc/motd

fi

