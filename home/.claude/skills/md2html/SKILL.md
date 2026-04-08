---
name: md2html
description: Convert markdown files to styled, print-friendly HTML using pandoc. Use when the user wants to convert, export, or print markdown documents. Output lands in ~/Downloads/.
argument-hint: <file1.md> [file2.md] [...]
allowed-tools: Bash Read
---

Convert the markdown files provided as arguments to styled HTML. Each input file produces an HTML file with the same basename in `~/Downloads/`.

**Arguments:** $ARGUMENTS — one or more space-separated paths to `.md` files.

## Steps

1. Write the CSS below to a temporary file (`mktemp /tmp/md2html.XXXX.css`):

```css
body { font-family: system-ui, -apple-system, sans-serif; max-width: 850px; margin: auto; padding: 2em; font-size: 11pt; line-height: 1.5; color: #1a1a1a; }
h1 { font-size: 1.6em; border-bottom: 2px solid #333; padding-bottom: 0.3em; }
h2 { font-size: 1.3em; border-bottom: 1px solid #ccc; padding-bottom: 0.2em; margin-top: 1.5em; }
h3 { font-size: 1.1em; margin-top: 1.2em; }
table { border-collapse: collapse; width: 100%; margin: 1em 0; font-size: 10pt; }
th { background: #f0f0f0; font-weight: 600; }
th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; vertical-align: top; }
code { background: #f4f4f4; padding: 1px 4px; border-radius: 3px; font-size: 0.9em; }
pre { background: #f4f4f4; padding: 1em; overflow-x: auto; border-radius: 4px; font-size: 0.85em; line-height: 1.4; }
pre code { background: none; padding: 0; }
blockquote { border-left: 3px solid #ccc; margin-left: 0; padding-left: 1em; color: #555; }
@media print { body { font-size: 10pt; padding: 0; } }
```

2. For each markdown file in the arguments, run:
```bash
pandoc "$file" -t html --standalone --css="$CSS_FILE" --embed-resources -o ~/Downloads/$(basename "${file%.md}.html")
```

3. Remove the temporary CSS file.

4. Report which HTML files were created in `~/Downloads/`.
