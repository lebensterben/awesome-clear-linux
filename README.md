# Scripts for installing NVIDIA Proprietary Driver on Linux

Based on the [tutorial by Clear Linux](https://clearlinux.org/documentation/clear-linux/tutorials/nvidia), I created four bash scripts that will automate the installation, and uninstallation, of NVIDIA proprietary driver.

All of them needs `root` privilege to be executed.

## 1. `pre_install.sh`

This script would install `kernel-native-dkms` or `kernel-lts-dkms` bundle based on your kernel type. Then it will update Clear Linux OS bootloader and prompt the user to reboot.

**Note**: This shall only need to be exectuted for once.

## 2. `install.sh`

This script do the followings:
- Set up ld config file to include libraries that are going to be installed by NVIDIA drivers.
- Disable nouveau driver.
- Locate NVIDIA driver installer
  - If it cannot find the installer under current directory or `~/Downloads`, it will open the download page via the default web browser of the user. Before it exits, it also shows the display adapters currently idenfied in the OS.
  - If there're multiple installer found, it chooses the newest one according to the version number.
- Install the driver with the following options:
  ```
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
  ```
  - I removed `--no-nvidia-modprobe` because it's needed for CUDA toolkit to work properly.
-  Before exiting, it will remind user to run the `post_install.sh`

## 3. `post_install.sh`

This script will list the NVIDIA kernel modules loaded on the system, which shall not be empty or otherwise the installation is not successful.

It also calls `swupd verify --fix` to verify the integrity of OpenGL library, which is likely to be altered by NVIDIA installer.

## 4. `uninstall.sh`

This script re-enables nouveau driver before it uninstalls NVIDIA proprietary driver via the official uninstaller, `nvidia-uninstall`. It also prompts the user to reboot.
