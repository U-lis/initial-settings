# INITIAL SETTINGS
> Initial Settings for new UNIX/Linux Computer

This Repo contains some script for basic develop environment settings.
With this, You can set this:
 1. set git aliases (See 2.1)
 2. set zshrc with install [zsh](http://www.zsh.org/), [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
 3. Install [powerline font](https://github.com/Lokaltog/powerline-fonts)

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

Version differences are handled by **feature detection**, not by Ubuntu version
numbers — `lib/detect.sh` asks what is installed (`command -v`, gsettings schema,
apt candidate) instead of branching on `VERSION_ID`. This keeps 24.04 and 26.04
on the same code path and survives the next release.

| Path | What |
|---|---|
| `lib/common.sh` | colors, prompts, logging, idempotent file edits |
| `lib/detect.sh` | feature detection: commands, gsettings schemas, apt, terminal |
| `git/git-settings.sh` | git aliases and default editor |
| `zsh/zsh-settings.sh` | zsh, oh-my-zsh, `.zshrc`, login shell |
| `font/font-settings.sh` | powerline fonts, terminal font (Ptyxis or gnome-terminal) |
| `poetry/poetry-settings.sh` | **outdated**, fails on 26.04 — being replaced by uv (issue #8) |

Every script is runnable on its own and safe to re-run.

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
- copy font files into `~/.local/share/fonts` (no sudo needed)
- set the terminal font, detecting Ptyxis (26.04 default) or gnome-terminal
  (24.04 default); skipped when neither is present
- These fonts enable zsh agnoster theme / vim-powerline plugin with pretty format


## TODO
- [x] use user's own .vimrc / .zshrc file
- [x] change terminal theme in script
- [x] support 24.04 and 26.04 from one code path
- [ ] install with one command like omzsh
- [ ] replace poetry with uv — U-lis/initial-settings#8
