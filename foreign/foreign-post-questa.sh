#!/bin/sh

QUARTUS_ROOTDIR=$1

echo "export LM_LICENSE_FILE=$QUARTUS_ROOTDIR/questa_fse/license.dat" >> /home/$SUDO_USER/.bashrc

sed -i "s/\$dir\/linux_\$umach\/vsim/\$dir\/linux_x86_64\/vsim/g" $QUARTUS_ROOTDIR/questa_fse/vco
sed -i "s/vco=\"linux_\$umach\"/vco=\"linux_x86_64\"/g" $QUARTUS_ROOTDIR/questa_fse/vco
sed -i "s/vco=\"linuxpe\"/vco=\"linux_x86_64\"/g" $QUARTUS_ROOTDIR/questa_fse/vco
