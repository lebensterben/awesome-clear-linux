#!/usr/bin/bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 0
fi

## Configure the dynamic linker configuration to include /opt/nvidia/lib and /opt/nvidia/lib32
echo -e "\e[33m\xe2\x8f\xb3 Configuring dynamic linker configuration ...\e[m"
if [ ! -d /etc/ld.so.conf.d ]; then
  mkdir /etc/ld.so.conf.d
fi
cat <<EOF > /etc/ld.so.conf.d/nvidia.conf
/opt/nvidia/lib
/opt/nvidia/lib32
EOF

if [ ! -f /etc/ld.so.conf ] || [ "$(grep 'include /etc/ld\.so\.conf\.d/\*\.conf' /etc/ld.so.conf )" = '' ]; then
  cat <<EOF >> /etc/ld.so.conf
include /etc/ld.so.conf.d/*.conf
EOF
fi

## Try to locate NVIDIA Linux Driver installer
## `NVIDIA-Linux-x86_64-<VERESION>.run` under current directory
## or `~/Downloads` directory
echo -e "\e[33m\xe2\x8f\xb3 Locating NVIDIA-Linux-x86_64-<VERSION>.run ...\e[m"
INSTALLER="$(find $PWD -maxdepth 1 -name 'NVIDIA-Linux-x86_64*\.run' | sort -r | head -1 )"
if [ "$INSTALLER" = '' ]; then
  INSTALLER="$(find $HOME/Downloads -maxdepth 1 -name 'NVIDIA-Linux-x86_64*\.run' | sort -r | head -1 )"
  if [ "$INSTALLER" = '' ]; then
    echo -e "\e[31m\xe2\x9d\x8c Cannot find NVIDIA-Linux-x86_64-<VERSION>.run under current directory or ~/Downloads\e[m"
    echo -e "\e[32mBelow are all display adapters currently identified on your current system:\e[m"
    echo -e "\e[32m$(sudo lshw -C display | command grep product | sed -r 's/.*product: /\t/g' | uniq)\e[m"
    echo -e "\e[32mPlease download the appropriate driver and re-run this install.sh script.\e[m"
    xdg-open https://www.nvidia.com/download/index.aspx
    exit 0
  fi
fi

## Install the NVIDIA driver with advanced options below
## Note that --no-nvidia-modprobe is deleted so that CUDA could work correctly
echo -e "\e[33m\xe2\x8f\xb3 Installing NVIDIA proprietary Driver now ... \e[m"
echo -e "\e[32mIf the installation is successful, GUI may automatically start.\e[m"
echo -e "\e[32mPlease run the post_install.sh to validate that the nvidia kernel modules are loaded.\e[m"
sh "$INSTALLER" \
   --utility-prefix=/opt/nvidia \
   --opengl-prefix=/opt/nvidia \
   --compat32-prefix=/opt/nvidia \
   --compat32-libdir=lib32 \
   --x-prefix=/opt/nvidia \
   --documentation-prefix=/opt/nvidia \
   --no-precompiled-interface \
   --no-distro-scripts \
   --force-libglx-indirect \
   --dkms \
   --silent
unset INSTALLER
