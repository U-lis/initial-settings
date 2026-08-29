# powerline-45c.zsh-theme
#
# 45c = WCAG contrast 4.5:1. 팔레트·dircolors·프롬프트를 관통하는 바닥선이며
# 이 테마의 모든 요소가 네 변형(Sage/Ochre × 라이트/다크)에서 이를 넘는다.
#
# Sage / Ochre 팔레트용 powerline 프롬프트.
# Inconsolata for Powerline (또는 powerline 패치 폰트) 필요.
#
# agnoster 가 이 팔레트에서 깨지는 이유는 세그먼트를 %K{color} 로 칠하고
# 글자를 다시 16색에서 고르기 때문이다. 라이트 테마에서는 12색이 전부
# 어두운 쪽에 몰려 있으므로 그 조합이 2.3~2.8:1 로 무너진다.
#
# 여기서는 %S (reverse video, SGR 7) 로 채운다. 글자가 터미널 배경색이 되므로
# 대비가 cr(ANSI색, 배경) — 팔레트가 이미 4.5:1 이상으로 보장한 값이 그대로
# 나오고, 라이트/다크 전환도 자동으로 따라온다. dircolors 와 같은 원리.
#
#    ~/Documents/zeroxflow/1Hour_Back  develop ✚ ● ? ↑1 ▶ █
#
# 칩 하나로 읽히도록 git 상태까지 음영 안에 넣고, 화살표를 맨 뒤로 보내
# 입력 커서와 같은 줄에 둔다.

# powerline 글리프. 함수 안에서 참조하므로 전역이어야 한다.
typeset -g P45_SEP=$'\ue0b0'      # U+E0B0 
typeset -g P45_BRANCH=$'\ue0a0'   # U+E0A0 

# 색 채운 칩. %S 가 SGR 7(reverse) 이라 글자는 터미널 배경색이 된다.
# 내용 뒤에 %F{$1} 을 다시 세우는 이유: P45_GIT_STATUS_COLOR=1 이면 내용이
# %f 로 끝나 기본 전경색이 남는데, reverse 상태에서 그것이 끝 여백의 배경이
# 되어 칩 끝만 다른 색으로 튄다.
p45_chip() { print -n "%F{$1}%S $2%F{$1} %s%f" }

# 막대 끝의 화살표. 칩과 같은 색이라 이어져 보인다.
p45_cap() { print -n "%F{$1}${P45_SEP}%f" }

# --- git: 브랜치 (칩 안에 들어가므로 색 지정 없음) ---
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

# --- git: 워킹트리 상태 (칩 안) ---
#
# 칩은 %S(reverse video) 라 글자가 터미널 배경색이 된다. 그래서 심볼에 %F 를
# 주면 그 색이 글자가 아니라 **배경**이 되어, 심볼마다 색 사각형이 하나씩
# 생긴다. 칩이 토막나 보이는 대신 색 구분은 남는다.
#
#   P45_GIT_STATUS_COLOR=0  글자 색을 주지 않는다. 칩이 하나로 이어져 보이고
#                           구분은 심볼 모양(✚ ● ✖ ➜ ═ ? ⚑)으로만 한다. 기본값.
#   P45_GIT_STATUS_COLOR=1  심볼마다 색 사각형. 색 구분이 남는다.
#
# 어느 쪽이든 대비는 cr(ANSI색, 배경) 그대로라 4.5:1 아래로 내려가지 않는다.
typeset -g P45_GIT_STATUS_COLOR=${P45_GIT_STATUS_COLOR:-0}

p45_sym() {
  if (( P45_GIT_STATUS_COLOR )); then
    print -n "%F{$1} $2%f"
  else
    print -n " $2"
  fi
}

ZSH_THEME_GIT_PROMPT_ADDED="$(p45_sym green '✚')"
ZSH_THEME_GIT_PROMPT_MODIFIED="$(p45_sym yellow '●')"
ZSH_THEME_GIT_PROMPT_DELETED="$(p45_sym red '✖')"
ZSH_THEME_GIT_PROMPT_RENAMED="$(p45_sym blue '➜')"
ZSH_THEME_GIT_PROMPT_UNMERGED="$(p45_sym red '═')"
ZSH_THEME_GIT_PROMPT_UNTRACKED="$(p45_sym cyan '?')"
ZSH_THEME_GIT_PROMPT_STASHED="$(p45_sym magenta '⚑')"

p45_remote() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local ahead behind
  ahead=$(command git rev-list --count @{upstream}..HEAD 2>/dev/null) || return
  behind=$(command git rev-list --count HEAD..@{upstream} 2>/dev/null) || return
  [[ $ahead  -gt 0 ]] && p45_sym blue "↑${ahead}"
  [[ $behind -gt 0 ]] && p45_sym red "↓${behind}"
}

# oh-my-zsh 의 git_prompt_info / git_prompt_status 는 async 다. 핸들러는 $PS1
# 안에 $(git_prompt_info) / $(git_prompt_status) 리터럴이 있을 때만 자동
# 등록되는데 (lib/git.zsh 의 _defer_async_git_register), 여기서는 둘 다 칩으로
# 감싸느라 그 조건에 걸리지 않는다. 직접 등록한다.
#
# status 는 칩 안으로 들어오면서 리터럴이 사라졌다. 등록을 빠뜨리면 심볼이
# 영영 빈 값이 된다.
if (( ${+functions[_omz_register_handler]} )); then
  _omz_register_handler _omz_git_prompt_info
  _omz_register_handler _omz_git_prompt_status
fi

# 첫 프롬프트에서는 async 캐시가 비어 있다. 동기 호출로 폴백한다.
p45_git_info() {
  local v="$(git_prompt_info)"
  [[ -z $v ]] && v="$(_omz_git_prompt_info)"
  print -n "$v"
}

p45_git_status() {
  local v="$(git_prompt_status)"
  [[ -z $v ]] && v="$(_omz_git_prompt_status)"
  print -n "$v"
}

# 경로 칩과 브랜치 칩은 사이에 화살표 없이 맞붙인다 — 하나의 라벨로 읽힌다.
# (blue/magenta 경계에 삼각형을 넣어도 대비가 1.05~1.08 이라 보이지 않는다.)
#
# git 상태와 원격 차이는 브랜치 칩 **안**에 들어간다. 칩을 닫기 전에 붙여야
# 하므로 p45_chip 을 나눠 쓰지 않고 내용을 먼저 조립한다.
p45_bar() {
  local last=blue
  p45_chip blue "%~"

  local br="$(p45_git_info)"
  if [[ -n $br ]]; then
    p45_chip magenta "${P45_BRANCH} ${br}$(p45_git_status)$(p45_remote)"
    last=magenta
  fi

  # 화살표는 맨 뒤다. 평소에는 칩과 같은 색이라 이어져 보이고, 직전 명령이
  # 실패했을 때만 빨강으로 바뀐다. 예전의 ❯ 줄이 하던 일을 대신한다.
  print -n "%(?.$(p45_cap $last).$(p45_cap red))"
}

setopt PROMPT_SUBST

# 입력 커서가 같은 줄에 온다.
PROMPT='
$(p45_bar) '

RPROMPT='%(?..%F{red}%?%f)'
