#!/bin/bash
# 출력, 프롬프트, 로깅. 모든 *-settings.sh 가 공유한다.
#
# 여러 번 source 될 수 있으므로 재진입을 막는다.
[ -n "${_INITIAL_SETTINGS_COMMON:-}" ] && return 0
_INITIAL_SETTINGS_COMMON=1

# 파이프나 리다이렉트로 돌 때는 색을 끈다. tput 은 TERM 이 없으면 실패하므로
# 실패를 흘려보내고 빈 문자열로 남긴다.
if [ -t 1 ] && [ -n "${TERM:-}" ] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold 2>/dev/null || true)
  NORM=$(tput sgr0 2>/dev/null || true)
  RED=$(tput setaf 1 2>/dev/null || true)
  GREEN=$(tput setaf 2 2>/dev/null || true)
  YELLOW=$(tput setaf 3 2>/dev/null || true)
  PURPLE=$(tput setaf 5 2>/dev/null || true)
else
  BOLD='' NORM='' RED='' GREEN='' YELLOW='' PURPLE=''
fi

step() { printf '%s==>%s %s\n' "$BOLD" "$NORM" "$*"; }
info() { printf '    %s\n' "$*"; }
ok() { printf '    %s✓%s %s\n' "$GREEN" "$NORM" "$*"; }
warn() { printf '    %s!%s %s\n' "$YELLOW" "$NORM" "$*" >&2; }
err() { printf '    %s✗%s %s\n' "$RED" "$NORM" "$*" >&2; }
note() { printf '%s%s%s\n' "$PURPLE$BOLD" "$*" "$NORM"; }

# 원래 이름이 wait() 였는데 bash 빌트인 wait 를 가렸다.
pause() {
  local _
  read -r -p "Press ENTER to continue... " _ || true
}

# y / s(skip) / N. 반환값: 0=yes, 1=skip, 2=no.
# 비대화형(파이프 입력)에서는 기본값을 그대로 쓴다.
confirm() {
  local prompt="$1" default="${2:-N}" input
  while true; do
    if ! read -r -p "$prompt [y/s/N] (default: $default) " input; then
      input=$default
      echo
    fi
    input=${input:-$default}
    case $input in
    [Yy]*) return 0 ;;
    [Ss]*) return 1 ;;
    [Nn]*) return 2 ;;
    *) warn "y, s, n 중에서 골라라." ;;
    esac
  done
}

# 파일에 줄이 없을 때만 덧붙인다. 재실행해도 중복되지 않는다.
append_once() {
  local file="$1" line="$2"
  [ -f "$file" ] || touch "$file"
  grep -qxF -- "$line" "$file" && return 1
  printf '%s\n' "$line" >>"$file"
}

# 백업을 남기고 파일을 되돌릴 수 있게 한다. 같은 실행 안에서 두 번 부르면
# 처음 것만 남긴다.
backup_once() {
  local file="$1"
  [ -f "$file" ] || return 0
  [ -f "$file.bak" ] && return 0
  cp -p -- "$file" "$file.bak"
  info "백업: $file.bak"
}
