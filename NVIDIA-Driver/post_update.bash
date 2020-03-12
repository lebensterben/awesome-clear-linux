#!/usr/bin/env bash

# Validate that nvidia kernel modules are loaded
echo -e "\e[33m\xe2\x8f\xb3 Making sure NVIDIA kernel modules are loaded ...\e[m"
if ! lsmod | grep '^nvidia '; then
  echo -e "\e[31m Cannot find NVIDIA modules, something went wrong!\e[m"
  exit 1
fi

# Update flatpak runtime for the new NVIDIA driver
echo -e "\e[33m\xe2\x8f\xb3 Updating the flatpak runtime ...\e[m"
flatpak update -y

echo -e "\e[32m\xf0\x9f\x91\x8f Update completed!\e[m"
