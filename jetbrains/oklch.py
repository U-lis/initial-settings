"""sRGB <-> OKLCh. 외부 의존 없이 쓰려고 직접 넣었다.

출처: Björn Ottosson, "A perceptual color space for image processing"
      https://bottosson.github.io/posts/oklab/
"""

import math

_LMS_FROM_LINEAR = (
    (0.4122214708, 0.5363325363, 0.0514459929),
    (0.2119034982, 0.6806995451, 0.1073969566),
    (0.0883024619, 0.2817188376, 0.6299787005),
)
_LAB_FROM_LMS = (
    (0.2104542553, 0.7936177850, -0.0040720468),
    (1.9779984951, -2.4285922050, 0.4505937099),
    (0.0259040371, 0.7827717662, -0.8086757660),
)
_LMS_FROM_LAB = (
    (1.0, 0.3963377774, 0.2158037573),
    (1.0, -0.1055613458, -0.0638541728),
    (1.0, -0.0894841775, -1.2914855480),
)
_LINEAR_FROM_LMS = (
    (4.0767416621, -3.3077115913, 0.2309699292),
    (-1.2684380046, 2.6097574011, -0.3413193965),
    (-0.0041960863, -0.7034186147, 1.7076147010),
)


def _mul(m, v):
    return tuple(sum(row[i] * v[i] for i in range(3)) for row in m)


def _to_linear(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def _from_linear(c):
    return c * 12.92 if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055


def hex_to_oklch(value):
    """'#EFD9C8' -> (L 0..1, C, h 도). 알파는 무시한다."""
    text = value.lstrip("#")
    rgb = tuple(int(text[i : i + 2], 16) / 255 for i in (0, 2, 4))
    lms = _mul(_LMS_FROM_LINEAR, tuple(_to_linear(c) for c in rgb))
    lab = _mul(_LAB_FROM_LMS, tuple(math.copysign(abs(c) ** (1 / 3), c) for c in lms))
    L, a, b = lab
    return L, math.hypot(a, b), math.degrees(math.atan2(b, a)) % 360


def oklch_to_hex(L, C, h):
    """감마 범위를 벗어나면 채도를 낮춰가며 들어올 때까지 줄인다."""
    for _ in range(64):
        rad = math.radians(h)
        lab = (L, C * math.cos(rad), C * math.sin(rad))
        lms = _mul(_LMS_FROM_LAB, lab)
        linear = _mul(_LINEAR_FROM_LMS, tuple(c**3 for c in lms))
        rgb = tuple(_from_linear(c) for c in linear)
        if all(-0.0005 <= c <= 1.0005 for c in rgb):
            return "#" + "".join(f"{round(min(max(c, 0), 1) * 255):02X}" for c in rgb)
        C *= 0.95
    return "#" + "".join(f"{round(min(max(c, 0), 1) * 255):02X}" for c in rgb)


def relative_luminance(value):
    text = value.lstrip("#")
    rgb = [int(text[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    r, g, b = (_to_linear(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(fg, bg):
    a, b = relative_luminance(fg), relative_luminance(bg)
    hi, lo = max(a, b), min(a, b)
    return (hi + 0.05) / (lo + 0.05)
