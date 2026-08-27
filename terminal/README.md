# terminal

밝기를 최대로 두고 쓰는 것을 전제로 만든 Ptyxis 터미널 팔레트와, 그에 맞춘
`dircolors` 규칙.

## 내용

| 파일 | 설명 |
|---|---|
| `palettes/Sage.palette` | 연두 계열. 배경 `#DDE5D5` (L\*=90) / 다크 `#152110` |
| `palettes/Ochre.palette` | 황토 계열. 배경 `#EFD9C8` (L\*=88) / 다크 `#271E17` |
| `dir_colors` | 두 팔레트 모두에서 읽히는 `LS_COLORS` |
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

## 수동 설치

```sh
mkdir -p ~/.local/share/org.gnome.Ptyxis/palettes
cp palettes/*.palette ~/.local/share/org.gnome.Ptyxis/palettes/
cp dir_colors ~/.dir_colors
echo 'eval "$(dircolors -b ~/.dir_colors)"' >> ~/.zshrc
```

Ptyxis 재시작 후 Preferences → Appearance 에서 Sage 또는 Ochre 선택.

## TODO

- [ ] `terminal-settings.sh` 작성 — 팔레트 복사 + Ptyxis 프로파일을 Sage 로
      지정(`gsettings set org.gnome.Ptyxis.Profile:… palette 'Sage'`) +
      `.zshrc` 에 dircolors 한 줄 추가
- [ ] `install.sh` 에 `install_terminal()` 추가
