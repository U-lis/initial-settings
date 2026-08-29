#!/bin/bash
# git alias 와 기본 에디터 설정.

set -uo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
. "$HERE/../lib/common.sh"
# shellcheck source=lib/detect.sh
. "$HERE/../lib/detect.sh"

if ! has_command git; then
  step "git 이 없다"
  confirm "git 을 설치할까?" Y
  case $? in
  0)
    install_cmd=$(pkg_install_command)
    if [ -z "$install_cmd" ]; then
      err "apt 를 찾지 못했다. git 을 직접 설치해라."
      exit 1
    fi
    $install_cmd git || exit 1
    ok "git 설치"
    ;;
  *)
    info "git 설정을 건너뛴다."
    exit 0
    ;;
  esac
fi

step "git alias 설정"
set_alias() {
  git config --global --replace-all "alias.$1" "$2"
  ok "git $1 == git $2"
}

set_alias co 'checkout'
set_alias st 'status -sb'
set_alias tags 'tag -l'
set_alias br 'branch -a'
set_alias re 'remote -v'
set_alias lg "log --color --graph \
	--pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' \
	--abbrev-commit --"

# 예전에는 vim 을 무조건 박았다. 없는 기계에서 커밋이 막힌다.
step "기본 에디터"
if [ -n "$(git config --global --get core.editor || true)" ]; then
  info "이미 설정돼 있다: $(git config --global --get core.editor)"
elif has_command vim; then
  git config --global core.editor vim
  ok "vim"
else
  info "vim 이 없어 건드리지 않는다. git 기본값(\$EDITOR 또는 nano)을 쓴다."
fi
