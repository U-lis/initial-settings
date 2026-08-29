#!/bin/bash
# 기능 탐지. 우분투 버전이 아니라 무엇이 설치돼 있는지로 판단한다.
#
# 버전 번호로 가르면 릴리스마다 손대야 하고, 우분투가 아닌 GNOME 이나 기본이
# 아닌 터미널에서 틀린 길로 간다. VERSION_ID 는 탐지가 애매한 곳에서만 쓴다.
[ -n "${_INITIAL_SETTINGS_DETECT:-}" ] && return 0
_INITIAL_SETTINGS_DETECT=1

# which 는 debianutils 판이라 폐기 예정이다. command -v 가 POSIX.
has_command() { command -v -- "$1" >/dev/null 2>&1; }

# 주의: 파이프로 grep -q 에 넘기면 안 된다. grep 이 첫 일치에서 바로 끝나
# 앞 명령이 SIGPIPE(141)로 죽고, 호출부의 `set -o pipefail` 이 그 141 을 집어
# 간헐적으로 "없음"이 된다. herestring 을 써서 파이프를 만들지 않는다.
has_schema() {
  has_command gsettings || return 1
  grep -qxF -- "$1" <<<"$(gsettings list-schemas 2>/dev/null)"
}

# apt 에 설치 후보가 있는 패키지인지. python3-distutils 처럼 사라진 패키지를
# 걸러내는 데 쓴다.
apt_has() {
  has_command apt-cache || return 1
  [ "$(apt-cache policy -- "$1" 2>/dev/null | awk '/Candidate:/ {print $2}')" != "(none)" ] &&
    [ -n "$(apt-cache policy -- "$1" 2>/dev/null)" ]
}

# /etc/os-release 의 한 필드. VERSION_ID 처럼 탐지가 애매한 곳의 보조용이다.
os_field() {
  [ -r /etc/os-release ] || return 1
  # head -1 로 자르면 위와 같은 SIGPIPE 문제가 난다. 변수에 받아서 자른다.
  local value
  value=$(sed -n "s/^$1=//p" /etc/os-release)
  value=${value%%$'\n'*}
  printf '%s\n' "${value//\"/}"
}

# ptyxis | gnome-terminal | none
# 기본 터미널이 무엇인지가 24.04 / 26.04 를 가르는 실제 축이다. 다만 우분투
# 버전과 1:1 이 아니다 — 26.04 에 gnome-terminal 을 깔 수도, 24.04 에 Ptyxis 를
# 깔 수도 있다.
detect_terminal() {
  if has_command ptyxis && has_schema org.gnome.Ptyxis; then
    printf 'ptyxis\n'
  elif has_command gnome-terminal && has_schema org.gnome.Terminal.ProfilesList; then
    printf 'gnome-terminal\n'
  else
    printf 'none\n'
  fi
}

ptyxis_profile_uuid() {
  gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'"
}

ptyxis_profile_path() {
  local uuid
  uuid=$(ptyxis_profile_uuid) || return 1
  [ -n "$uuid" ] || return 1
  printf 'org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/%s/\n' "$uuid"
}

# 예전 코드는 UUID(b1dcc9dd-...)를 하드코딩했다. 여기서는 설정에서 읽는다 —
# 사용자가 기본 프로파일을 바꿔 놨으면 그쪽을 따라간다.
#
# 주의: gnome-terminal 을 한 번도 안 띄운 기계에서도 gsettings 는 스키마 기본값
# (하필 b1dcc9dd-...)을 돌려준다. 즉 이 함수로 "프로파일이 있는지"는 알 수 없다.
# 다만 그 경로에 쓰면 프로파일이 생기고 gnome-terminal 이 그대로 쓰므로 문제는
# 없다. 설치 여부는 detect_terminal 이 has_command 로 가른다.
gnome_terminal_profile_path() {
  local uuid
  uuid=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
  [ -n "$uuid" ] || return 1
  printf 'org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:%s/\n' "$uuid"
}

# 설치 명령. apt 가 없으면 빈 문자열이라 호출부에서 걸러야 한다.
pkg_install_command() {
  if has_command apt-get; then
    printf 'sudo apt-get install -y\n'
  elif has_command apt; then
    printf 'sudo apt install -y\n'
  fi
}
