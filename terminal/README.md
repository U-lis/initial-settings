# terminal

밝기를 최대로 두고 쓰는 것을 전제로 만든 Ptyxis 터미널 팔레트와, 그에 맞춘
`dircolors` 규칙.

## 내용

| 파일 | 설명 |
|---|---|
| `palettes/Sage.palette` | 연두 계열. 배경 `#DDE5D5` (L\*=90) / 다크 `#152110` |
| `palettes/Ochre.palette` | 황토 계열. 배경 `#EFD9C8` (L\*=88) / 다크 `#271E17` |
| `dir_colors` | 두 팔레트 모두에서 읽히는 `LS_COLORS` |
| `powerline-45c.zsh-theme` | powerline 프롬프트. powerline 패치 폰트 필요 |
| `plain-45c.zsh-theme` | 같은 정보를 전경색만으로. 폰트 요구 없음 |
| `palette-preview.html` | 대비 실측과 실제 렌더링 미리보기 (브라우저로 열면 됨) |

같은 팔레트의 JetBrains IDE 판은 `../jetbrains/` 에 있다.

## 설계 기준

- 배경을 순백이 아니라 **L\*=88~90** 으로 눌러 광량을 24~28% 줄인다.
  밝기 최대에서 눈에 들어오는 절대 휘도를 낮추는 것이 핵심.
- `Color0` 을 제외한 **전 색상이 네 변형(2테마 × 라이트/다크) 모두에서
  배경 대비 4.5:1 이상** (최저 4.51).
- `Color0` 은 텍스트 색이 아니라 `ESC[40m` 의 패널 배경. 대비 기준에서 제외한다.
- 라이트 테마에서 bright 계열은 더 밝게가 아니라 **더 진하게** 구분한다.
  밝히면 읽을 수 없어진다.
- `Color7`/`Color15` 를 반전시켰다. 라이트에서 `Color7` 을 흰색으로 두면
  7번을 기본 전경으로 쓰는 프롬프트 테마와 TUI 에서 글자가 사라진다.

## dircolors

기본 `dircolors` 는 검은 터미널을 전제로 색 배경 조합(`30;42`, `37;41` …)을
쓴다. 밝은 배경에서는 전경이 어두워져야 하는데 배경까지 어두운 색을
지정하므로 대비가 1.0~1.7:1 로 무너진다.

여기서는 권한 이상(setuid/setgid/sticky/other-writable/capability)에
**reverse video(`SGR 7`)** 를 쓴다. 글자가 터미널 배경색이 되므로 대비가
`cr(ANSI색, 배경)` — 팔레트가 이미 보장한 4.5:1 이상이 그대로 나오고,
테마를 바꿔도 자동으로 따라온다. 박스 모양도 유지된다.

전 14개 항목 × 4개 변형 실측 최저 **4.61:1**.

## 프롬프트 테마

이름의 `45c` 는 **WCAG contrast 4.5:1** 이다. 팔레트·`dircolors`·프롬프트를
관통하는 유일한 바닥선이고, 세 층 모두 네 변형(Sage/Ochre × 라이트/다크)에서
이를 넘도록 설계했다 — 팔레트 최저 4.51, `dircolors` 4.61, 프롬프트 4.61.

테마 이름에 팔레트 이름을 넣지 않은 이유는 아래 "팔레트에 종속되지 않는다"
항목과 같다.

`agnoster` 같은 powerline 테마는 세그먼트를 `%K{color}` 로 칠하고 글자를 다시
16색에서 고른다. 라이트 테마에서는 12색이 전부 어두운 쪽에 몰려 있으므로 그
조합이 **2.3~2.8:1** 로 무너진다. `dircolors` 와 같은 구조의 문제다.

`powerline-45c` 는 세그먼트를 `%S`(reverse video, SGR 7)로 채운다. 글자가
터미널 배경색이 되므로 대비가 `cr(ANSI색, 배경)` — 팔레트가 보장한 값이
그대로 나오고, 라이트/다크 전환도 따라온다. 화살표는 세그먼트와 같은 색으로
터미널 배경 위에 찍어 이어져 보이게 한다.

git 상태 심볼(`✚` staged / `●` modified / `✖` deleted / `?` untracked /
`═` conflict / `⚑` stash)과 원격과의 차이(`↑2` / `↓1`)는 브랜치 칩 **안**에
들어간다. 화살표는 그 뒤, 줄의 맨 끝이고 입력 커서가 같은 줄에 온다.

칩은 reverse video 라 심볼에 `%F` 를 주면 그 색이 글자가 아니라 **배경**이
된다. 그래서 두 가지 중 하나를 고르게 했다.

| `P45_GIT_STATUS_COLOR` | 결과 |
|---|---|
| `0` (기본) | 색을 주지 않는다. 칩이 하나로 이어져 보이고 구분은 심볼 모양으로만 |
| `1` | 심볼마다 색 사각형. 색 구분이 남지만 칩이 토막나 보인다 |

어느 쪽이든 대비는 `cr(ANSI색, 배경)` 그대로라 4.5:1 아래로 내려가지 않는다.

화살표는 평소 칩과 같은 색이라 이어져 보이고, 직전 명령이 실패했을 때만
빨강으로 바뀐다 — 예전에 아랫줄의 `❯` 가 하던 일이다.

| 테마 | 최저 대비 (4개 변형) |
|---|---|
| `agnoster` (기본) | 2.28 |
| `powerline-45c` | **4.51** |
| `plain-45c` | **4.51** |

256색 인덱스(`FG[237]` 등)를 쓰는 테마는 팔레트를 우회하므로 피한다 —
`af-magic` 이 그렇고, 라이트 배경에서 읽히지 않는다.

**테마는 팔레트에 종속되지 않는다.** 명명된 16색만 쓰므로 Ptyxis 에서
Sage ↔ Ochre 를 바꾸면 색이 그대로 따라온다. 팔레트별 테마를 따로 만들 필요가
없다. 그래서 테마 이름에는 팔레트 이름 대신 설계 기준(`45c`)을 넣었다.

### 함정: `git_prompt_info` 는 async 다

oh-my-zsh 는 **`$PS1` 안에 `$(git_prompt_info)` / `$(git_prompt_status)`
리터럴이 있을 때만** async 핸들러를 등록한다 (`lib/git.zsh` 의
`_defer_async_git_register`). 이 테마처럼 칩 함수로 감싸면 그 조건에 걸리지
않아 값이 항상 비게 된다. `_omz_register_handler` 로 **둘 다** 직접 등록하고,
첫 프롬프트에서는 캐시가 비어 있으므로 동기 호출로 폴백한다.

상태 심볼을 칩 안으로 옮기면서 `$(git_prompt_status)` 리터럴도 `$PS1` 에서
사라졌다. 등록을 빠뜨리면 심볼이 영영 안 뜬다 — 브랜치 때와 같은 함정을 한 번
더 밟는 자리다.

## 수동 설치

```sh
mkdir -p ~/.local/share/org.gnome.Ptyxis/palettes
cp palettes/*.palette ~/.local/share/org.gnome.Ptyxis/palettes/
cp dir_colors ~/.dir_colors
echo 'eval "$(dircolors -b ~/.dir_colors)"' >> ~/.zshrc

cp *.zsh-theme ~/.oh-my-zsh/custom/themes/
# .zshrc 의 ZSH_THEME 를 'powerline-45c' 또는 'plain-45c' 로
```

Ptyxis 재시작 후 Preferences → Appearance 에서 Sage 또는 Ochre 선택.

## TODO

- [ ] `terminal-settings.sh` 작성 — U-lis/initial-settings#3
- [ ] `install.sh` 에 `install_terminal()` 추가 — U-lis/initial-settings#4
