# terminal

밝기를 최대로 두고 쓰는 것을 전제로 만든 Ptyxis 터미널 팔레트와, 그에 맞춘
`dircolors` 규칙.

## 내용

| 파일 | 설명 |
|---|---|
| `palettes/Sage.palette` | 연두 계열. 배경 `#DDE5D5` (L\*=90) / 다크 `#152110` |
| `palettes/Ochre.palette` | 황토 계열. 배경 `#EFD9C8` (L\*=88) / 다크 `#271E17` |
| `dir_colors` | 두 팔레트 모두에서 읽히는 `LS_COLORS` |
| `sage-powerline.zsh-theme` | powerline 프롬프트. powerline 패치 폰트 필요 |
| `sage.zsh-theme` | 같은 정보를 전경색만으로. 폰트 요구 없음 |
| `palette-preview.html` | 대비 실측과 실제 렌더링 미리보기 (브라우저로 열면 됨) |

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

`agnoster` 같은 powerline 테마는 세그먼트를 `%K{color}` 로 칠하고 글자를 다시
16색에서 고른다. 라이트 테마에서는 12색이 전부 어두운 쪽에 몰려 있으므로 그
조합이 **2.3~2.8:1** 로 무너진다. `dircolors` 와 같은 구조의 문제다.

`sage-powerline` 은 세그먼트를 `%S`(reverse video, SGR 7)로 채운다. 글자가
터미널 배경색이 되므로 대비가 `cr(ANSI색, 배경)` — 팔레트가 보장한 값이
그대로 나오고, 라이트/다크 전환도 따라온다. 화살표는 세그먼트와 같은 색으로
터미널 배경 위에 찍어 이어져 보이게 한다.

git 상태 심볼(`✚` staged / `●` modified / `✖` deleted / `?` untracked /
`═` conflict / `⚑` stash)은 칩 **바깥**에 전경색으로 둔다. 칩 안에 넣으면
전부 터미널 배경색이 되어 색 구분이 사라진다. 원격과의 차이는 개수까지
표시한다 (`↑2` / `↓1`).

| 테마 | 최저 대비 (4개 변형) |
|---|---|
| `agnoster` (기본) | 2.28 |
| `sage-powerline` | **4.51** |
| `sage` | **4.51** |

256색 인덱스(`FG[237]` 등)를 쓰는 테마는 팔레트를 우회하므로 피한다 —
`af-magic` 이 그렇고, 라이트 배경에서 읽히지 않는다.

## 수동 설치

```sh
mkdir -p ~/.local/share/org.gnome.Ptyxis/palettes
cp palettes/*.palette ~/.local/share/org.gnome.Ptyxis/palettes/
cp dir_colors ~/.dir_colors
echo 'eval "$(dircolors -b ~/.dir_colors)"' >> ~/.zshrc

cp *.zsh-theme ~/.oh-my-zsh/custom/themes/
# .zshrc 의 ZSH_THEME 를 'sage-powerline' 또는 'sage' 로
```

Ptyxis 재시작 후 Preferences → Appearance 에서 Sage 또는 Ochre 선택.

## TODO

- [ ] `terminal-settings.sh` 작성 — U-lis/initial-settings#3
- [ ] `install.sh` 에 `install_terminal()` 추가 — U-lis/initial-settings#4
