# INITIAL SETTINGS
> Initial Settings for new UNIX/Linux Computer

Shell scripts that set up a development environment on a fresh machine:
git aliases, [zsh](https://www.zsh.org/) with
[oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), and powerline-patched fonts.

Targets Ubuntu 24.04 and 26.04 from one code path — verified on 26.04, and the
24.04 path is taken by feature detection rather than a version check. Every
script is runnable on its own and safe to re-run.

# Introduction
## 0. Requirements
  - Internet connection
  - `apt` (Ubuntu/Debian). Other distros are not supported.
  - `curl` or `wget`, for the oh-my-zsh installer
  - git (optional — you can download the zip instead)


## 1. Installation
```shell script
$ git clone https://github.com/U-lis/initial-settings.git
```
or just download zip file and unzip it.
```shell script
$ cd initial-settings
$ ./install.sh
```
If a permission problem occurs, retry after `$ chmod +x install.sh`, then
follow the menu.

You can also run a single piece without the menu:

```shell script
$ ./git/git-settings.sh
$ ./zsh/zsh-settings.sh agnoster        # theme name is optional
$ ./font/font-settings.sh "Inconsolata-dz for Powerline Medium 12"
```


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
- install oh-my-zsh over HTTPS (the old script used plain HTTP with certificate
  checking disabled)
- set `ZSH_THEME` and `DEFAULT_USER` in `.zshrc` by pattern, not by line number
- offer to change the login shell, using `command -v zsh` and checking
  `/etc/shells` first
- when run from `install.sh`: if the chosen theme needs powerline glyphs
  (`agnoster`, `powerlevel*`, `powerline*`), install the fonts too

### 2.3. install fonts
The bundled fonts come from [powerline/fonts](https://github.com/powerline/fonts)
(archived upstream; [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) is the
maintained successor if you want more glyphs).

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
