#!/bin/bash
# zsh + oh-my-zsh 설치와 .zshrc 설정.
#
# $1 — 쓸 테마 이름 (비면 물어본다)

set -uo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
. "$HERE/../lib/common.sh"
# shellcheck source=lib/detect.sh
. "$HERE/../lib/detect.sh"

DEFAULT_THEME='agnoster'
ZSHRC="$HOME/.zshrc"

if ! has_command zsh; then
  step "zsh 가 없다"
  confirm "zsh 를 설치할까?" Y
  case $? in
  0)
    install_cmd=$(pkg_install_command)
    if [ -z "$install_cmd" ]; then
      err "apt 를 찾지 못했다. zsh 를 직접 설치해라."
      exit 1
    fi
    $install_cmd zsh zsh-common zsh-doc || exit 1
    ok "zsh 설치"
    ;;
  *)
    info "zsh 설정을 건너뛴다."
    exit 0
    ;;
  esac
fi

step "oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  info "이미 있다: $HOME/.oh-my-zsh"
else
  # 예전에는 평문 HTTP(install.ohmyz.sh)로 받으면서 --no-check-certificate 로
  # 인증서 검증까지 껐다. 정식 HTTPS URL 을 쓴다.
  url='https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh'
  if has_command curl; then
    fetch=(curl -fsSL "$url")
  elif has_command wget; then
    fetch=(wget -qO- "$url")
  else
    err "curl 도 wget 도 없다."
    exit 1
  fi
  # --unattended: 설치 스크립트가 chsh 를 하거나 zsh 를 띄우지 않게 한다.
  # 셸 변경은 아래에서 직접 처리한다.
  if ! "${fetch[@]}" | RUNZSH=no CHSH=no sh -s -- --unattended; then
    err "oh-my-zsh 설치 실패"
    exit 1
  fi
  ok "oh-my-zsh 설치"
fi

step "테마"
theme=${1:-}
if [ -z "$theme" ]; then
  info "기본값은 $DEFAULT_THEME 다."
  read -r -p "테마 이름 (그냥 ENTER 면 $DEFAULT_THEME): " theme || true
  theme=${theme:-$DEFAULT_THEME}
fi

if [ ! -f "$ZSHRC" ]; then
  template="$HOME/.oh-my-zsh/templates/zshrc.zsh-template"
  if [ -f "$template" ]; then
    cp -- "$template" "$ZSHRC"
    ok ".zshrc 를 oh-my-zsh 템플릿에서 만들었다"
  else
    err "$template 이 없다. .zshrc 를 만들 수 없다."
    exit 1
  fi
fi

backup_once "$ZSHRC"
# 예전에는 `sed "11s/.*/ZSH_THEME=..."` 로 11번째 줄을 통째로 덮어썼다.
# 템플릿이 한 줄만 밀려도 엉뚱한 줄이 날아간다. 패턴으로 바꾼다.
if grep -qE '^ZSH_THEME=' "$ZSHRC"; then
  sed -i -E "s|^ZSH_THEME=.*|ZSH_THEME=\"$theme\"|" "$ZSHRC"
else
  append_once "$ZSHRC" "ZSH_THEME=\"$theme\""
fi
ok "ZSH_THEME=\"$theme\""

if append_once "$ZSHRC" "DEFAULT_USER=$(id -un)"; then
  ok "DEFAULT_USER=$(id -un)"
else
  info "DEFAULT_USER 는 이미 있다"
fi

step "기본 셸"
zsh_path=$(command -v zsh)
current_shell=$(getent passwd "$(id -un)" | cut -d: -f7)
if [ "$current_shell" = "$zsh_path" ]; then
  info "이미 zsh 다: $zsh_path"
elif ! grep -qxF -- "$zsh_path" /etc/shells; then
  # 예전에는 /bin/zsh 를 하드코딩했다. 배포판마다 경로가 다르다.
  warn "$zsh_path 가 /etc/shells 에 없어 chsh 가 거부한다. 직접 등록해라."
else
  # confirm 은 0=yes / 1=skip / 2=no 인데 여기서는 yes 인지만 보면 된다.
  if confirm "기본 셸을 $zsh_path 로 바꿀까? (비밀번호를 묻는다)" Y; then
    if chsh -s "$zsh_path"; then
      ok "기본 셸 변경. 다음 로그인부터 적용된다."
    else
      warn "chsh 실패. 'chsh -s $zsh_path' 를 직접 실행해라."
    fi
  fi
fi
