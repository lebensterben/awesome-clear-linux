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

# Fix Suspend/Resume Service Files
echo -e "\e[33m\xe2\x8f\xb3 Modifying Nvidia Service Files ...\e[m"

sudo sed -i 's|/usr/bin/nvidia-sleep.sh|/opt/nvidia/bin/nvidia-sleep.sh|g' /etc/systemd/system/systemd-suspend.service.requires/nvidia-suspend.service
sudo sed -i 's|/usr/bin/nvidia-sleep.sh|/opt/nvidia/bin/nvidia-sleep.sh|g' /etc/systemd/system/systemd-suspend.service.requires/nvidia-resume.service

sudo systemctl daemon-reload

# Optionally ask user whether to add a desktop file for "nvidia-settings"
if ! [ -f "$HOME"/.local/share/applications/nvidia-settings.desktop ]; then
  read -rp "Do you want to add a desktop file for \"nvidia-settings\"? (Y/n)" -n1 -s
  echo
  if [ "$REPLY" = Y ]; then
    ln -sv /opt/nvidia/share/applications/nvidia-settings.desktop "$HOME"/.local/share/applications
  fi
fi
echo -e "\e[32m\xf0\x9f\x91\x8f Installation completed!\e[m"

# Optionally ask user whether to delete NVIDIA installer(s)
read -rp "Do you want to delete NVIDIA driver installer(s) in current directory? (Y/n)" -n1 -s
echo
if [ "$REPLY" = Y ]; then
  find . -maxdepth 1 -name 'NVIDIA-Linux-x86_64*\.run' -printf "Removing %f\n" -delete
fi

echo -e "\e[32m\xf0\x9f\x91\x8f Update completed!\e[m"
