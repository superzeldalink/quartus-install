#!/bin/sh

QUARTUS_ROOTDIR=$1

sed -i "s/export QUARTUS_BIT_TYPE=32/export QUARTUS_BIT_TYPE=64/g" $QUARTUS_ROOTDIR/quartus/adm/qenv.sh

sed -i "s|grep sse /proc/cpuinfo|true|g" $QUARTUS_ROOTDIR/quartus/adm/qenv.sh

echo "export PATH=\"\$PATH:$QUARTUS_ROOTDIR/quartus/bin/:$QUARTUS_ROOTDIR/questa_fse/bin/\"" >> /home/$SUDO_USER/.bashrc