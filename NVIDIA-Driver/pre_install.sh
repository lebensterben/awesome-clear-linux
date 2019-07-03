#!/usr/bin/bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

## Install Dynamic Kernel Module System (DKMS) according to kernel variant
VARIANT="$(uname -r)" && VARIANT=${VARIANT##*.}
case "$VARIANT" in 
  native|lts)
    echo -e "\e[33m\xe2\x8f\xb3 Installing Dynamic Kernel Module System ...\e[m"
    swupd bundle-add kernel-"$VARIANT"-dkms
    ;;
  *)
    echo -e "\e[31m\xe2\x9d\x8c The kernel must be either \"native\" or \"lts\".\e[m"
    exit 1
    ;;
esac

## Update Clear Linux OS bootloader
echo -e "\e[33m\xe2\x8f\xb3 Updating Clear Linux OS bootloader ...\e[m"
clr-boot-manager update

## Disable nouveau driver
echo -e "\e[33m\xe2\x8f\xb3 Disabling nouveau Driver ...\e[m"
if [ ! -d /etc/modprobe.d ]; then
  mkdir /etc/modprobe.d
fi
cat <<EOF > /etc/modprobe.d/disable-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF

## Ask the user whether he wants to reboot now
echo -e "\e[32mPlease reboot your system ASAP and execute the \e[33minstall.sh \e[32mscript to install the NVIDIA proprietary driver.\e[m"
exit 0
