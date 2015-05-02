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
cat > "${DESTDIR}/bin/unlock" << EOF
#!/bin/sh
if PATH=/lib/unlock:/bin:/sbin /scripts/local-top/cryptroot; then
  kill -TERM $(ps -o pid= -C cryptroot)
  kill -TERM $(ps -o pid= -C dropbear)
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

echo To unlock root-partition run "unlock" >> ${DESTDIR}/etc/motd

fi

