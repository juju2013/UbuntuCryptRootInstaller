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
