"""Builds every app icon and launch image from the approved logo (§15 D106).

    uv run --with pillow python -I tool/brand/make_brand_assets.py

Run from apps/mobile. `logo_source.png` is the owner's flattened logo and the
only source: it is only resized and placed, never redrawn or recoloured. The
intro's logo and the adaptive foreground fade the outermost plain-green
margin (no gold lies within 50 px of the source's edges) into the ground, so
no square edge shows; the gold, the lettering and its marks are untouched.
The native launch screens show the ground only (§15 D112): the intro fades
the logo in.
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

HERE = Path(__file__).resolve().parent
APP = HERE.parent.parent
SOURCE = HERE / "logo_source.png"

# The ground: the median of the source's outer 24 px band, so the
# faded edge meets the background it fades into.
GROUND = (0x02, 0x2E, 0x23)

# How far in from the source's edge the fade reaches, in source pixels:
# (left, top, right, bottom).
FEATHER_PX = (44, 44, 44, 44)

# The intro's wider fade (§15 D112): the logo's own green is lighter than the
# ground near its top and sides, so a narrow fade left a faint square. Each
# side stops short of the nearest gold: the pillar feet 154 px from the left
# and 158 from the right, their bases 150 from the bottom, the arch apex 70
# from the top.
INTRO_FEATHER_PX = (120, 60, 120, 130)

# Adaptive launcher icon: a 108 dp canvas; any mask shows its centre 66 dp
# circle. The logo's farthest gold (the pillar feet) lies 0.537 of the
# logo's side from its centre, so 60 dp keeps it within 32.2 dp.
ADAPTIVE_CANVAS_DP = 108
ADAPTIVE_LOGO_DP = 60

# In-app logo (Image.asset 'assets/brand/logo.png'), 1x side in logical px.
IN_APP_1X = 220

# The intro's logo ('assets/brand/logo_launch.png'): the faded pixels, large
# enough for a phone's width; 3x is the source's own 1254 px, never upscaled.
INTRO_1X = 418

ANDROID_DENSITIES = {"mdpi": 1.0, "hdpi": 1.5, "xhdpi": 2.0, "xxhdpi": 3.0, "xxxhdpi": 4.0}
LEGACY_LAUNCHER_DP = 48


def smoothstep(x: float) -> float:
    x = min(max(x, 0.0), 1.0)
    return x * x * (3 - 2 * x)


def feathered(logo: Image.Image, feather: tuple[int, int, int, int]) -> Image.Image:
    """The logo with its outer plain margin faded to transparent, [feather]
    source pixels in from the (left, top, right, bottom) edges."""
    size = logo.width
    left, top, right, bottom = feather

    def ramp(near: int, far: int) -> list[int]:
        return [round(255 * smoothstep(min(i / near, (size - 1 - i) / far))) for i in range(size)]

    horizontal = Image.new("L", (size, 1))
    horizontal.putdata(ramp(left, right))
    horizontal = horizontal.resize((size, size), Image.NEAREST)
    vertical = Image.new("L", (1, size))
    vertical.putdata(ramp(top, bottom))
    vertical = vertical.resize((size, size), Image.NEAREST)
    out = logo.convert("RGBA")
    out.putalpha(ImageChops.multiply(horizontal, vertical))
    return out


def resized(image: Image.Image, side: int) -> Image.Image:
    return image.resize((side, side), Image.LANCZOS)


def placed(image: Image.Image, canvas: int, side: int) -> Image.Image:
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    offset = (canvas - side) // 2
    out.alpha_composite(resized(image, side), (offset, offset))
    return out


def save(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, optimize=True)
    print(f"{path.relative_to(APP)}  {image.width}x{image.height}")


def main() -> int:
    logo = Image.open(SOURCE).convert("RGB")
    if logo.width != logo.height:
        print("logo_source.png must be square", file=sys.stderr)
        return 1
    soft = feathered(logo, FEATHER_PX)
    intro = feathered(logo, INTRO_FEATHER_PX)

    # In-app: the logo itself, and the intro's faded copy.
    brand = APP / "assets" / "brand"
    for scale, folder in ((1, brand), (2, brand / "2.0x"), (3, brand / "3.0x")):
        save(resized(logo, IN_APP_1X * scale), folder / "logo.png")
        save(resized(intro, INTRO_1X * scale), folder / "logo_launch.png")

    res = APP / "android" / "app" / "src" / "main" / "res"
    for name, density in ANDROID_DENSITIES.items():
        # Launcher: adaptive layers and the legacy square.
        canvas = round(ADAPTIVE_CANVAS_DP * density)
        save(Image.new("RGB", (canvas, canvas), GROUND), res / f"mipmap-{name}" / "ic_launcher_background.png")
        save(
            placed(soft, canvas, round(ADAPTIVE_LOGO_DP * density)),
            res / f"mipmap-{name}" / "ic_launcher_foreground.png",
        )
        save(resized(logo, round(LEGACY_LAUNCHER_DP * density)), res / f"mipmap-{name}" / "ic_launcher.png")

    ios = APP / "ios" / "Runner" / "Assets.xcassets"
    # iOS draws its own rounded mask over the full-bleed square; every icon
    # keeps the pixel size its file already has.
    for icon in sorted((ios / "AppIcon.appiconset").glob("Icon-App-*.png")):
        with Image.open(icon) as old:
            side = old.width
        save(resized(logo, side), icon)

    if "--previews" in sys.argv:
        previews(logo, soft, Path(sys.argv[sys.argv.index("--previews") + 1]))
    return 0


def previews(logo: Image.Image, soft: Image.Image, out: Path) -> None:
    """Mask previews: adaptive circle / squircle / rounded square / teardrop
    and the iOS rounded square, each also with its safe zone drawn in red."""
    scale = 4
    tile = ADAPTIVE_CANVAS_DP * scale
    sheet = Image.new("RGB", (tile * 5 + 60, tile * 2 + 30), (235, 235, 235))

    def adaptive() -> Image.Image:
        base = Image.new("RGBA", (tile, tile), GROUND + (255,))
        base.alpha_composite(placed(soft, tile, ADAPTIVE_LOGO_DP * scale))
        return base

    def mask(kind: str) -> Image.Image:
        m = Image.new("L", (tile, tile), 0)
        d = ImageDraw.Draw(m)
        inset = (ADAPTIVE_CANVAS_DP - 72) // 2 * scale  # visible 72 dp viewport
        box = (inset, inset, tile - inset, tile - inset)
        span = tile - 2 * inset
        if kind == "circle":
            d.ellipse(box, fill=255)
        elif kind == "squircle":
            d.rounded_rectangle(box, radius=round(span * 0.38), fill=255)
        elif kind == "rounded":
            d.rounded_rectangle(box, radius=round(span * 0.16), fill=255)
        else:  # teardrop
            d.rounded_rectangle(box, radius=round(span * 0.5), fill=255)
            d.rectangle((tile // 2, tile // 2, box[2], box[3]), fill=255)
        return m

    def safe(img: Image.Image, radius_dp: float) -> Image.Image:
        img = img.copy()
        d = ImageDraw.Draw(img)
        c = tile / 2
        r = radius_dp * scale
        d.ellipse((c - r, c - r, c + r, c + r), outline=(255, 0, 0, 255), width=2)
        return img

    shots = []
    for kind in ("circle", "squircle", "rounded", "teardrop"):
        icon = Image.new("RGBA", (tile, tile), (0, 0, 0, 0))
        icon.paste(adaptive(), (0, 0), mask(kind))
        shots.append((icon, 33))
    ios_icon = Image.new("RGBA", (tile, tile), (0, 0, 0, 0))
    ios_mask = Image.new("L", (tile, tile), 0)
    ImageDraw.Draw(ios_mask).rounded_rectangle((0, 0, tile - 1, tile - 1), radius=round(tile * 0.2237), fill=255)
    ios_icon.paste(resized(logo, tile).convert("RGBA"), (0, 0), ios_mask)
    shots.append((ios_icon, 0))
    for i, (shot, radius) in enumerate(shots):
        x = 10 + i * (tile + 10)
        sheet.paste(shot, (x, 10), shot)
        marked = safe(shot, radius) if radius else shot
        sheet.paste(marked, (x, tile + 20), marked)
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(f"previews -> {out}")


if __name__ == "__main__":
    sys.exit(main())
