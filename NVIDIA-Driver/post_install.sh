#!/usr/bin/bash

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

## Validate that nvidia kernel modules are loaded
echo -e "\e[33m\xe2\x8f\xb3 Making sure NVIDIA kernel modules are loaded...\e[32m"
lsmod | grep ^nvidia

## Verify and fix OpenGL library files files that are likely modified by NVIDIA installer
echo -e "\e[33m\xe2\x8f\xb3 Verifying the integrity of OpenGL library files...\e[m"
swupd verify --quick --fix --bundles=lib-opengl

echo -e "\e[32m\xf0\x9f\x91\x8f Installation completed!\e[m"
