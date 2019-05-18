# Scripts for installing NVIDIA Proprietary Driver on Clear Linux

Based on the [tutorial by Clear Linux](https://clearlinux.org/documentation/clear-linux/tutorials/nvidia), I wrote four bash scripts that automate the installation, and uninstallation, of NVIDIA proprietary driver.

By design, all of them needs `root` privilege to be executed. Therefore there's no need to change their permission to make them executable.

## 1. `pre_install.sh`

- Installs `kernel-native-dkms` or `kernel-lts-dkms` bundle based on your kernel type
- Updates Clear Linux OS boot-loader
- Disables nouveau driver by blacklisting it in `/etc/modprobe.d/disable-nouveau.conf`
- Reminds the user to reboot, and use `install.sh** script to proceed to installation.

**Note**: After the reboot the GUI desktop environment may not work, then you need press `Ctrl+Alt+F2` to enter `tty2`, from which you can log-in and proceed to the next step.

## 2. `install.sh`

- Sets up `ld.so.conf` file to include libraries that are going to be installed by NVIDIA drivers, which are under `/opt/nvidia/lib` and `/opt/nvidia/lib32`.
- Locates NVIDIA driver installer , `NVIDIA-Linux-x86_64-<VERSION>.run`, under current directory.
  - If there are multiple installer found, it chooses the newest one according to the version number.
  - If the installer is not found in current directory, then search in `~/Downloads` instead.
  - If it's still not found, the download page would be open by the default web browser. Display adapters currently identified in the OS would be displayed to assist the user in finding the right driver.
- Installs the driver with the following options:
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
-  Before the actual installation, users will be reminded of running the `post_install.sh`, and they need to press a key to continue installation.

## 3. `post_install.sh`

- Lists the NVIDIA kernel modules loaded on the system, which shall not be empty or otherwise the installation is not successful.
- Calls `swupd verify --fix` to verify the integrity of OpenGL library, which is likely to be altered by NVIDIA installer.

## 4. `uninstall.sh`

- Re-enables nouveau driver by moving them out of blacklist defined in `/etc/modprobe.d/disable-nouveau.conf`.
- Uninstalls NVIDIA proprietary driver via the official uninstaller, `/opt/nvidia/bin/nvidia-uninstall`.
- Remind the user to reboot after uninstallation.
