#!/usr/bin/bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 0
fi

## Re-enable nouveau driver
## The following two file names come from different editions of clear tutorial
echo -e "\e[33m\xe2\x8f\xb3 Re-enabling nouveau Driver ...\e[m"
for i in /etc/modprobe.d/disable-nouveau.conf /etc/modprobe.d/nvidia-disable-nouveau.conf ; do
  if [ -f "$i" ]; then
    rm $i
  fi
done
unset i

## Running nvidia-uninstall script (by NVIDIA) to uninstall the GPU driver
echo -e "\e[33m\xe2\x8f\xb3 Running nvidia-uninstall ...\e[m"
/opt/nvidia/bin/nvidia-uninstall

## Removing /etc/ld.conf.d/nvidia.conf
echo -e "\e[33m\xe2\x8f\xb3 Removing NVIDIA libraries ...\e[m"
if [ -f "/etc/ld.conf.d/nvidia.conf" ]; then
  rm "/etc/ld.conf.d/nvidia.conf"
fi

## Ask the user whether he wants to reboot now
echo -e "\e[32mPlease reboot your system ASAP.\e[m"
exit 0
