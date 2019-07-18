### Systemd Configs

```
/etc/systemd/system.conf,
/etc/systemd/system.conf.d/*.conf,
/run/systemd/system.conf.d/*.conf,
/usr/lib/systemd/system.conf.d/*.conf
```

### Post install

```
# add ping and hexchat
swupd bundle-add hexchat clr-network-troubleshooter

# deletes orca autostart
rm -rf /usr/share/gdm/greeter/autostart/orca.desktop

# for alternative email client
rm -rf /usr/share/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop

# if you don't use gnome-flackbac
rm -rf /usr/share/xdg/autostart/gnome-flackback*

# don't needed if flathub already added
rm -rf /usr/share/xdg/autostart/org.clearlinux.initFlathubRepo.desktop
```

### Services

```
# disable GNOME Software Autostart
echo '#' > /usr/share/dbus-1/services/org.gnome.Software.service

# disable coredumps
echo 'Storage=none' > /etc/systemd/coredump.conf
```

```
# use `systemctl cat .service` if not sure

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

# must have for SSD
systemctl enable fstrim.timer
```

### Apps

GNOME Clocks - hacky way to install:

```
rpm -ivh --nodeps /tmp/gnome-clocks-3.32.0-1.fc30.x86_64.rpm
```

### Flatpak dark theme by default

Add `Exec=env GTK_THEME=Adwaita:dark ...` to every `.desktop` in `~/.local/share/flatpak/exports/share`.
