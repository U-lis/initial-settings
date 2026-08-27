# sage-powerline.zsh-theme
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
#    ~/Documents/zeroxflow/1Hour_Back    develop  ●2 ✚1 ?3 ↑1
#   ❯

# powerline 글리프. 함수 안에서 참조하므로 전역이어야 한다.
typeset -g SAGE_PL_SEP=$'\ue0b0'      # U+E0B0 
typeset -g SAGE_PL_BRANCH=$'\ue0a0'   # U+E0A0 

# 색 채운 칩 하나 + 뒤따르는 화살표. 둘 다 같은 색이라 이어져 보인다.
# %S 가 SGR 7(reverse) 이라 글자는 터미널 배경색이 된다.
sage_pl_chip() { print -n "%F{$1}%S $2 %s%f%F{$1}${SAGE_PL_SEP}%f" }

# --- git: 브랜치 (칩 안에 들어가므로 색 지정 없음) ---
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

# --- git: 워킹트리 상태 (칩 바깥, 전경색으로 색 구분 유지) ---
ZSH_THEME_GIT_PROMPT_ADDED="%F{green} ✚%f"
ZSH_THEME_GIT_PROMPT_MODIFIED="%F{yellow} ●%f"
ZSH_THEME_GIT_PROMPT_DELETED="%F{red} ✖%f"
ZSH_THEME_GIT_PROMPT_RENAMED="%F{blue} ➜%f"
ZSH_THEME_GIT_PROMPT_UNMERGED="%F{red} ═%f"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{cyan} ?%f"
ZSH_THEME_GIT_PROMPT_STASHED="%F{magenta} ⚑%f"

sage_pl_remote() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local ahead behind
  ahead=$(command git rev-list --count @{upstream}..HEAD 2>/dev/null) || return
  behind=$(command git rev-list --count HEAD..@{upstream} 2>/dev/null) || return
  [[ $ahead  -gt 0 ]] && print -n " %F{blue}↑${ahead}%f"
  [[ $behind -gt 0 ]] && print -n " %F{red}↓${behind}%f"
}

# oh-my-zsh 의 git_prompt_info 는 async 다. 핸들러는 $PS1 안에
# $(git_prompt_info) 리터럴이 있을 때만 자동 등록되는데, 여기서는 칩으로
# 감싸느라 그 조건에 걸리지 않는다. 직접 등록한다.
(( ${+functions[_omz_register_handler]} )) && _omz_register_handler _omz_git_prompt_info

sage_pl_git() {
  local br="$(git_prompt_info)"
  # 첫 프롬프트에서는 async 캐시가 아직 비어 있으므로 동기 호출로 채운다
  [[ -z $br ]] && br="$(_omz_git_prompt_info)"
  [[ -z $br ]] && return
  sage_pl_chip magenta "${SAGE_PL_BRANCH} ${br}"
}

setopt PROMPT_SUBST

PROMPT='
$(sage_pl_chip blue "%~")$(sage_pl_git)$(git_prompt_status)$(sage_pl_remote)
%(?.%F{green}.%F{red})❯%f '

RPROMPT='%(?..%F{red}%?%f)'
