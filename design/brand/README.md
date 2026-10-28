# Brand: «أَذِّنْ فِي النَّاسِ» (Azen Fel Nas)

The logo and app icon (DESIGN.md §15 D89). The lettering is Aref Ruqaa Bold (SIL OFL 1.1, licence in
`fonts/`), set in an interlaced Ruqʿah composition and fully vowelled after al-Ḥajj 22:27:
أَذِّنْ (fatḥa on the hamza, shadda + kasra on the dhāl, sukūn on the nūn), فِي (kasra), النَّاسِ (silent
lām, shadda + fatḥa on the nūn, kasra on the sīn).

| File | What |
|---|---|
| `logo.html` | The full mark on pearl: gilded alfiz with rosettes, mihrab on brass-capital columns, lamp, words in gold. |
| `logo_transparent.html` | The same with a transparent ground (onboarding, splash). |
| `icon.html` | The app icon, 1024 px; `?fg` the Android adaptive foreground (safe zone), `?bg` its background. |
| `brand_assets.py` | Scales the renders into the app: Flutter `assets/brand`, Android mipmaps, splash and adaptive layers, iOS AppIcon and LaunchImage. |

## Regenerate

Render with Edge or Chrome headless (Chromium shapes Arabic with HarfBuzz), into `out/`:

```
msedge --headless=new --default-background-color=00000000 --force-device-scale-factor=3 --window-size=1000,1100 --screenshot=out/logo_t.png logo_transparent.html
msedge --headless=new --window-size=1024,1024 --screenshot=out/icon_full.png icon.html
msedge --headless=new --default-background-color=00000000 --window-size=1024,1024 --screenshot=out/icon_fg.png "icon.html?fg"
msedge --headless=new --window-size=1024,1024 --screenshot=out/icon_bg.png "icon.html?bg"
python brand_assets.py <repo root>
```

The gold lettering uses `background-clip: text`, which paints only inside each word's box: keep the
`.55em` padding, or the vowel marks and dots disappear.
