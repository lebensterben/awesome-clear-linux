#!/usr/bin/env bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

## Verify NVIDIA proprietary driver is installed and get current driver version
CURRENT="$(/opt/nvidia/bin/nvidia-settings --version 2>/dev/null)" \
  && CURRENT="$(awk 'NR==2{print $3}' <<< "$CURRENT")" \
    || { echo -e "\e[31m Cannot obtain current NVIDIA driver version, is it installed?\e[m"; exit 1;}

## Retrieve latest NVIDIA driver version, and download it if it doesn't exist
echo -e "\e[33m\xe2\x8f\xb3 Retrieving latest driver version ...\e[m"
LATEST="$(curl -L -s https://download.nvidia.com/XFree86/Linux-x86_64 | grep "<span class='dir'>" | tail -n1 | sed -e "s/.*'>//" -e "s/\/<.*//" )"
if [ -z "$LATEST" ]; then
  echo -e "\e[31m Cannot obtaining latest NVIDIA driver version number ...\e[m"
  echo -e "\e[32m Please Download the latest driver manually\e[m"
  exit 1
else
  echo -e "\e[32m The latest version is \e[33m${LATEST}\e[m"
  if (( ${CURRENT%%.*} < ${LATEST%%.*} )) || (( ${CURRENT##*.} < ${LATEST##*.} )); then
    if [ -f "${PWD}/NVIDIA-Linux-x86_64-${LATEST}.run" ]; then
      echo -e "\e[32m The installer for the latest driver is already downloaded.\e[m"
    else
      echo -e "\e[32m Dowloading \e[33m${LATEST} \e[m..."
      curl -O "https://download.nvidia.com/XFree86/Linux-x86_64/${LATEST}/NVIDIA-Linux-x86_64-${LATEST}.run"
    fi
  else
    echo -e "\e[32m Your NVIDIA driver is up to date."
    exit 0
  fi
fi

## Temporarily set default boot target to `multi-user`
echo -e "\e[33m\xe2\x8f\xb3 Temprarily set default boot target to \e[32mmulti-user\e[m."
systemctl set-default multi-user.target

## Ask the user to reboot
echo -e "\e[32m Please restart your system and execute the \e[33mupdate.sh \e[32mscript to update the NVIDIA proprietary driver.\e[m"
exit 0
