## Overview

Currently, the shell default shell startup files for `sh` (Bourne shell), `bash` (Bash), and `zsh` (Z Shell) are rather messy in the sense that:
- The environment variables are set differently
- Some functionalities are not available for `zsh` while it's feasible to achieve them in `zsh`
- Scripts are sourcing each other, which is redundant
- `zsh` has an entirely different set of startup files as oppose to `sh` and `bash`, but actually most statement in the startup files are compatible to all of the three shells.
- The default global startup files are stored in `/usr/share/defaults/etc/`, and an average user may not be aware of them.

## Loading process of startup files

A summary of how the startup files are processed by the three shells on Clear Linux (Version 29480) is given below

### `sh`

The `sh` non-login shell doesn't seem to load any startup files, while the `sh` login shell would look for the global profile and user profile at `/usr/share/defaults/etc/profile` and `~/.profile` respectively. Both of them are created by default.

### `bash`

The `bash` login shell first looks for the global profile and user profile in the same path as `sh` login shell does. But there exists either `~/.bash_profile` or `~/.bash_login`, `~/.profile` will not be sourced. When the user logout from `bash` login shell, it also executes `~/.bash_logout`, who does not exist by default.

The `bash` non-login shell first source the global `bash` configuration at `/usr/share/defaults/etc/bash.bashrc` and then the user configuration at `~/.bashrc`.

### `zsh`

There are five types of startup files for `zsh`, which are `env`, `zprofile`, `zshrc`, `zlogin`, and `zlogout` respectively. For each of the five types, `zsh` login shell would look for a global configuration in `/usr/share/defaults/etc/<TYPE>`, and then the user's configuration in `~/.<TYPE>`, in that order. And a `zsh` non-login in shell only process `env` and `zshrc` files.

Currently, the default global `env`, `zshrc`, and `zlogin` are created when installing `zsh`, but no local startup file is created.

## Current default startup files

### `/usr/share/defaults/etc/profile`

This file sets various environment variables, set-up the prompt, and source the shell scripts under `/usr/share/defaults/etc/profile.d/`, which are created by default. And if the system admin could make overrides by creating `/etc/profile`, and putting scripts under `/etc/profile.d/`, which would be sourced by `/usr/share/defaults/etc/profile` if they exist.

This file is sourced by

- `sh` login shell
- `sh` non-login shell (via `~/.profile`)
- `bash` login shell for twice, where the second time is via `~/.profile`
- `bash` non-login shell for twice, via `/usr/share/defaults/etc/bash.bashrc` and `~/.bashrc` respectively.

#### `/usr/share/defaults/etc/profile.d/*`

There are 7 files in this directory and they’re sourced by `/usr/share/defaults/etc/profile`.

- `10-command-not-found.sh`,  provides similar functionality as `command-not-found` in `Ubuntu`.

- `50-swupd.bash`, and `bash_completion.sh` provides auto-completion for `bash`.

- `50-colors.sh` colourise the output of `ls` command, and also set the colours for GCC compilation flags.

- `50-prompt` colourise the prompt defined in `/usr/share/defaults/etc/profile`.

- `ccache.sh` add `/usr/lib64/ccache/bin` to accelerate GCC compilation.

- `flatpak.sh` sets up directories so that apps installed via `flatpak` would correctly show up in `gnome`.

### `~/.profile`

It sources `~/.bashrc`, which sources ``/usr/share/defaults/etc/profile`. Thus its redundant.

This file is sourced by

- `sh` non-login shell
- `bash` login shell (when neither `~/.bash_profile` nor `~/.bash_login` is available, which is the default)

### `/usr/share/defaults/etc/profile.d/*`

There are 7 files in this directory and they’re sourced by `/usr/share/defaults/etc/profile`.

`10-command-not-found.sh`,  provides similar functionality as `command-not-found` in `Ubuntu`.

`50-swupd.bash`, and `bash_completion.sh` provides auto-completion for `bash`.

`50-colors.sh` colourise the output of `ls` command, and also set the colours for GCC compilation flags.

`50-prompt` colourise the prompt defined in `/usr/share/defaults/etc/profile`.

`ccache.sh` add `/usr/lib64/ccache/bin` to accelerate GCC compilation.

`flatpak.sh` sets up directories so that apps installed via `flatpak` would correctly show up in `gnome`.

### `/usr/share/defaults/etc/bash.bashrc`

It sources the global profile `/usr/share/defaults/etc/profile`. It also allow admin overrides by sourcing  `/etc/profile`, which is redundant.

It’s sourced by

- `bash` non-login shell for twice, where the second time is via `~/.bashrc`

### `~/.bashrc`

Identical to `/usr/share/defaults/etc/bash.bashrc`, which makes it redundant.

It’s sourced by

- `bash` non-login shell

### `/usr/share/defaults/etc/zshenv`

It sets environment variables who are mostly identical to those set by  `/usr/share/defaults/etc/profile`. It also allows admin overrides by sourcing `/etc/zshenv`

But notice that, various GCC flags and the `PATH` are not exactly the same.

It’s sourced by

- `zsh` login shell
- `zsh` non-login shell

### `/usr/share/defaults/etc/zshrc`

It sets aliases, keybindings, and the prompt for `zsh` shell.

It’s sourced by

- `zsh` login shell
- `zsh` non-login shell

### `/usr/share/defaults/etc/zlogin`

Itself does not do anything but sourcing `/etc/zlogin` to allow admin overrides.

It’s sourced by

- `zsh` login shell
- `zsh` non-login shell

## Solution

1.  `sh` shell is the least flexible one here that it only sources global and local profiles for its login shell. We can keep the global profile `/usr/share/defaults/etc/profile` but delete the user profile `~/.profile`, which just sources the global one in default.

   Then `/usr/share/defaults/etc/profile` would be the only startup file for `sh` login shell, therefore it shall contain the most critical environment variables to ensure its proper behaviours.

   In addition to environment variables,  `/usr/share/defaults/etc/profile` also source the files under `/usr/share/defaults/etc/profile.d/`, which provides additional functionality to login shell when the machine is connected to via SSH, if the login shell is `sh` or `bash`.

2. As for `bash` login shell, it always reads `/usr/share/defaults/etc/profile`. Thus removing `~/.profile` will not cause any problem for `bash` login shell as well.

   Similarly, `/usr/share/defaults/etc/bash.bashrc` and `~/.bashrc` are identical, and we can safely remove the latter one.

   `/usr/share/defaults/etc/bash.bashrc` is sourced by non-login shell, so it’s sensible to have it to source `/usr/share/defaults/etc/profile` , which will setup environment variables and also provide the same functionality as login shell.

3. `zlogin` are sourced only in login shells, while `zshenv` are sourced in all invocations of `zsh` shells and is always sourced first. Thus the default `zlogin` shall not do anything other than taking admin overrides from `/etc/zlogin`. It is the status quo and no change need to be made.

   Then `/usr/share/defaults/etc/zshenv` shall be responsible for setting things up as much as `/usr/share/defaults/etc/profile` does for `sh` and `bash` shells.

   This also implies that we might have `/usr/share/defaults/etc/zshrc` only to take admin overrides from `/etc/zshrc`.

   One way to achieve this is to modify `/usr/share/defaults/etc/zshenv` so that it achieve similar result to `/usr/share/defaults/etc/profile`. But this requires developers to maintain those two files separately, which is likely to introduce problems in the future.

   Alternatively, we can just have `/usr/share/defaults/etc/zshenv`  to source `/usr/share/defaults/etc/profile`, but this requires us to deal with the compatibility issues.

   Fortunately this is not hard to do.

## Goal

In summary, this project is going to achieve the following:

1. All system-wide default startup files stay in `/usr/share/defaults/etc/profile`,  where
   - `/usr/share/defaults/etc/profile` is responsible for setting up environment variables and provide extended functionalities such as command completions. It shall also execute different blocks based on the shell, which is acquired by `echo $0`, so that it’s compatible to all of `sh`, `bash`, and `zsh`.
   - `/usr/share/defaults/etc/profile` is directly sourced by `sh` and `bash`, while it’s sourced by `zsh` via `/usr/share/defaults/etc/zshenv`.
   - `/usr/share/defaults/etc/profile` additionally takes admin overrides from `/etc/profile` and `/etc/profile.d/*`.
   - `/usr/share/defaults/etc/bash.bashrc` shall source `/usr/share/defaults/profile` and does nothing else.
   - Similarly, `/usr/share/defaults/etc/zshenv` shall take admin overrides from `/etc/zshenv`, in addition to sourcing `/usr/share/defaults/etc/profile`.
   - `/usr/share/defaults/etc/zlogin` and `/usr/share/defaults/etc/zshrc` shall do nothing except from taking admin overrides from `/etc/zlogin` and `/etc/zshrc`, respectively.
   - No user default startup files shall be created.
2. Scripts under `/usr/share/defaults/etc/profile.d/` shall be modified to achieve compatibility in `zsh`.
3. `/etc` is where system admin can put startup files to override the system-wide defaults. And user’s local startup files are stored in the `$HOME` directory.