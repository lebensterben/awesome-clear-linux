#!/usr/bin/env bash

# Remove files created for workarounds
echo -e "\e[33m\xe2\x8f\xb3 Removing files created for workarounds ...\e[m"
for i in /etc/kernel/cmdline-removal.d/intel-iommu.conf \
           /etc/systemd/system/fix-nvidia-libGL-trigger.service \
           /etc/systemd/system/update-triggers.target.wants/fix-nvidia-libGL-trigger.service; do
  if [ -f "$i" ]; then
    echo -e "\e[33m Removing \e[32m$i\e[33m ...\e[m"
    sudo rm $i
  fi
done
sudo systemctl daemon-reload

# Re-enable nouveau driver
echo -e "\e[33m\xe2\x8f\xb3 Re-enabling nouveau Driver ...\e[m"
## The following two file names come from different editions of Clear tutorial
for i in /etc/modprobe.d/disable-nouveau.conf /etc/modprobe.d/nvidia-disable-nouveau.conf ; do
  if [ -f "$i" ]; then
    echo -e "\e[33m Removing \e[32m$i\e[33m ...\e[m"
    sudo rm $i
  fi
done

# Remove Xorg configuration file for NVIDIA driver
echo -e "\e[33m\xe2\x8f\xb3 Restoring Xorg configuration ...\e[m"
for i in /etc/X11/xorg.conf.d/nvidia-files-opt.conf\
           /usr/share/X11/xorg.conf.d/nvidia-drm-outputclass.conf; do
  if [ -f "$i" ]; then
    echo -e "\e[33m Removing \e[32m$i\e[33m ...\e[m"
    sudo rm $i
  fi
done

# Remove NVIDIA libraries from dynamic linker configuration
echo -e "\e[33m\xe2\x8f\xb3 Restoring dynamic linker configuration ...\e[m"
if [ -e /etc/ld.so.conf.d/nvidia.conf ]; then
  echo -e "\e[33m Removing \e[32m$i\e[33m ...\e[m"
  sudo rm /etc/ld.so.conf.d/nvidia.conf
fi

# Remove desktop file for `nvidia-settings` if it's installed
if [ -f "$HOME"/.local/share/applications/nvidia-settings.desktop ]; then
  echo -e "\e[33m\xe2\x8f\xb3 Removing desktop file for \e[32m\"nvidia-settings\"\e[33m ...\e[m"
  unlink -v "$HOME"/.local/share/applications/nvidia-settings.desktop
fi

# Running nvidia-uninstall script (by NVIDIA) to uninstall the GPU driver
echo -e "\e[33m\xe2\x8f\xb3 Running nvidia-uninstall ...\e[m"
sudo /opt/nvidia/bin/nvidia-uninstall

# Ask the user whether he wants to reboot now
echo -e "\e[32m Please reboot your system ASAP.\e[m"
exit 0
