#!/usr/bin/env bash

# Try to locate the driver installer under current directory, downlad on if not found
echo -e "\e[33m\xe2\x8f\xb3 Locating NVIDIA-Linux-x86_64-<VERSION>.run ...\e[m"
INSTALLER="$(find .  -maxdepth 1 -name 'NVIDIA-Linux-x86_64*\.run' | sort -r | head -1 )"
if [ "$INSTALLER" = '' ]; then
  ## Cannot find installer, download one
  echo -e "\e[31m\xe2\x9d\x8c Cannot find NVIDIA-Linux-x86_64-<VERSION>.run under current directory\e[m"
  LATEST="$(curl -s -L https://download.nvidia.com/XFree86/Linux-x86_64 | grep "<span class='dir'>"\
            | tail -n1 | sed -e "s/.*'>//" -e "s/\/<.*//" )"
  if [ -z "$LATEST" ]; then
    echo -e "\e[31m Cannot obtaining latest NVIDIA driver version number ...\e[m"
    echo -e "\e[32m Please Download the latest driver manually\e[m"
    exit 1
  else
    echo -e "\e[32m The latest version of NVIDIA driver is \e[33m${LATEST}\e[m"
    echo -e "\e[32m Dowloading \e[33m${LATEST} ...\e[m"
    curl -O "https://download.nvidia.com/XFree86/Linux-x86_64/${LATEST}/NVIDIA-Linux-x86_64-\
${LATEST}.run"
    if [ -f "NVIDIA-Linux-x86_64-${LATEST}.run" ]; then
      INSTALLER="NVIDIA-Linux-x86_64-${LATEST}.run"
    fi
  fi
fi

# Configure the dynamic linker configuration to include /opt/nvidia/lib and /opt/nvidia/lib32
echo -e "\e[33m\xe2\x8f\xb3 Configuring dynamic linker configuration ...\e[m"
if [ ! -f /etc/ld.so.conf ] || \
     grep -q '^include /etc/ld\.so\.conf\.d/\*\.conf$' /etc/ld.so.conf; then
  cat <<EOF | sudo tee --append /etc/ld.so.conf > /dev/null
include /etc/ld.so.conf.d/*.conf
EOF
fi
if [ ! -d /etc/ld.so.conf.d ]; then
  sudo mkdir /etc/ld.so.conf.d
fi
## Write `/etc/ld.so.conf.d/nvidia.conf`
cat <<EOF | sudo tee /etc/ld.so.conf.d/nvidia.conf > /dev/null
/opt/nvidia/lib
/opt/nvidia/lib32
EOF
echo -e "\e[32m Updating dynamic linker run-time bindings and library cache ...\e[m"
sudo ldconfig

# Configure Xorg to search for modules under /opt/nvidia
echo -e "\e[33m\xe2\x8f\xb3 Configuring Xorg to search for additional module ...\e[m"
if [ ! -d /etc/X11/xorg.conf.d ]; then
  sudo mkdir -p /etc/X11/xorg.conf.d
fi
## Write `/etc/X11/xorg.conf.d/nvidia-files-opt.conf`
cat <<EOF | sudo tee /etc/X11/xorg.conf.d/nvidia-files-opt.conf > /dev/null
Section "Files"
        ModulePath      "/usr/lib64/xorg/modules"
        ModulePath      "/opt/nvidia/lib64/xorg/modules"
EndSection
EOF

# Install the NVIDIA driver with advanced options below
echo -e "\e[33m\xe2\x8f\xb3 Installing NVIDIA proprietary Driver now ... \e[m"
echo -e "\e[32m If the installation is successful, GUI may automatically start.\e[m"
echo -e "\e[32m Please run the \e[33mpost_install.bash \e[32mto validate that the nvidia kernel \
modules are loaded.\e[m"
echo -e "\e[32m The version of the driver is \e[33m""$([[ "$INSTALLER" =~ ^.*\-(.*)\.run$ ]] && \
echo "${BASH_REMATCH[1]}")\e[m"
read -rp "Press any key to continue ... " -n1 -s
echo
if ! sudo sh "$INSTALLER" \
    --utility-prefix=/opt/nvidia \
    --opengl-prefix=/opt/nvidia \
    --compat32-prefix=/opt/nvidia \
    --compat32-libdir=lib32 \
    --x-prefix=/opt/nvidia \
    --x-module-path=/opt/nvidia/lib64/xorg/modules \
    --x-library-path=/opt/nvidia/lib64 \
    --x-sysconfig-path=/etc/X11/xorg.conf.d \
    --documentation-prefix=/opt/nvidia \
    --application-profile-path=/etc/nvidia/nvidia-application-profiles-rc.d \
    --no-precompiled-interface \
    --no-nvidia-modprobe \
    --no-distro-scripts \
    --force-libglx-indirect \
    --glvnd-egl-config-path=/etc/glvnd/egl_vendor.d \
    --egl-external-platform-config-path=/etc/egl/egl_external_platform.d \
    --dkms \
    --silent; then
  echo -e "\e[31m Installation failed! Aborting...\e[m"
  exit 1
fi
