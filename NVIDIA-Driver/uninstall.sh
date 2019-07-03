#!/usr/bin/env bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

## Re-enable nouveau driver
## The following two file names come from different editions of Clear tutorial
echo -e "\e[33m\xe2\x8f\xb3 Re-enabling nouveau Driver ...\e[m"
for i in /etc/modprobe.d/disable-nouveau.conf /etc/modprobe.d/nvidia-disable-nouveau.conf ; do
  if [ -f "$i" ]; then
    rm $i
  fi
done

## Running nvidia-uninstall script (by NVIDIA) to uninstall the GPU driver
echo -e "\e[33m\xe2\x8f\xb3 Running nvidia-uninstall ...\e[m"
/opt/nvidia/bin/nvidia-uninstall

## Remove NVIDIA libraries from dynamic linker configuration
echo -e "\e[33m\xe2\x8f\xb3 Restoring dynamic linker configuration ...\e[m"
sed -i '/^include \/etc\/ld\.so\.conf\.d\/\*\.conf$/d' /etc/ld.so.conf
if [ -e "/etc/ld.so.conf.d/nvidia.conf" ]; then
  rm /etc/ld.so.conf.d/nvidia.conf
fi
if [ -e "/usr/share/X11/xorg.conf.d/nvidia-drm-outputclass.conf" ]; then
  rm /usr/share/X11/xorg.conf.d/nvidia-drm-outputclass.conf
fi

## Removing Xorg configuration file for NVIDIA driver
echo -e "\e[33m\xe2\x8f\xb3 Restoring Xorg configuration ...\e[m"
rm /etc/X11/xorg.conf.d/nvidia-files-opt.conf

## Ask the user whether he wants to reboot now
clr-boot-manager update
echo -e "\e[32mPlease reboot your system ASAP.\e[m"
exit 0
