#!/usr/bin/env bash

# Check GCC version compatibility
GCC_VERSION="$(gcc --version | grep -oP '([0-9]+.?){3}(?= [0-9]{8})')"
KERNEL_GCC_VERSION="$(grep -oP '([0-9]+.?){3}(?= [0-9]{8})' "/proc/version")"
if ! [ "$GCC_VERSION" = "$KERNEL_GCC_VERSION" ]; then
  echo -e "\e[31m\xe2\x9d\x8c The GCC used for compiling the kernel, $KERNEL_GCC_VERSION, is \
different from the current GCC version, $GCC_VERSION.\e[m"
  exit 1
fi

# Make sure `IOMMU` is disabled for Intel CPUs
if grep -q 'Intel' /proc/cpuinfo; then
  echo -e "\e[33m\xe2\x8f\xb3 Found \e[32mIntel CPU(s)\e[33m, disabling IOMMU ...\e[m"
  if [ ! -d /etc/kernel/cmdline-removal.d ]; then
    sudo mkdir -p /etc/kernel/cmdline-removal.d
  fi
  cat <<< 'intel_iommu=igfx_off' | \
    sudo tee /etc/kernel/cmdline-removal.d/intel-iommu.conf > /dev/null
fi

# Create a systemd unit that overwrites `libGL` library after every OS update
echo -e "\e[33m\xe2\x8f\xb3 Creating a systemd unit that fix problems with \"libGL\" library ...\
\e[m"

## Write the systemd file at "/etc/systemd/system/fix-nvidia-libGL-trigger.service"
echo -e "\e[33m Writing the systemd unit file at \"\e[32m\
/etc/systemd/system/fix-nvidia-libGL-trigger.service\e[33m\"\e[m"

cat <<EOF | sudo tee /etc/systemd/system/fix-nvidia-libGL-trigger.service > /dev/null
[Unit]
Description=Fixes libGL symlinks for the NVIDIA proprietary driver
BindsTo=update-triggers.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ln -sfv /opt/nvidia/lib/libGL.so.1 /usr/lib/libGL.so.1
ExecStart=/usr/bin/ln -sfv /opt/nvidia/lib32/libGL.so.1 /usr/lib32/libGL.so.1
EOF

## Reload systemd daemon to find the new service
echo -e "\e[33m Reload systemd manager configuration to pick up the new service ...\e[m"
sudo systemctl daemon-reload

## Make sure the service is launched after every OS update
echo -e "\e[33m Creating a hook to Clear Linux OS updates ...\e[m"
sudo systemctl add-wants update-triggers.target fix-nvidia-libGL-trigger.service

# Install Dynamic Kernel Module System (DKMS) if not found, according to kernel variant
VARIANT="$(uname -r)" && VARIANT=${VARIANT##*.}
case "$VARIANT" in
  aws|lts|lts2018|lts2019|native)
    if ! sudo swupd bundle-list | grep -q kernel-"$VARIANT"-dkms; then
      echo -e "\e[33m\xe2\x8f\xb3 Installing Dynamic Kernel Module System ...\e[m"
      sudo swupd bundle-add kernel-"$VARIANT"-dkms
    fi
    ;;
  *)
    echo -e "\e[31m\xe2\x9d\x8c The kernel must be either \"\e[32mnative\e[31m\" or \"\e[32mlts\
\e[31m\".\e[m"
    exit 1
    ;;
esac

## Update Clear Linux OS bootloader
echo -e "\e[33m\xe2\x8f\xb3 Updating Clear Linux OS bootloader ...\e[m"
sudo clr-boot-manager update

# Disable nouveau driver
echo -e "\e[33m\xe2\x8f\xb3 Disabling nouveau Driver ...\e[m"
if [ ! -d /etc/modprobe.d ]; then
  sudo mkdir /etc/modprobe.d
fi
cat <<EOF | sudo tee /etc/modprobe.d/disable-nouveau.conf > /dev/null
blacklist nouveau
options nouveau modeset=0
EOF

# Ask the user whether he wants to reboot now
echo -e "\e[32m Please reboot your system ASAP and execute the \e[33minstall.bash \e[32mscript to \
install the NVIDIA proprietary driver.\e[m"
exit 0
