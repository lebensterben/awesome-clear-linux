#!/usr/bin/env bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

## Verify NVIDIA proprietary driver is installed
echo -e "\e[33m\xe2\x8f\xb3 Checking NVIDIA proprietary driver ...\e[m"
glxinfo | grep nvidia &>/dev/null
if [ "$?" ]; then
  echo -e "\e[31m\xe2\x9d\x8c NVIDIA proprietary driver not found.\e[m"
  echo -e "\e[32mPlease install the NVIDIA proprietary driver first.\e[m"
  exit 1
fi

## (Optional) Install GCC7
if [ ! "$(which gcc7 2>/dev/null)" ]; then
  echo -e "\e[33m\xe2\x9d\x8c gcc 7 is not detected, which may be required if you need to compile CUDA applications.\e[m"
  read -p "$(echo -e "\e[32mDo you want to install \e[33mc-extras-gcc7\e[32m bundle?\e[m [y/N]")" gcc_install
  if [ "$gcc_install" = "y" ]; then
    swupd bundle-add c-extras-gcc7 --debug --no-progress > swupd_gcc7.log && \
      rm swupd_gcc7.log || \
        echo -e "\e[31mFailed to add c-extras-gcc7 bundle.\e[m" && \
          echo -e "\e[32mSee\e[33m $PWD/swupd_gcc7.log\e[32m for details\e[m"
    [ -d /usr/local/cuda/bin ] || mkdir -pv /usr/local/cuda/bin
    [ "$(readlink /usr/local/cuda/bin/gcc 2>/dev/null)" != "/usr/bin/gcc7" ] || ln -sv /usr/bin/gcc7 /usr/local/cuda/bin/gcc
    [ "$(readlink /usr/local/cuda/bin/g++ 2>/dev/null)" != "/usr/bin/g++7" ] || ln -sv /usr/bin/g++7 /usr/local/cuda/bin/g++
  fi
fi

## Try to locate NVIDIA CUDA Toolkit installer
## `cuda_<CUDA_VERESION>_<DRIVER_VERSION>_linux.run` under current directory
## or `~/Downloads` directory
echo -e "\e[33m\xe2\x8f\xb3 Locating cuda_<CUDA_VERSION>_<DRIVER_VERSION>_linux.run ...\e[m"
INSTALLER="$(find "$PWD" -maxdepth 1 -name 'cuda_*_linux\.run')"
if [ ! "$INSTALLER" ]; then
  INSTALLER="$(find "$HOME"/Downloads -maxdepth 1 -name 'cuda_*_linux\.run')"
  if [ ! "$INSTALLER" ]; then
    echo -e "\e[31m\xe2\x9d\x8c Cannot find NVIDIA CUDA Toolkit installer under current directory or ~/Downloads\e[m"
    read -p "$(echo -e "\e[32m Do you want to open the CUDA Toolkit Archive webpage in your default browser?\e[m [Y/n]")" cuda_archive
    [ "$cuda_archive" = "n" ] && exit 1 || xdg-open "https://developer.nvidia.com/cuda-toolkit-archive" && exit 0
  fi
fi

## Configure the dynamic linker configuration to include /opt/nvidia/lib and /opt/cuda/lib64
echo -e "\e[33m\xe2\x8f\xb3 Configuring dynamic linker configuration ...\e[m"
if [ ! -f /etc/ld.so.conf ] || [ "$(grep 'include /etc/ld\.so\.conf\.d/\*\.conf' /etc/ld.so.conf )" ]; then
  cat <<EOF >> /etc/ld.so.conf
include /etc/ld.so.conf.d/*.conf
EOF
fi
if [ ! -d /etc/ld.so.conf.d ]; then
  mkdir /etc/ld.so.conf.d
fi

## Install the NVIDIA CUDA Toolkit with advanced options below
echo -e "\e[33m\xe2\x8f\xb3 Installing NVIDIA CUDA Toolkit now ...\e[m"
echo -e "\e[32mThe version of CUDA Toolkit is \e[33m$(awk -F'_' '{print $2}'  <<< "$INSTALLER")\e[m"
read -rp "Press any key to continue... " -n1 -s
echo
sh "$INSTALLER" \
   --toolkit \
   --samples \
   --installpath=/opt/cuda \
   --no-man-page \
   --override \
   --silent
[ $? = 0 ] && exit 0 || \
    echo -e "\e[31mFailed to install NVIDIA CUDA Toolkit.\e[m" && exit 1
