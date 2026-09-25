# grund brand assets

The one place grund's logo lives. Every grund site and app copies its mark
from here; change it here first, then copy it out.

The mark is a wolf head in pale mint, outlined in black, wearing a dark grey
spiked muzzle. The wordmark is the word "grund" set in the app's own type
(Inter, weight 650, tracking -0.03em on grund.sh); there is no wordmark
image.

## Which file to use

| File | Size | Use it for |
|---|---|---|
| `grund-mark.svg` | 19 KB | **The mark, everywhere it can be SVG**: page headers, footers, docs. Square viewBox, transparent background. |
| `grund-mark-{64,128,256,512,1024}.png` | 4–116 KB | Where SVG is not accepted (chat tools, slides, email). Pick the smallest that is at least 2× the displayed size. |
| `grund-mark-{256,512}.webp` | 18 / 39 KB | Pages that want a raster mark and can serve WebP. |
| `favicon.svg` | 19 KB | `<link rel="icon" type="image/svg+xml">`. The same file as `grund-mark.svg`. |
| `favicon-{16,32,48}.png` | 1–3 KB | PNG favicon fallbacks. |
| `favicon.ico` | 9 KB | `/favicon.ico` (16, 32 and 48 px inside), for clients that ask for it by name. |
| `apple-touch-icon.png` | 180 px, 11 KB | `<link rel="apple-touch-icon">`. On the site background (`#141c18`), because iOS fills transparency with black. |
| `icon-192.png`, `icon-512.png` | 16 / 52 KB | A web app manifest, if a site gets one. Transparent. |
| `avatar-500.png`, `avatar-1024.png` | 34 / 78 KB | Org avatars (Gitea, GitHub) and other round-cropped profile pictures. The mark sits inside the circle a round crop keeps. |
| `og-1200x630.png` | 27 KB | The social/OpenGraph card for grund.sh: the mark, "grund" and the site's title line. |
| `grund-logo-master.png` | 1254 px, 1.2 MB | **The source**, as drawn. Never ship it on a page; derive from it. |

## Colours

| Layer | Colour | Note |
|---|---|---|
| mint (fur) | `#e8fdd9` | measured from the master; lighter than the site's `--accent` (`#b8dab3`), kept as drawn |
| grey (muzzle, nose) | `#3f3f3f` | |
| outline | `#000000` | |

## How the SVG was made, and how faithful it is

`grund-mark.svg` is traced from the master with potrace 1.16, one pass per
colour layer, stacked black silhouette, then grey, then mint:

- silhouette: alpha ≥ 50 %;
- mint: luminance ≥ 55 % on black;
- grey: luminance 13–45 %, opened with a 2.5 px disk to drop the
  anti-aliasing fringe between mint and black;
- `potrace -s --flat -a 1.0 -O 0.4 -u 10`, turdsize 4 (30 for grey).

Compared with the master side by side at 512 px, at 32 px and at 16 px,
rendered in Chrome, on dark and on white (2026-09-26): the shapes match. Two
details are flattened: the faint highlight streak across the muzzle and the
nose's gradient. The trace has no compression artefacts, which the master
has around its edges.

## Minimum size and clear space

- **Minimum 24 px** for the mark on its own. Below that it reads as a pale
  wolf-head blob; at 32 px the eye, the nose and the muzzle are legible.
- Favicons go down to 16 px, where only the silhouette and the dark muzzle
  band survive. That is accepted for a tab icon; nowhere else.
- **Clear space**: keep at least one eighth of the mark's width empty on
  every side. Next to the wordmark, the gap is about a quarter of the mark's
  height (0.6 rem at the site's header size).
- Next to "grund", size the mark to about 1.4× the wordmark's cap height, so
  the head matches the lowercase letters' visual weight.

## On light and on dark

One mark serves both. There is no on-dark or on-light variant.

- **On dark** (grund.sh's `#141c18`, GitHub's `#0d1117`), the black outline
  merges into the background and the mark reads as mint and grey cut out by
  dark lines. That is what the outline does anyway, so nothing is lost.
  A mint-and-grey-only variant would look the same on these backgrounds and
  wrong on any other, so there is none.
- **On light** (white, a light browser tab bar), the black outline gives the
  mint its edge. Checked on `#ffffff` and `#dee1e6`.
- Do not recolour the mark, put it on the accent colour, or set it on a
  mid-grey near `#3f3f3f`, where the muzzle disappears.

## Not done

- **No simplified small-size mark.** A tighter crop on the head was tried
  for 16–32 px. It is marginally more legible at 32 px but cuts the ears and
  the fur off, which is a redesign, not a derivation. It is Kasper's call;
  until then favicons use the full mark.
- No wordmark or lockup image: every page sets "grund" as text.
