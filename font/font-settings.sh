#!/bin/bash
# powerline 패치 폰트를 설치하고, 가능하면 터미널 폰트로 지정한다.
#
# $1 — 지정할 폰트 이름 (비면 설치만 하고 안내로 끝낸다)

set -uo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
. "$HERE/../lib/common.sh"
# shellcheck source=lib/detect.sh
. "$HERE/../lib/detect.sh"

FONT_NAME=${1:-}
# 예전에는 sudo 로 /usr/share/fonts/truetype 에 넣었다. 사용자 단위 설치면
# ~/.local/share/fonts 로 충분하고 sudo 가 필요 없다.
FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"

step "powerline 폰트 설치"
mkdir -p -- "$FONT_DIR"
installed=0
for font in "$HERE"/*.ttf "$HERE"/*.otf; do
  [ -e "$font" ] || continue
  cp -- "$font" "$FONT_DIR/"
  ok "$(basename -- "$font")"
  installed=1
done

if [ "$installed" = 0 ]; then
  err "$HERE 에 폰트 파일이 없다."
  exit 1
fi

if has_command fc-cache; then
  fc-cache -f "$FONT_DIR" >/dev/null
  ok "폰트 캐시 갱신"
else
  warn "fc-cache 가 없다. 폰트가 잡히려면 재로그인이 필요할 수 있다."
fi

if [ -z "$FONT_NAME" ]; then
  info "터미널 폰트는 직접 지정해라."
  exit 0
fi

# gconftool-2(GNOME 2)와 gnome-shell 버전 파싱 분기는 지웠다. 전자는 없어진 지
# 오래고, 후자는 gnome-shell 이 없는 환경에서 빈 문자열 비교로 죽었다.
step "터미널 폰트 지정: $FONT_NAME"
terminal=$(detect_terminal)
case $terminal in
ptyxis)
  # Ptyxis 는 폰트가 프로파일별이 아니라 전역이다. 팔레트만 프로파일별이다.
  gsettings set org.gnome.Ptyxis use-system-font false
  gsettings set org.gnome.Ptyxis font-name "$FONT_NAME"
  ok "Ptyxis 폰트 지정"
  ;;
gnome-terminal)
  if path=$(gnome_terminal_profile_path); then
    gsettings set "$path" use-system-font false
    gsettings set "$path" font "$FONT_NAME"
    ok "gnome-terminal 폰트 지정"
  else
    warn "gnome-terminal 기본 프로파일을 찾지 못했다. 직접 지정해라."
  fi
  ;;
none)
  info "Ptyxis / gnome-terminal 을 찾지 못했다. 터미널 폰트는 직접 지정해라."
  ;;
esac
