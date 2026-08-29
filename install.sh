#!/bin/bash
# 새 기계 초기 설정.
#
# 버전 분기는 하지 않는다. 무엇이 설치돼 있는지로 판단한다 (lib/detect.sh).

set -uo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"
# shellcheck source=lib/detect.sh
. "$HERE/lib/detect.sh"

# agnoster 처럼 powerline 글리프를 쓰는 테마. 걸리면 폰트도 같이 깐다.
# [[ =~ ]] 용 정규식. case 패턴으로 쓰면 변수 안의 | 가 대안으로 안 읽힌다.
POWERLINE_THEMES='agnoster|powerlevel|powerline'
POWERLINE_FONT='Inconsolata-dz for Powerline Medium 12'

install_git() { bash "$HERE/git/git-settings.sh"; }

install_zsh() {
  bash "$HERE/zsh/zsh-settings.sh" || return $?
  # 예전에는 zsh-settings.sh 가 종료 코드 1/2 로 테마를 알렸다. .zshrc 에서
  # 직접 읽는 편이 스크립트를 따로 돌렸을 때도 맞는다.
  # 파이프로 head/grep 에 넘기면 SIGPIPE 가 pipefail 에 걸린다 (lib/detect.sh 참고).
  local theme
  theme=$(sed -n 's/^ZSH_THEME=["'"'"']\?\([^"'"'"']*\)["'"'"']\?.*/\1/p' "$HOME/.zshrc" 2>/dev/null)
  theme=${theme%%$'\n'*}
  if [[ $theme =~ $POWERLINE_THEMES ]]; then
    info "테마 '$theme' 는 powerline 글리프를 쓴다. 폰트도 설치한다."
    install_font "$POWERLINE_FONT"
  fi
}

install_font() { bash "$HERE/font/font-settings.sh" "${1:-}"; }

# poetry 는 26.04 에서 죽는다. uv 로 교체 예정 (issue #8). 그때까지 그대로 둔다.
install_poetry() {
  if ! has_command python3; then
    err "poetry 는 Python 3 이 필요하다. 먼저 설치해라."
    return 1
  fi
  warn "poetry 스크립트는 24.04 기준이다. 26.04 에서는 실패할 수 있다 (issue #8)."
  bash "$HERE/poetry/poetry-settings.sh"
}

main_menu() {
  while true; do
    clear
    printf '%sinitial-settings%s\n' "$BOLD" "$NORM"
    info "$(os_field PRETTY_NAME)  /  터미널: $(detect_terminal)"
    echo
    echo "  1) 전부 (git, zsh, 폰트)   [기본]"
    echo "  2) git alias"
    echo "  3) zsh + oh-my-zsh + 폰트"
    echo "  4) powerline 폰트만"
    echo "  5) poetry  (구버전, issue #8)"
    echo "  0) 종료"
    echo
    local input
    read -r -p "선택: " input || exit 0
    case ${input:-1} in
    0) exit 0 ;;
    1)
      install_git
      pause
      install_zsh
      pause
      note "기본 셸 변경은 다음 로그인부터 적용된다."
      ;;
    2) install_git ;;
    3) install_zsh ;;
    4) install_font "$POWERLINE_FONT" ;;
    5) install_poetry ;;
    *)
      warn "0에서 5 사이로 골라라."
      ;;
    esac
    pause
  done
}

# 예전에는 SYSTEM_TYPE 에 'NOT VALID. This script...' 를 넣고 = 'NOT VALID' 로
# 비교해서 이 분기가 절대 안 잡혔다. 비 Linux 에서 INSTALL_COMMAND 가 빈 채로
# 진행됐다. macOS 분기는 주석으로만 남아 있어 지웠다.
if [ "$(uname)" != 'Linux' ]; then
  err "이 스크립트는 Linux(apt 계열)만 지원한다. 현재: $(uname)"
  exit 1
fi
if [ -z "$(pkg_install_command)" ]; then
  warn "apt 를 찾지 못했다. 패키지 설치가 필요한 항목은 실패한다."
  pause
fi

main_menu
