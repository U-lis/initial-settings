#!/usr/bin/env python3
"""팔레트로 JetBrains UI 테마 플러그인을 만든다.

에디터 색 스킴(`.icls`)은 에디터·콘솔 안쪽만 바꾼다. 툴바·프로젝트 트리·탭 같은
IDE 크롬은 **UI Theme** 영역이고, UI Theme 은 `.theme.json` 하나를 던져 넣는
방식이 없다 — 플러그인(jar)으로 감싸서 설치해야 한다. 이 스크립트가 그 jar 을
만든다.

베이스는 설치된 IDE 안의 New UI 테마(`expUI_light` / `expUI_dark`)다. 그 테마는
`colors` 에 이름 붙인 색(`Gray1..14`, `Blue1..13` …)을 두고 `ui` 항목 489곳이
그 이름을 참조하는 구조라, **이름 테이블만 갈아끼우면 크롬 전체가 따라온다.**

베이스를 레포에 넣지 않고 설치된 IDE 에서 매번 읽는다. 결과 jar 도 커밋하지
않는다 (`build/`). JetBrains 리소스를 파생해 재배포하지 않기 위해서다.

사용:
    ./gen-theme.py ../terminal/palettes/*.palette
    ./gen-theme.py ../terminal/palettes/Ochre.palette --install ~/.local/share/JetBrains/PyCharm2026.2
"""

import argparse
import configparser
import json
import math
import pathlib
import re
import shutil
import sys
import uuid
import zipfile

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from oklch import hex_to_oklch, oklch_to_hex  # noqa: E402

BASE_THEMES = {
    "Light": "themes/expUI/expUI_light.theme.json",
    "Dark": "themes/expUI/expUI_dark.theme.json",
}
BASE_JAR = "lib/intellij.platform.ide.impl.jar"

# 채도가 이 아래면 회색 계열로 본다. 베이스의 Gray 램프는 C<=0.023,
# 가장 옅은 강조색(Blue11)이 0.043 이라 그 사이.
NEUTRAL_CHROMA = 0.03

# 강조색 계열 -> 팔레트의 ANSI 색. ANSI 에 주황이 없어서 Orange 는 빨강과
# 노랑의 중간 색상각을 쓴다.
FAMILY_SOURCE = {
    "Blue": (4,),
    "Green": (2,),
    "Red": (1,),
    "Yellow": (3,),
    "Orange": (1, 3),
    "Purple": (5,),
    "Teal": (6,),
}
HEX = re.compile(r"^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$")


def mean_hue(degrees):
    x = sum(math.cos(math.radians(d)) for d in degrees)
    y = sum(math.sin(math.radians(d)) for d in degrees)
    return math.degrees(math.atan2(y, x)) % 360


class Remap:
    """베이스 테마의 색 하나를 팔레트 쪽으로 옮긴다.

    - 명도(L): 라이트만 `L * L_bg` 로 눌러 순백 표면을 팔레트 배경까지 내린다.
      다크 베이스는 가장 어두운 회색이 이미 L=23.9 로 팔레트 다크 배경(L=24.3)과
      같은 자리라 손대지 않는다.
    - 회색: 색상각을 팔레트 배경의 것으로 바꾸고, 채도를 표면일수록 세게 준다.
      글자 쪽(라이트=어두움, 다크=밝음)은 거의 무채로 남는다.
    - 강조색: 명도·채도는 베이스 것을 그대로 두고 색상각만 팔레트 계열로 돌린다.
      UI 가 색으로 구분하는 상태(선택/경고/오류)의 강약을 깨지 않기 위해서다.
    """

    def __init__(self, base_colors, section, dark):
        self.dark = dark
        self.bg_L, self.bg_C, self.bg_h = hex_to_oklch(section["Background"])
        self.scale = 1.0 if dark else self.bg_L

        ansi = {i: section[f"Color{i}"] for i in range(16)}
        self.family_hue = {
            family: mean_hue([hex_to_oklch(ansi[i])[2] for i in indexes])
            for family, indexes in FAMILY_SOURCE.items()
        }
        # 베이스 계열별 기준 색상각. 이름 없는 raw hex 를 어느 계열로 볼지
        # 정하는 데 쓴다.
        self.base_hue = {}
        for family in FAMILY_SOURCE:
            hues = [
                hex_to_oklch(v)[2]
                for k, v in base_colors.items()
                if re.fullmatch(family + r"\d+", k)
            ]
            if hues:
                self.base_hue[family] = mean_hue(hues)

    def family_of(self, hue):
        return min(
            self.base_hue,
            key=lambda f: abs((hue - self.base_hue[f] + 180) % 360 - 180),
        )

    def __call__(self, value, family=None):
        alpha = value[7:9] if len(value) == 9 else ""
        L, C, h = hex_to_oklch(value[:7])
        L *= self.scale

        if family is None and C < NEUTRAL_CHROMA:
            # 표면에 가까울수록 1, 글자 쪽으로 갈수록 0.
            near = L / self.bg_L if not self.dark else (1 - L) / (1 - self.bg_L)
            weight = min(max(near, 0.0), 1.0) ** 2
            return oklch_to_hex(L, self.bg_C * weight, self.bg_h) + alpha

        family = family or self.family_of(h)
        target = self.family_hue.get(family)
        if target is None:
            return oklch_to_hex(L, C, h) + alpha
        # 계열 전체를 같은 각도만큼 돌린다. 계열 안의 색상 차이는 남는다.
        shift = (target - self.base_hue[family] + 180) % 360 - 180
        return oklch_to_hex(L, C, (h + shift) % 360) + alpha


def convert(node, remap):
    if isinstance(node, dict):
        return {k: convert(v, remap) for k, v in node.items()}
    if isinstance(node, list):
        return [convert(v, remap) for v in node]
    if isinstance(node, str) and HEX.fullmatch(node):
        return remap(node)
    return node


def build_theme(base, palette_name, variant, section):
    theme = dict(base)
    remap = Remap(base["colors"], section, dark=(variant == "Dark"))

    colors = {}
    for name, value in base["colors"].items():
        match = re.fullmatch(r"([A-Za-z]+)\d+", name)
        family = match.group(1) if match and match.group(1) in FAMILY_SOURCE else None
        colors[name] = remap(value, family)

    theme["name"] = f"{palette_name} {variant}"
    theme["author"] = "U-lis"
    theme["colors"] = colors
    theme["ui"] = convert(base["ui"], remap)
    if "icons" in base:
        theme["icons"] = convert(base["icons"], remap)
    theme["editorScheme"] = f"/themes/{palette_name}-{variant}.xml"
    # 베이스의 nameKey 를 남기면 번들 문자열("Light")이 이름으로 다시 뜬다.
    theme.pop("nameKey", None)
    return theme


PLUGIN_XML = """<idea-plugin>
  <id>com.github.ulis.initial-settings.palette-themes</id>
  <name>Ochre &amp; Sage</name>
  <version>1.0.0</version>
  <vendor url="https://github.com/U-lis/initial-settings">U-lis</vendor>
  <description><![CDATA[
    밝기를 최대로 두고 쓰는 것을 전제로 만든 팔레트의 IDE 판.
    터미널 팔레트(Ptyxis)와 같은 색을 쓴다.
  ]]></description>
  <depends>com.intellij.modules.lang</depends>
  <extensions defaultExtensionNs="com.intellij">
{providers}
  </extensions>
</idea-plugin>
"""


def find_ide():
    root = pathlib.Path.home() / ".local/share/JetBrains/Toolbox/apps"
    for name in ("pycharm", "clion", "goland", "webstorm", "rustrover", "datagrip"):
        jar = root / name / BASE_JAR
        if jar.exists():
            return root / name
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("palettes", nargs="+", type=pathlib.Path)
    parser.add_argument("--ide", type=pathlib.Path, help=f"IDE 설치 경로 ({BASE_JAR} 를 담은)")
    parser.add_argument("--schemes", type=pathlib.Path, default=pathlib.Path("schemes"))
    parser.add_argument("--out", type=pathlib.Path, default=pathlib.Path("build"))
    parser.add_argument("--install", type=pathlib.Path, help="플러그인 디렉터리에 바로 복사")
    args = parser.parse_args()

    ide = args.ide or find_ide()
    if ide is None or not (ide / BASE_JAR).exists():
        parser.error(f"IDE 설치를 못 찾았다. --ide 로 {BASE_JAR} 를 담은 경로를 지정해라.")

    with zipfile.ZipFile(ide / BASE_JAR) as jar:
        bases = {v: json.loads(jar.read(p)) for v, p in BASE_THEMES.items()}

    args.out.mkdir(parents=True, exist_ok=True)
    jar_path = args.out / "ochre-sage-theme.jar"
    providers = []

    with zipfile.ZipFile(jar_path, "w", zipfile.ZIP_DEFLATED) as out:
        for path in args.palettes:
            ini = configparser.ConfigParser()
            ini.optionxform = str
            ini.read(path)
            name = ini["Palette"]["Name"]
            for variant in ("Light", "Dark"):
                theme = build_theme(bases[variant], name, variant, ini[variant])
                entry = f"themes/{name}-{variant}.theme.json"
                out.writestr(entry, json.dumps(theme, indent=2, ensure_ascii=False))
                providers.append(
                    f'    <themeProvider id="{uuid.uuid5(uuid.NAMESPACE_URL, entry)}"'
                    f' path="/{entry}"/>'
                )
                scheme = args.schemes / f"{name}-{variant}.icls"
                if scheme.exists():
                    out.writestr(f"themes/{name}-{variant}.xml", scheme.read_text())
                else:
                    print(f"경고: {scheme} 없음 — 에디터 색은 부모 테마 것을 쓴다.")
                print(entry)
        out.writestr("META-INF/plugin.xml", PLUGIN_XML.format(providers="\n".join(providers)))

    print(jar_path)
    if args.install:
        shutil.copy(jar_path, args.install / jar_path.name)
        print(args.install / jar_path.name)


if __name__ == "__main__":
    main()
