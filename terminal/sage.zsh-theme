# sage.zsh-theme
#
# Sage / Ochre 팔레트를 위한 프롬프트.
#
# 원칙 하나: 색을 배경으로 칠하지 않고, 256색 인덱스도 쓰지 않는다.
# 명명된 ANSI 16색만 쓰므로 터미널이 라이트/다크로 바뀌면 색이 따라 바뀌고,
# 팔레트가 전 색상을 배경 대비 4.5:1 이상으로 보장하므로 어느 쪽이든 읽힌다.
#
# powerline 계열(agnoster 등)이 이 팔레트와 맞지 않는 이유는 세그먼트를
# 색 배경으로 칠하기 때문이다. 전경과 배경을 둘 다 16색에서 고르면
# 라이트 테마에서 2.3~2.8:1 로 무너진다. dircolors 와 같은 문제다.
#
#   ~/Documents/initial-settings  on develop ●2 ✚1 ?3  ↑1
#   ❯

# --- git: 브랜치 ---
ZSH_THEME_GIT_PROMPT_PREFIX="%F{8}on%f %F{magenta}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

# --- git: 워킹트리 상태 ---
ZSH_THEME_GIT_PROMPT_ADDED="%F{green} ✚%f"
ZSH_THEME_GIT_PROMPT_MODIFIED="%F{yellow} ●%f"
ZSH_THEME_GIT_PROMPT_DELETED="%F{red} ✖%f"
ZSH_THEME_GIT_PROMPT_RENAMED="%F{blue} ➜%f"
ZSH_THEME_GIT_PROMPT_UNMERGED="%F{red} ═%f"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{cyan} ?%f"
ZSH_THEME_GIT_PROMPT_STASHED="%F{magenta} ⚑%f"

# --- git: 원격과의 차이 (개수 포함) ---
sage_git_remote() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local ahead behind
  ahead=$(command git rev-list --count @{upstream}..HEAD 2>/dev/null) || return
  behind=$(command git rev-list --count HEAD..@{upstream} 2>/dev/null) || return
  [[ $ahead  -gt 0 ]] && echo -n " %F{blue}↑${ahead}%f"
  [[ $behind -gt 0 ]] && echo -n " %F{red}↓${behind}%f"
}

setopt PROMPT_SUBST

PROMPT='
%F{blue}%~%f $(git_prompt_info)$(git_prompt_status)$(sage_git_remote)
%(?.%F{green}.%F{red})❯%f '

# 종료 코드가 0이 아니면 오른쪽에 표시
RPROMPT='%(?..%F{red}%?%f)'
