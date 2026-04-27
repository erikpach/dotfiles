---
name: code-snippet-images
description: Generate beautiful code snippet images (PNG) for social media, tweets, LinkedIn, and documentation. Creates light-themed, macOS-style window chrome screenshots from code using HTML templates and Chrome headless. Use when asked to create code images, tweet images, snippet screenshots, code cards, or visual code examples for sharing. Supports single snippets, multi-image sets, and 2x2 grid composites.
---

# Code Snippet Images

Generate high-resolution code snippet PNGs using HTML templates rendered with Chrome headless at 2x scale.

## Quick Start

1. Copy the template from `assets/template.html` to a temp file
2. Replace `<!-- FILENAME -->` with the title bar text (e.g., filename or description)
3. Replace `<!-- CODE CONTENT -->` with syntax-highlighted HTML (see Syntax Highlighting below)
4. Render with `scripts/render.sh`:

```bash
scripts/render.sh /tmp/snippet.html /tmp/snippet.png
# Produces 2400x1350 PNG (1200x675 at 2x scale)
```

## Design Specs

- **Viewport**: 1200×675px, rendered at 2x scale → **2400×1350px** output
- **Style**: Light theme, warm off-white (#f0ece8 background, #faf8f6 card)
- **Window chrome**: macOS-style red/yellow/green dots, no badges or pills
- **Font**: JetBrains Mono (loaded from Google Fonts), ligatures disabled
- **Code font size**: 25px default (23px if code is longer, 20px if very dense). Use large fonts to fill the card.
- **No footer text** below the code card
- **Color scheme**: GitHub-light inspired syntax highlighting

## Syntax Highlighting

Wrap code tokens in `<span>` with these classes:

| Class | Color | Use for |
|-------|-------|---------|
| `.keyword` | green #22863a | `use`, `function`, `class`, `return`, `new`, `fn` |
| `.string` | blue #032f62 | `'quoted strings'` |
| `.method` | purple #6f42c1 | method/function names |
| `.class-name` | purple #6f42c1 | class and namespace names |
| `.facade` | purple #6f42c1 | Facade names like `Pdf` |
| `.comment` | gray italic #6a737d | `// comments` and `# comments` |
| `.variable` | orange #e36209 | `$variables` |
| `.named-arg` | orange #e36209 | PHP named args `key:` |
| `.arrow` | dark #24292e | `->` and `=>` |
| `.punctuation` | dark #24292e | `()`, `{}`, `[]`, `;`, `::` |
| `.env-key` | green bold #22863a | `.env` keys |
| `.env-val` | blue #032f62 | `.env` values |
| `.number` | blue #005cc5 | numeric literals |
| `.type` | purple #6f42c1 | type hints |

Use `<br>` for line breaks. Use `&nbsp;` for indentation (4× per level).

## Example

```html
<span class="keyword">use</span> <span class="class-name">App\Models\User</span><span class="punctuation">;</span><br><br>
<span class="variable">$users</span> <span class="punctuation">=</span> <span class="class-name">User</span><span class="punctuation">::</span><span class="method">where</span><span class="punctuation">(</span><span class="string">'active'</span><span class="punctuation">,</span> <span class="keyword">true</span><span class="punctuation">)-&gt;</span><span class="method">get</span><span class="punctuation">();</span>
```

## Grid Composite (2×2)

For combining 4 snippets into one image (e.g., LinkedIn posts):

1. Copy `assets/grid-2x2.html` to a temp file
2. Fill in the 4 `<!-- FILENAME N -->` and `<!-- CODE N -->` placeholders
3. Render at 2400×1350 native (no scaling needed since the grid is already 2400px wide):

```bash
scripts/render.sh /tmp/grid.html /tmp/grid.png 2400 1350 1
```

Grid uses slightly smaller fonts (17px) and padding to fit 4 cards.

## Render Script

`scripts/render.sh <input.html> <output.png> [width] [height] [scale]`

| Param | Default | Notes |
|-------|---------|-------|
| width | 1200 | Viewport width in px |
| height | 675 | Viewport height in px |
| scale | 2 | Device scale factor (2 = retina) |

## Tips

- **Adjust font size** if code doesn't fit: change `.code { font-size }` in the HTML
- **Adjust card height**: the card auto-sizes to content; body height may need increasing for long snippets
- **Arrow ligatures**: template already disables ligatures (`font-variant-ligatures: none`) to prevent `->` from rendering as `→`
- **Multiple images**: create separate HTML files per snippet, render each independently
- **PHP code**: prefer `pdf()` helper style over `Pdf` facade when showing Laravel examples (Spatie convention)
- Keep code concise — these are for social media, not documentation
