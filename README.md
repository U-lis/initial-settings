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


## TODO
- [x] use user's own .vimrc / .zshrc file 
- [x] change terminal theme in script
- [ ] install with one command like omzsh
