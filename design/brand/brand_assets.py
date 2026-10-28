"""Writes the Azen Fel Nas brand rasters into the app from the logo renders."""

import json
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1])  # the worktree
logo = root / "design/brand/out"
app = root / "apps/mobile"


def scale(src: pathlib.Path, dst: pathlib.Path, width: int, alpha: bool) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    fmt = "rgba" if alpha else "rgb24"
    subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-y", "-i", str(src),
         "-vf", f"scale={width}:-1:flags=lanczos,format={fmt}", str(dst)],
        check=True,
    )


# Flutter asset: the full logo, 220 logical px wide.
for factor, sub in [(1, ""), (2, "2.0x/"), (3, "3.0x/")]:
    scale(logo / "logo_t.png", app / f"assets/brand/{sub}logo.png", 220 * factor, True)

# Android launcher: legacy square, adaptive foreground and background (108 dp).
res = app / "android/app/src/main/res"
for density, mult in [("mdpi", 1), ("hdpi", 1.5), ("xhdpi", 2), ("xxhdpi", 3), ("xxxhdpi", 4)]:
    scale(logo / "icon_full.png", res / f"mipmap-{density}/ic_launcher.png", round(48 * mult), False)
    scale(logo / "icon_fg.png", res / f"mipmap-{density}/ic_launcher_foreground.png", round(108 * mult), True)
    scale(logo / "icon_bg.png", res / f"mipmap-{density}/ic_launcher_background.png", round(108 * mult), False)
    # Splash logo, 200 dp wide.
    scale(logo / "logo_t.png", res / f"drawable-{density}/splash_logo.png", round(200 * mult), True)

# iOS app icons from the Contents.json sizes.
icons = app / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
contents = json.loads((icons / "Contents.json").read_text(encoding="utf-8"))
for image in contents["images"]:
    side = float(image["size"].split("x")[0]) * int(image["scale"].rstrip("x"))
    scale(logo / "icon_full.png", icons / image["filename"], round(side), False)

# iOS launch image, 168 pt wide as the storyboard declares.
launch = app / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
for factor, name in [(1, "LaunchImage.png"), (2, "LaunchImage@2x.png"), (3, "LaunchImage@3x.png")]:
    scale(logo / "logo_t.png", launch / name, 168 * factor, True)
print("ok")
