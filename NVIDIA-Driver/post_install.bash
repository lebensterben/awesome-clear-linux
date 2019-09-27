#!/usr/bin/env bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

## Validate that nvidia kernel modules are loaded
echo -e "\e[33m\xe2\x8f\xb3 Making sure NVIDIA kernel modules are loaded ...\e[m"
lsmod | grep ^nvidia

## Verify and fix OpenGL library files files that are likely modified by NVIDIA installer
echo -e "\e[33m\xe2\x8f\xb3 Verifying the integrity of OpenGL library files ...\e[m"
swupd verify --fix --quick --bundles=lib-opengl

## Update flatpak runtime for the new NVIDIA driver
echo -e "\e[33m\xe2\x8f\xb3 Updating the flatpak runtime ...\e[m"
flatpak update -y

echo -e "\e[32m\xf0\x9f\x91\x8f Installation completed!\e[m"
