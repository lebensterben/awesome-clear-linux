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
      DRIVER="NVIDIA-Linux-x86_64-${LATEST}"
      INSTALLER="${DRIVER}.run"
    fi
  fi
fi

# Configure the dynamic linker configuration to include /opt/nvidia/lib and /opt/nvidia/lib32
echo -e "\e[33m\xe2\x8f\xb3 Configuring dynamic linker configuration ...\e[m"
if [ ! -f /etc/ld.so.conf ] || \
     [ "$(grep 'include /etc/ld\.so\.conf\.d/\*\.conf' /etc/ld.so.conf )" = '' ]; then
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
cat <<EOF | sudo tee /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf > /dev/null
# This xorg.conf.d configuration snippet configures the X server to
# automatically load the nvidia X driver when it detects a device driven by the
# nvidia-drm.ko kernel module.  Please note that this only works on Linux kernels
# version 3.9 or higher with CONFIG_DRM enabled, and only if the nvidia-drm.ko
# kernel module is loaded before the X server is started.
Section "OutputClass"
    Identifier  "intel"
    MatchDriver "i915"
    Driver      "modesetting"
EndSection 

Section "OutputClass"
    Identifier      "nvidia"
    MatchDriver     "nvidia-drm"
    Driver          "nvidia"
    Option          "AllowEmptyInitialConfiguration"
    Option          "PrimaryGPU" "yes"
    ModulePath      "/opt/nvidia/lib64/xorg/modules"
    ModulePath      "/usr/lib64/xorg/modules"
EndSection
EOF
cat <<EOF | sudo tee /etc/X11/xorg.conf.d/90-mwhd.conf > /dev/null
Section "Module"
	Load "modesetting"
EndSection

Section "Device"
	Identifier "nvidia"
	Driver "nvidia"
	BusID "PCI:1:0:0"
	Option "AllowEmptyInitialConfiguration"
EndSection
EOF

# Optimus workaround (maybe should ask user first?)
echo -e "\e[33m\xe2\x8f\xb3 Applying Optimus workarounds...\e[m"
if [ ! -d /usr/local/share ]; then
  sudo mkdir -p /usr/local/share
fi
cat <<EOF | sudo tee /usr/local/share/optimus.desktop > /dev/null
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
EOF
sudo ln -s /usr/local/share/optimus.desktop /usr/share/gdm/greeter/autostart/optimus.desktop
sudo ln -s /usr/local/share/optimus.desktop /etc/xdg/autostart/optimus.desktop

# Install the NVIDIA driver with advanced options below
echo -e "\e[33m\xe2\x8f\xb3 Installing NVIDIA proprietary Driver now ... \e[m"
echo -e "\e[32m If the installation is successful, GUI may automatically start.\e[m"
echo -e "\e[32m Please run the \e[33mpost_install.bash \e[32mto validate that the nvidia kernel \
modules are loaded.\e[m"
echo -e "\e[32m The version of the driver is \e[33m""$([[ "$INSTALLER" =~ ^.*\-(.*)\.run$ ]] && \
echo "${BASH_REMATCH[1]}")\e[m"
read -rp "Press any key to continue ... " -n1 -s
echo
# We only extract, otherwise ENV variables don't seem to affect the installer
# This is also faster if the user wants to repete the installation
if [ ! -d ./${DRIVER}]
if ! sudo sh "$INSTALLER" --extract-only; then
  echo -e "\e[31m Installation failed! Aborting...\e[m"
  exit 1
fi

# No silent install -- user will have to answer some questions. This is because private signing
# key MUST NOT be deleted, and there seems to be no command line option to force this behaviour.
# No DKMS: all the stuff done in the previous steps might be useless for this approach.
sudo CONFIG_SECTION_MISMATCH_WARN_ONLY=y ./${DRIVER}/nvidia-installer  \
    --utility-prefix=/opt/nvidia \
    --opengl-prefix=/opt/nvidia \
    --compat32-prefix=/opt/nvidia \
    --compat32-libdir=lib32 \
    --x-prefix=/opt/nvidia \
    --x-module-path=/opt/nvidia/lib64/xorg/modules \
    --x-library-path=/opt/nvidia/lib64 \
    --x-sysconfig-path=/etc/X11/xorg.conf.d \
    --documentation-prefix=/opt/nvidia \
    --application-profile-path=/etc/nvidia \
    --no-precompiled-interface \
    --no-distro-scripts \
    --force-libglx-indirect \
    --glvnd-egl-config-path=/etc/glvnd/egl_vendor.d  \
    --no-cc-version-check \
    --egl-external-platform-config-path=/etc/egl/egl_external_platform.d
  