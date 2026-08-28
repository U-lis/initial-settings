# jetbrains

`terminal/palettes/*.palette` 를 JetBrains IDE(PyCharm, CLion, GoLand …)로 옮긴
것. 두 층이 따로 있다.

| 층 | 바꾸는 곳 | 형식 |
|---|---|---|
| Editor Color Scheme | 에디터, 콘솔, 터미널 **안쪽** | `.icls` 파일 |
| UI Theme | 툴바, 프로젝트 트리, 탭, 다이얼로그 | **플러그인 jar** |

에디터만 적용하면 IDE 크롬이 원래의 중성 회색으로 남아 색이 겉돈다. 일체감은 UI
Theme 까지 넣어야 나온다.

## 내용

| 파일 | 설명 |
|---|---|
| `oklch.py` | sRGB ↔ OKLCh, WCAG 대비. 외부 의존 없음 |
| `gen-icls.py` | `.palette` → `.icls` (에디터 색 스킴) |
| `gen-theme.py` | `.palette` → UI 테마 플러그인 jar |
| `schemes/*.icls` | 생성된 색 스킴 4개 (Ochre/Sage × Light/Dark) |
| `build/` | 생성된 플러그인 jar. 커밋하지 않는다 |

```sh
./gen-icls.py ../terminal/palettes/*.palette -o schemes/
./gen-theme.py ../terminal/palettes/*.palette
```

## 설치

플러그인 jar 이 색 스킴까지 같이 물고 있으므로 **jar 하나만 넣으면 된다.**

```sh
./gen-theme.py ../terminal/palettes/*.palette \
    --install ~/.local/share/JetBrains/PyCharm2026.2
```

IDE 재시작 후 Settings → Appearance & Behavior → Appearance → Theme 에서
`Ochre Light` / `Ochre Dark` / `Sage Light` / `Sage Dark`. 테마를 고르면 에디터
스킴도 같이 따라온다. 지울 때는 jar 을 지우고 재시작하면 된다.

제품마다 플러그인 디렉터리가 다르므로 CLion·GoLand 등에도 쓰려면 각각 복사한다.

에디터 색만 원하면 `schemes/*.icls` 를 Settings → Editor → Color Scheme → ⚙ →
Import Scheme… 로 따로 넣어도 된다.

## 색 스킴 (`gen-icls.py`)

ANSI 16색이 **두 계열**에 중복으로 들어간다. 서로 참조하지 않기 때문이다.

| 대상 | 키 |
|---|---|
| Run 콘솔 + 기존 터미널 | `CONSOLE_BLACK_OUTPUT` … `CONSOLE_WHITE_OUTPUT` |
| 새 터미널 (2024.3+) | `BLOCK_TERMINAL_BLACK` … `BLOCK_TERMINAL_WHITE_BRIGHT` |

각 항목이 `FOREGROUND`(`ESC[3Xm`)와 `BACKGROUND`(`ESC[4Xm`) 두 칸을 가진다.
터미널에서는 같은 색이 양쪽에 쓰이므로 두 값을 같게 둔다. 그 외:

| Ptyxis | `.icls` |
|---|---|
| `Background` | `TEXT`/BACKGROUND, `CONSOLE_BACKGROUND_KEY`, `GUTTER_BACKGROUND` |
| `Foreground` | `TEXT`/FOREGROUND, `CONSOLE_NORMAL_OUTPUT`, `BLOCK_TERMINAL_COMMAND` |
| `Cursor` | `CARET_COLOR` |

새 터미널의 블록 배경(`BLOCK_TERMINAL_BLOCK_BACKGROUND_START`/`_END`)은 기본값이
부모 스킴의 흰/검 계열이라 팔레트 배경 위에서 튄다. 배경색으로 눕히고 블록
구분은 `BLOCK_TERMINAL_PROMPT_SEPARATOR_COLOR`(= `Color8`)로 준다.

문법 하이라이팅은 부모 스킴(`Light` / `Dark`, New UI 기본)을 물려받는다.
팔레트에 그에 대응하는 정보가 없다.

## UI 테마 (`gen-theme.py`)

UI Theme 은 `.theme.json` 을 설정 디렉터리에 던져 넣는 경로가 없다. `plugin.xml`
의 `<themeProvider>` 로 등록된 **플러그인**이어야 한다.

베이스는 설치된 IDE 안의 New UI 테마(`expUI_light` / `expUI_dark`,
`lib/intellij.platform.ide.impl.jar` 안)다. 그 테마는 `colors` 에 이름 붙인 색
(`Gray1..14`, `Blue1..13` …)을 두고 `ui` 항목 489곳이 그 이름을 참조하는 구조라,
**이름 테이블만 갈아끼우면 크롬 전체가 따라온다.** 남은 raw hex 126개는 대부분
투명도 오버레이(`#00000010` 등)라 팔레트와 무관하다.

베이스를 레포에 넣지 않고 설치된 IDE 에서 매번 읽는다. 결과 jar 도 커밋하지
않는다. JetBrains 리소스를 파생해 재배포하지 않기 위해서다. 대신 IDE 가 설치된
기계에서만 생성이 된다.

변환은 OKLCh 에서 한다:

- **명도(L)**: 라이트만 `L × L_bg` 로 눌러 순백 표면을 팔레트 배경까지 내린다
  (`Gray14 #FFFFFF` → `#EFD9C8`, 정확히 팔레트 배경). 다크 베이스는 가장 어두운
  회색이 이미 L=23.9 로 팔레트 다크 배경(L=24.3)과 같은 자리라 손대지 않는다.
- **회색**: 색상각을 팔레트 배경의 것으로 바꾸고, 채도를 표면일수록 세게 준다
  (`w = (L/L_bg)²`). 글자 쪽은 거의 무채로 남는다.
- **강조색**: 명도·채도는 베이스 것을 그대로 두고 색상각만 팔레트 계열로 돌린다
  (`Blue`→`Color4`, `Green`→`Color2`, `Red`→`Color1`, `Yellow`→`Color3`,
  `Purple`→`Color5`, `Teal`→`Color6`, `Orange`→`Color1`·`Color3` 중간).
  UI 가 색으로 구분하는 상태(선택/경고/오류)의 강약을 깨지 않기 위해서다.

### 대비

터미널 팔레트의 4.5:1 바닥선은 **여기에 적용되지 않는다.** 베이스인 New UI
테마의 크롬 색이 이미 그 아래에 있고(`Gray6` 4.64, `Blue4` 4.03), 배경을 흰색에서
팔레트 배경으로 내리면 어두운 전경의 대비는 구조적으로 더 떨어진다.

| 키 | 베이스 (라이트) | Ochre Light |
|---|---|---|
| `Gray1` (본문) | 19.76 | 14.54 |
| `Gray4` | 8.14 | 7.12 |
| `Gray6` | 4.64 | 4.30 |
| `Gray7` (부가 정보) | 3.46 | 3.28 |
| `Blue4` (강조) | 4.03 | 3.67 |

크롬 라벨은 4.5:1 을 보장하지 않는다. 보장 대상은 콘솔/터미널 ANSI 색이고 그건
`.icls` 쪽에서 그대로 유지된다 (`../terminal/README.md`).

## 한계

- 베이스가 New UI(2022.2+) 테마다. 구 UI 를 쓰면 크롬이 그대로 남는다.
- `TitlebarBackground` / `Superuser*` / `Remote*` 는 Ptyxis 전용이라 대응 키가
  없다.

## TODO

- [ ] `jetbrains-settings.sh` 작성 + `install.sh` 연동 — U-lis/initial-settings#6
