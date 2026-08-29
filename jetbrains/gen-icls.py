#!/usr/bin/env python3
"""Ptyxis .palette -> JetBrains editor color scheme (.icls).

한 팔레트의 [Light]/[Dark] 섹션이 각각 별도 스킴 파일이 된다. JetBrains 스킴은
라이트/다크를 한 파일에 담지 못한다.

사용:
    ./gen-icls.py ../terminal/palettes/*.palette -o schemes/
"""

import argparse
import configparser
import pathlib

# ANSI 인덱스 -> (클래식 콘솔 키, 새 터미널 키)
#
# 클래식 키는 Console Colors 섹션(Run 콘솔 + 기존 터미널), BLOCK_TERMINAL_* 는
# 2024.3+ 의 새 터미널이 쓴다. 두 계열이 서로를 참조하지 않으므로 둘 다 채운다.
ANSI_KEYS = [
    (0,  "CONSOLE_BLACK_OUTPUT",           "BLOCK_TERMINAL_BLACK"),
    (1,  "CONSOLE_RED_OUTPUT",             "BLOCK_TERMINAL_RED"),
    (2,  "CONSOLE_GREEN_OUTPUT",           "BLOCK_TERMINAL_GREEN"),
    (3,  "CONSOLE_YELLOW_OUTPUT",          "BLOCK_TERMINAL_YELLOW"),
    (4,  "CONSOLE_BLUE_OUTPUT",            "BLOCK_TERMINAL_BLUE"),
    (5,  "CONSOLE_MAGENTA_OUTPUT",         "BLOCK_TERMINAL_MAGENTA"),
    (6,  "CONSOLE_CYAN_OUTPUT",            "BLOCK_TERMINAL_CYAN"),
    (7,  "CONSOLE_GRAY_OUTPUT",            "BLOCK_TERMINAL_WHITE"),
    (8,  "CONSOLE_DARKGRAY_OUTPUT",        "BLOCK_TERMINAL_BLACK_BRIGHT"),
    (9,  "CONSOLE_RED_BRIGHT_OUTPUT",      "BLOCK_TERMINAL_RED_BRIGHT"),
    (10, "CONSOLE_GREEN_BRIGHT_OUTPUT",    "BLOCK_TERMINAL_GREEN_BRIGHT"),
    (11, "CONSOLE_YELLOW_BRIGHT_OUTPUT",   "BLOCK_TERMINAL_YELLOW_BRIGHT"),
    (12, "CONSOLE_BLUE_BRIGHT_OUTPUT",     "BLOCK_TERMINAL_BLUE_BRIGHT"),
    (13, "CONSOLE_MAGENTA_BRIGHT_OUTPUT",  "BLOCK_TERMINAL_MAGENTA_BRIGHT"),
    (14, "CONSOLE_CYAN_BRIGHT_OUTPUT",     "BLOCK_TERMINAL_CYAN_BRIGHT"),
    (15, "CONSOLE_WHITE_OUTPUT",           "BLOCK_TERMINAL_WHITE_BRIGHT"),
]


def rgb(value):
    """'#EFD9C8' -> 'efd9c8'. .icls 는 '#' 없는 소문자 hex 를 쓴다."""
    return value.strip().lstrip("#").lower()


def attribute(name, fg, bg=None):
    lines = [f'      <option name="{name}">', "        <value>"]
    lines.append(f'          <option name="FOREGROUND" value="{fg}" />')
    if bg is not None:
        lines.append(f'          <option name="BACKGROUND" value="{bg}" />')
    lines += ["        </value>", "      </option>"]
    return "\n".join(lines)


def build(palette_name, variant, section):
    bg = rgb(section["Background"])
    fg = rgb(section["Foreground"])
    cursor = rgb(section["Cursor"])
    color = {i: rgb(section[f"Color{i}"]) for i in range(16)}

    scheme = f"{palette_name} {variant}"
    # New UI 의 기본 스킴. 문법 하이라이팅을 여기서 물려받아야 UI 테마와
    # 어긋나지 않는다 (구 UI 의 Default/Darcula 는 색감이 한 세대 이전이다).
    parent = "Light" if variant == "Light" else "Dark"

    colors = [
        f'      <option name="CONSOLE_BACKGROUND_KEY" value="{bg}" />',
        f'      <option name="CARET_COLOR" value="{cursor}" />',
        f'      <option name="GUTTER_BACKGROUND" value="{bg}" />',
        # 새 터미널의 블록 배경. 기본값은 부모 스킴의 흰/검 계열이라 팔레트
        # 배경 위에서 튄다. 배경과 같게 눕히고, 블록 구분은 구분선으로 준다.
        f'      <option name="BLOCK_TERMINAL_BLOCK_BACKGROUND_START" value="{bg}" />',
        f'      <option name="BLOCK_TERMINAL_BLOCK_BACKGROUND_END" value="{bg}" />',
        f'      <option name="BLOCK_TERMINAL_PROMPT_SEPARATOR_COLOR" value="{color[8]}" />',
    ]

    attrs = [
        attribute("TEXT", fg, bg),
        attribute("CONSOLE_NORMAL_OUTPUT", fg),
        attribute("CONSOLE_SYSTEM_OUTPUT", color[6]),
        attribute("CONSOLE_ERROR_OUTPUT", color[1]),
        attribute("CONSOLE_USER_INPUT", color[2]),
        attribute("BLOCK_TERMINAL_COMMAND", fg),
    ]
    for index, console_key, block_key in ANSI_KEYS:
        # FOREGROUND 는 ESC[3Xm, BACKGROUND 는 ESC[4Xm. 터미널에서는 같은 색이
        # 양쪽에 쓰이므로 두 값을 같게 둔다.
        attrs.append(attribute(console_key, color[index], color[index]))
        attrs.append(attribute(block_key, color[index], color[index]))

    return (
        f'<scheme name="{scheme}" version="142" parent_scheme="{parent}">\n'
        "  <metaInfo>\n"
        f'    <property name="originalScheme">{scheme}</property>\n'
        "  </metaInfo>\n"
        "  <colors>\n" + "\n".join(colors) + "\n  </colors>\n"
        "  <attributes>\n" + "\n".join(attrs) + "\n  </attributes>\n"
        "</scheme>\n"
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("palettes", nargs="+", type=pathlib.Path)
    parser.add_argument("-o", "--out", type=pathlib.Path, default=pathlib.Path("."))
    args = parser.parse_args()

    args.out.mkdir(parents=True, exist_ok=True)
    for path in args.palettes:
        parser_ini = configparser.ConfigParser()
        parser_ini.optionxform = str
        parser_ini.read(path)
        name = parser_ini["Palette"]["Name"]
        for variant in ("Light", "Dark"):
            target = args.out / f"{name}-{variant}.icls"
            target.write_text(build(name, variant, parser_ini[variant]))
            print(target)


if __name__ == "__main__":
    main()
