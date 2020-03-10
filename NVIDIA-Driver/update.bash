#!/usr/bin/env bash

# Locate the NVIDIA Linux Driver installer
# `NVIDIA-Linux-x86_64-<VERSION>.run` under current directory
echo -e "\e[33m\xe2\x8f\xb3 Locating NVIDIA-Linux-x86_64-<VERSION>.run ...\e[m"
INSTALLER="$(find "$PWD" -maxdepth 1 -name 'NVIDIA-Linux-x86_64*\.run' | sort -r | head -1 )"
if [ -z "$INSTALLER" ];then
  echo -e "\e[31m Cannot find the installer.\e[m"
  echo -e "\e[31m Exiting ...\e[m"
  exit 1
fi

# Install the NVIDIA driver with advanced options below
echo -e "\e[33m\xe2\x8f\xb3 Updating NVIDIA proprietary Driver now ... \e[m"
echo -e "\e[32m The version of the driver is \e[33m""$([[ "$INSTALLER" =~ ^.*\-(.*)\.run$ ]] && \
echo "${BASH_REMATCH[1]}")\e[m"
read -rp "Press any key to continue ... " -n1 -s
echo
if ! sudo sh "$INSTALLER" \
     --utility-prefix=/opt/nvidia \
     --opengl-prefix=/opt/nvidia \
     --compat32-prefix=/opt/nvidia \
     --compat32-libdir=lib32 \
     --x-prefix=/opt/nvidia \
     --x-module-path=/opt/nvidia/lib64/xorg/modules \
     --x-library-path=/opt/nvidia/lib64 \
     --x-sysconfig-path=/etc/X11/xorg.conf.d \
     --documentation-prefix=/opt/nvidia \
     --application-profile-path=/etc/nvidia/nvidia-application-profiles-rc.d \
     --no-precompiled-interface \
     --no-nvidia-modprobe \
     --no-distro-scripts \
     --force-libglx-indirect \
     --glvnd-egl-config-path=/etc/glvnd/egl_vendor.d \
     --egl-external-platform-config-path=/etc/egl/egl_external_platform.d \
     --dkms \
     --silent; then
  echo -e "\e[31m Update failed! Aborting ...\e[m"
  exit 1
fi

# Set default boot target back to graphical target.
echo -e "\e[33m\xe2\x8f\xb3 Set default boot target to \[32mgraphical.target\e[m."
sudo systemctl set-default graphical.target

# Ask the user to run post_update.bash
echo -e "\e[32m Please run the \e[33mpost_update.bash\e[32m script ASAP.\e[m"
