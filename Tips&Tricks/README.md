### The Clear Linux Installer partition names convention
* CLR_BOOT
* CLR_SWAP
* CLR_ROOT
* CLR_HOME
* CLR_MNT_/home


### Use swupd state in tmpfs to speedup update
Very good solution if you use slow HDD or SSD, also can save some wear on SSD

```bash
# cp -r /var/lib/swupd /tmp/swupd
# swupd update -S /tmp/swupd && swupd 3rd-party update -S /tmp/swupd
# rm -rf /var/lib/swupd
# mv /tmp/swupd /var/lib/swupd
```

### Post install

```
# delete orca autostart
rm -rf /usr/share/gdm/greeter/autostart/orca.desktop

# useless if you're not an Evolution user
rm -rf /usr/share/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop

# if you don't use gnome-flackback
rm -rf /usr/share/xdg/autostart/gnome-flackback*

# don't needed if flathub already added
rm -rf /usr/share/xdg/autostart/org.clearlinux.initFlathubRepo.desktop
```

### Service tweaks
```
# disable GNOME Software autostart
echo '#' > /usr/share/dbus-1/services/org.gnome.Software.service

# disable coredump service
ln -sf /dev/null /usr/lib/sysctl.d/50-coredump.conf
```
```
systemctl mask cupsd.service
systemctl mask mcelog.service
systemctl mask pacdiscovery.service
systemctl mask pacrunner.service
systemctl mask swupd-overdue.service
systemctl mask wpa_supplicant.service
systemctl mask cupsd.socket
systemctl mask pcscd.socket
systemctl mask motd-update.path 
systemctl mask pacdiscovery.path 
systemctl mask cupsd.service
systemctl mask mcelog.service
systemctl mask ModemManager.service 
systemctl mask swap.target
systemctl mask packagekit.service
systemctl mask packagekit-offline-update.service

# must-have for SSD
systemctl enable fstrim.timer
```
```
# disable journal storage
vi /usr/lib/systemd/journald.conf.d/*.conf
Storage=volatile
```

### Fonts load fix for many apps 

```
f=/etc/environment; s='export FONTCONFIG_PATH=/usr/share/defaults/fonts'; touch $f; if ! grep -q "$s" $f; then echo $s >> $f; fi

# Wayland
echo 'FONTCONFIG_PATH=/usr/share/defaults/fonts' > ~/.config/environment.d/envvars.conf

# X11
echo 'export FONTCONFIG_PATH=/usr/share/defaults/fonts' > ~/.xinitrc
```

### Flatpak dark theme fix

Add `Exec=env GTK_THEME=Adwaita:dark ...` to every `.desktop` in `~/.local/share/flatpak/exports/share`.


### Add Nautilus 'New File' menu

`touch ~/Templates/"Untitled Document"`

### All systemd config paths

```
/etc/systemd/system.conf,
/etc/systemd/system.conf.d/*.conf,
/run/systemd/system.conf.d/*.conf,
/usr/lib/systemd/system.conf.d/*.conf
```

### Powersave

Clear performance mode is totally overkill for laptops, this guide designed to improve the situation and get better time usage with battery.

Disable Clear Linux OS enforcement of certain power and performance settings: `sudo systemctl mask clr-power.timer`

Disable turbo boost: `echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo`

`vim /etc/systemd/system/powersave.service`
```
[Unit]
Description=Set CPU performance governor

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c "echo active > /sys/devices/system/cpu/intel_pstate/status; echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
ExecStop=/bin/bash -c "echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"

[Install]
WantedBy=multi-user.target
```

```
systemctl start powersave && systemctl enable powersave
```

```
mkdir -p /etc/kernel/cmdline.d
echo "pcie_aspm.policy=powersupersave" | tee /etc/kernel/cmdline.d/aspm.conf
clr-boot-manager update
```

Powertop service:

```
wget https://src.fedoraproject.org/rpms/powertop/raw/main/f/powertop.service
mv powertop.service /etc/systemd/system
systemctl daemon-reload
systemctl enable powertop
```


### Network manager

* "Allow password only for this user" to increase security - NM store passwords in plain configs by default, not the best decison
* Add `autoconnect-priority=1` `autoconnect-retries=10` to prefered connection config for better stability
* Set `dhcp-send-hostname=false` for both `[ipv4]` & `[ipv6]` - great for privacy
* Enable `iwd` backend and systemd-resolved
```
[device]
wifi.backend=iwd

[main]
dns=systemd-resolved
```

### DoT setup

`vi /etc/systemd/resolved.conf.d/dns_over_tls.conf`
```
DNSOverTLS=yes
DNS=9.9.9.9#dns.quad9.net
```

Avoid Google fallback DNS 

`vi /etc/systemd/resolved.conf.d/fallback_dns.conf` 
```
[Resolve]
FallbackDNS=1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001

# to disable fallback completely
FallbackDNS=
```
`systemctl restart systemd-resolved.service`


# macOS-like fonts

Based on https://aswinmohan.me/posts/better-fonts-on-linux/

```
# vim /etc/fonts/local.conf

<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>

<match target="font">
  <edit name="autohint" mode="assign">
    <bool>true</bool>
  </edit>
  <edit name="hinting" mode="assign">
    <bool>true</bool>
  </edit>
  <edit mode="assign" name="hintstyle">
    <const>hintslight</const>
  </edit>
  <edit mode="assign" name="lcdfilter">
   <const>lcddefault</const>
 </edit>
</match>


<!-- Default sans-serif font -->
 <match target="pattern">
   <test qual="any" name="family"><string>-apple-system</string></test>
   <!--<test qual="any" name="lang"><string>ja</string></test>-->
   <edit name="family" mode="prepend" binding="same"><string>Tex Gyre Heros</string>  </edit>
 </match>

 <match target="pattern">
   <test qual="any" name="family"><string>Helvetica Neue</string></test>
   <!--<test qual="any" name="lang"><string>ja</string></test>-->
   <edit name="family" mode="prepend" binding="same"><string>Tex Gyre Heros</string>  </edit>
 </match>

 <match target="pattern">
   <test qual="any" name="family"><string>Helvetica</string></test>
   <!--<test qual="any" name="lang"><string>ja</string></test>-->
   <edit name="family" mode="prepend" binding="same"><string>Tex Gyre Heros</string>  </edit>
 </match>

 <match target="pattern">
   <test qual="any" name="family"><string>arial</string></test>
   <!--<test qual="any" name="lang"><string>ja</string></test>-->
   <edit name="family" mode="prepend" binding="same"><string>Tex Gyre Heros</string>  </edit>
 </match>

 <match target="pattern">
   <test qual="any" name="family"><string>sans-serif</string></test>
   <!--<test qual="any" name="lang"><string>ja</string></test>-->
   <edit name="family" mode="prepend" binding="same"><string>Tex Gyre Heros</string>  </edit>
 </match>
 
<!-- Default serif fonts -->
 <match target="pattern">
   <test qual="any" name="family"><string>serif</string></test>
   <edit name="family" mode="prepend" binding="same"><string>Libertinus Serif</string>  </edit>
   <edit name="family" mode="prepend" binding="same"><string>Noto Serif</string>  </edit>
   <edit name="family" mode="prepend" binding="same"><string>Noto Color Emoji</string>  </edit>
   <edit name="family" mode="append" binding="same"><string>IPAPMincho</string>  </edit>
   <edit name="family" mode="append" binding="same"><string>HanaMinA</string>  </edit>
 </match>

<!-- Default monospace fonts -->
 <match target="pattern">
   <test qual="any" name="family"><string>SFMono-Regular</string></test>
   <edit name="family" mode="prepend" binding="same"><string>DM Mono</string></edit>
   <edit name="family" mode="prepend" binding="same"><string>Space Mono</string></edit>
   <edit name="family" mode="append" binding="same"><string>Inconsolatazi4</string></edit>
   <edit name="family" mode="append" binding="same"><string>IPAGothic</string></edit>
 </match>

 <match target="pattern">
   <test qual="any" name="family"><string>Menlo</string></test>
   <edit name="family" mode="prepend" binding="same"><string>DM Mono</string></edit>
   <edit name="family" mode="prepend" binding="same"><string>Space Mono</string></edit>
   <edit name="family" mode="append" binding="same"><string>Inconsolatazi4</string></edit>
   <edit name="family" mode="append" binding="same"><string>IPAGothic</string></edit>
 </match>

 <match target="pattern">
   <test qual="any" name="family"><string>monospace</string></test>
   <edit name="family" mode="prepend" binding="same"><string>DM Mono</string></edit>
   <edit name="family" mode="prepend" binding="same"><string>Space Mono</string></edit>
   <edit name="family" mode="append" binding="same"><string>Inconsolatazi4</string></edit>
   <edit name="family" mode="append" binding="same"><string>IPAGothic</string></edit>
 </match>

<!-- Fallback fonts preference order -->
 <alias>
  <family>sans-serif</family>
  <prefer>
   <family>Noto Sans</family>
   <family>Noto Color Emoji</family>
   <family>Noto Emoji</family>
   <family>Open Sans</family>
   <family>Droid Sans</family>
   <family>Ubuntu</family>
   <family>Roboto</family>
   <family>NotoSansCJK</family>
   <family>Source Han Sans JP</family>
   <family>IPAPGothic</family>
   <family>VL PGothic</family>
   <family>Koruri</family>
  </prefer>
 </alias>
 <alias>
  <family>serif</family>
  <prefer>
   <family>Noto Serif</family>
   <family>Noto Color Emoji</family>
   <family>Noto Emoji</family>
   <family>Droid Serif</family>
   <family>Roboto Slab</family>
   <family>IPAPMincho</family>
  </prefer>
 </alias>
 <alias>
  <family>monospace</family>
  <prefer>
   <family>Noto Sans Mono</family>
   <family>Noto Color Emoji</family>
   <family>Noto Emoji</family>
   <family>Inconsolatazi4</family>
   <family>Ubuntu Mono</family>
   <family>Droid Sans Mono</family>
   <family>Roboto Mono</family>
   <family>IPAGothic</family>
  </prefer>
 </alias>

</fontconfig>
```
Browser -> Settings -> Select Customize Fonts under Appearences -> Choose SF fonts
