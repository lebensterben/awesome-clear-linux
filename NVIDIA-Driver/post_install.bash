#!/usr/bin/env bash

# Validate that nvidia kernel modules are loaded
echo -e "\e[33m\xe2\x8f\xb3 Making sure NVIDIA kernel modules are loaded ...\e[m"
if ! lsmod | grep ^nvidia; then
  echo -e "\e[31m Cannot find NVIDIA modules, something went wrong!\e[m"
  exit 1
fi

# Optionally ask user whether to add a desktop file for "nvidia-settings"
read -rp "Do you want to add a desktop file for \"nvidia-settings\"? (Y/n)" -n1 -s
echo
if [ "$REPLY" = Y ]; then
  ln -sv /opt/nvidia/share/applications/nvidia-settings.desktop "$HOME"/.local/share/applications
fi

echo -e "\e[32m\xf0\x9f\x91\x8f Installation completed!\e[m"
