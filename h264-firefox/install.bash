#!/usr/bin/env bash

## References:
## https://community.clearlinux.org/t/how-to-h264-etc-support-for-firefox-including-ffmpeg-install

## Install dependencies
echo -e "\e[33m\xe2\x8f\xb3 Install the following dependencies: 'c-basic', 'devpkg-libva', and 'git' ...\e[m"
sudo swupd bundle-add c-basic devpkg-libva git

## Clone the ffmpeg git repository if it doesn't exist; or update it if it exists
echo -e "\e[33m\xe2\x8f\xb3 Get latest FFmpeg source repository ...\e[m"
if [ -d "FFmpeg" ];then
  # shellcheck disable=SC2164
  cd FFmpeg
  git fetch
else
  git clone https://github.com/FFmpeg/FFmpeg
  # shellcheck disable=SC2164
  cd FFmpeg
fi

## Get the latest non-dev release
echo -e "\e[33m\xe2\x8f\xb3 Checkout the latest non-dev release ...\e[m"
git checkout tags/"$(git tag -l | sed -n -E '/^n[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$/p' | sort | tail -1)"

## Build FFmpeg, which would be installed under /opt/ffmpeg
echo -e "\e[33m\xe2\x8f\xb3 Building ...\e[m"
echo -e "\e[32m If the installation is successful, it would be available under \e[33m/opt/ffmpeg\e[32m.\e[m"
read -rp "Press any key to continue ... " -n1 -s
echo
if ! ./configure --prefix=/opt/ffmpeg --enable-shared || ! make || ! sudo make install; then
  echo -e "\e[31m Installation failed! Aborting...\e[m"
  exit 1
fi

## Configure the dynamic linker configuration to include /opt/ffmpeg/lib
echo -e "\e[33m\xe2\x8f\xb3 Configuring dynamic linker configuration ...\e[m"
if [ ! -f /etc/ld.so.conf ] || \
  grep -q 'include /etc/ld\.so\.conf\.d/\*\.conf' /etc/ld.so.conf; then
  printf "include /etc/ld.so.conf.d/*.conf" | sudo tee -a /etc/ld.so.conf
fi
if [ ! -d /etc/ld.so.conf.d ]; then
  sudo mkdir /etc/ld.so.conf.d
fi
if [ ! -f /etc/ld.so.conf.d/ffmpeg.conf ] || \
  ! grep -q '/opt/ffmpeg/lib' /etc/ld.so.conf.d/ffmpeg.conf; then
  echo "/opt/ffmpeg/lib" | sudo tee /etc/ld.so.conf.d/ffmpeg.conf
fi
echo -e "\e[32m Updating dynamic linker run-time bindings and library cache ...\e[m"
sudo ldconfig

## Add ffmpeg to library path of Firefox
echo -e "\e[33m\xe2\x8f\xb3 Add FFmpeg to libarry path of Firefox ...\e[m"
if [ ! -f "${HOME}/.config/firefox.conf" ] || \
  grep -q 'export LD_LIBRARY_PATH' "${HOME}/.config/firefox.conf"; then
  echo "export LD_LIBRARY_PATH=/opt/ffmpeg/lib" >> "${HOME}/.config/firefox.conf"
else
  grep -q 'export LD_LIBRARY_PATH=.*/opt/ffmpeg/lib.*' "${HOME}/.config/firefox.conf" \
      || sed -i 's#export LD_LIBRARY_PATH=#&/opt/ffmpeg/lib:#' "${HOME}/.config/firefox.conf"
fi
