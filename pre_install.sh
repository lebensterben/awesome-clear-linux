#!/usr/bin/bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 0
fi

## Install Dynamic Kernel Module System (DKMS) according to kernel variant
echo -e "\e[33m\xe2\x8f\xb3 Installing Dynamic Kernel Module System ...\e[m"
VARIANT="$(uname -r | rev | sed 's/\..*//' | rev | sed -e 's/^/kernel-/' -e 's/$/-dkms/')"
swupd bundle-add "$VARIANT"
unset VARIANT

## Update Clear Linux OS bootloader
echo -e "\e[33m\xe2\x8f\xb3 Updating Clear Linux OS bootloader ...\e[m"
clr-boot-manager update

## Ask the user whether he wants to reboot now
read -p "$(echo -e '\e[31m\xe2\x9d\x93 Do you want to reboot now (y/N)? \e[m')" -n 1 -r
echo
if [[ $REPLY =~ ^[y]$ ]]; then
  echo -e "\e[33m\xe2\x8f\xb3 Rebooting ...\e[m"
  reboot
else
  echo -e "\e[32mPlease reboot your system ASAP and execute the \e[33minstall.sh \e[32mscript to install the NVIDIA proprietary driver.\e[m"
  exit 0
fi
