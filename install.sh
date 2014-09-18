#!/bin/sh

INSTALL_DIR=/opt/galileo

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

mkdir -p $INSTALL_DIR
cd /tmp
wget http://downloadmirror.intel.com/24272/eng/arduino-linux64-1.0.3.tgz
tar xf arduino-linux64-1.0.3.tgz
rm arduino-linux64-1.0.3.tgz
cp -r arduino-1.5.3-Intel.1.0.3/* $INSTALL_DIR/
rm -rf arduino-1.5.3-Intel.1.0.3
$INSTALL_DIR/hardware/tools/install_script.sh
$INSTALL_DIR/hardware/tools/edison/install_script.sh
