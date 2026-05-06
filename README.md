# INITIAL SETTINGS
> Initial Settings for new UNIX/Linux Computer

This Repo contains some script for basic develop environment settings.
With this, You can set this:
 1. set git aliases (See 2.1)
 2. set zshrc with install [zsh](http://www.zsh.org/), [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
 3. Install [powerline font](https://github.com/Lokaltog/powerline-fonts)
 4. Install 3beol forks of [libhangul](https://gitlab.com/3beol/libhangul) +
    [ibus-hangul](https://gitlab.com/3beol/ibus-hangul) for 세모이 (Sebeolsik
    Semoe) keyboards with 한 번에 모아치기 input mode (See 2.4)

# Introduction
## 0. Requirements
  - Internet connection
  - git (optional)


## 1. Installation
```shell script
$ git clone https://github.com/U-lis/initial-settings.git
```
or just download zip file and unzip it.
```shell script
$ cd initial-settings
$ ./install.sh
```
If permission problem occurs, retry after `$ chmod +x install.sh`  
follow introductions


## 2. Contents
### 2.1. git alias list
- git co == git checkout
- git st == git status -sb
- git tags == git tag -l
- git br == git branch -a
- git re == git remote -v
- git lg == git log (one line pretty format with branch tree)

### 2.2. zshrc
- install zsh
- install oh-my-zsh
- set `.zshrc`
- install powerline-fonts(Inconsolata-dz, DejaVu Sans Mono)

### 2.3. install fonts
- copy font files in user's local font directory
- These fonts enable zsh agnoster theme / vim-powerline plugin with pretty format

### 2.4. install 3beol libhangul + ibus-hangul (세모이 자판)
Builds and installs [3beol's forks](https://gitlab.com/3beol) of `libhangul`
and `ibus-hangul` so 세모이 (Sebeolsik Semoe) 한 번에 모아치기 keyboards work
through ibus.

- apt installs build deps: `build-essential autoconf automake libtool intltool
  autopoint pkg-config gettext libexpat1-dev libibus-1.0-dev libgtk-3-dev`
- clones `gitlab.com/3beol/libhangul` and `gitlab.com/3beol/ibus-hangul` to
  `~/Downloads/` (override with `HANGUL_WORK_DIR=...`)
- libhangul is installed to `/usr/local` (apt's `libhangul1` left untouched —
  ldconfig prefers `/usr/local/lib`)
- ibus-hangul is installed to `/usr` with `--libexecdir=/usr/libexec`,
  overwriting the apt `ibus-hangul` package files. Optionally `apt-mark hold`
  can pin the package to prevent apt upgrades from reverting the build.
- Sets `gsettings org.freedesktop.ibus.engine.hangul use-event-forwarding
  false` (required: with the schema default `true`, space and backspace are
  silently dropped on ibus 1.5.34-rc2 + 3beol ibus-hangul 1.5.4).
- Optionally sets `hangul-keyboard = '3moa-semoe-2018'`.

To revert: `sudo apt install --reinstall ibus-hangul` and `sudo apt-mark
unhold ibus-hangul` (and `sudo make uninstall` from the libhangul checkout).


## TODO
- [x] use user's own .vimrc / .zshrc file 
- [x] change terminal theme in script
- [ ] install with one command like omzsh
