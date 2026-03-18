---
name: nvim
description: Reference and assistant for Neovim — CLI flags, ex commands, modes, scripting, and config
allowed-tools: Bash(nvim *), Bash(printenv NVIM)
---

# Neovim Reference

## Detecting Neovim

The `NVIM` environment variable is set when a shell is running inside a Neovim terminal (`:terminal`):

```bash
printenv NVIM        # prints socket path if inside nvim terminal, empty if not
[ -n "$NVIM" ] && echo "inside nvim"
```

The `NVIM_LISTEN_ADDRESS` / `--listen` socket allows external tools to send RPC commands to a running nvim instance.

---

## Config Location

```
~/.config/nvim/init.lua        Main config entry point (Lua)
~/.config/nvim/                Config directory (lua/, lsp/, ftplugin/, snippets/, etc.)
~/.local/state/nvim/           Swap, backup, shada files
~/.local/share/nvim/           Runtime data, plugins (lazy.nvim installs here)
```

---

## CLI Flags (from manpage)

```bash
nvim file                      Open a file
nvim file1 file2               Open multiple files (one buffer each)
nvim +42 file                  Open file at line 42
nvim +/pattern file            Open file with cursor on first match of pattern
nvim -c "command" file         Run ex command after opening file
nvim --cmd "command" file      Run ex command before processing vimrc
nvim -R file                   Read-only mode
nvim -d file1 file2            Diff mode (like vimdiff)
nvim -o file1 file2            Open files in horizontal splits
nvim -O file1 file2            Open files in vertical splits
nvim -p file1 file2            Open files in tabs
nvim -u NONE                   Skip all config and plugins
nvim --clean                   Factory defaults (no config, no plugins, no shada)
nvim -l script.lua             Execute a Lua script and exit
nvim -es                       Silent Ex mode for scripting (no UI)
nvim --headless                No UI — useful for automation and scripting
nvim --listen /tmp/nvim.sock   Start with an RPC socket
nvim --startuptime file        Log startup timing to file (diagnose slow startup)
nvim -n file                   Disable swap file
```

---

## Modes

| Mode | Enter | Description |
|------|-------|-------------|
| Normal | `Esc` | Navigation and commands |
| Insert | `i` / `a` / `o` | Editing text |
| Visual | `v` / `V` / `Ctrl-v` | Selecting text (char / line / block) |
| Command | `:` | Ex commands |
| Replace | `R` | Overwrite characters |
| Terminal | `:terminal` then `i` | Shell inside a buffer |

---

## Ex Commands (`:`)

### Files & Buffers
```
:e file              Open file in current window
:w                   Write (save) current buffer
:w file              Write to a specific file
:wa                  Write all modified buffers
:q                   Quit
:q!                  Quit without saving
:wq / :x             Write and quit
:qa                  Quit all windows
:qa!                 Quit all without saving
:bn / :bp            Next / previous buffer
:bd                  Delete (close) current buffer
:ls / :buffers       List all open buffers
:b name              Switch to buffer by name or number
```

### Windows & Splits
```
:sp file             Horizontal split
:vsp file            Vertical split
:only                Close all other windows
:close               Close current window
Ctrl-w h/j/k/l       Navigate between splits
Ctrl-w =             Equalize split sizes
Ctrl-w _             Maximize current split height
Ctrl-w |             Maximize current split width
```

### Tabs
```
:tabnew file         Open file in new tab
:tabn / :tabp        Next / previous tab
:tabclose            Close current tab
:tabs                List all tabs
```

### Search & Replace
```
/pattern             Search forward
?pattern             Search backward
n / N                Next / previous match
:%s/old/new/g        Replace all in file
:%s/old/new/gc       Replace all with confirmation
:s/old/new/g         Replace all in current line
```

### Navigation
```
:42                  Jump to line 42
:$                   Jump to last line
gg / G               First / last line (normal mode)
Ctrl-o / Ctrl-i      Jump back / forward in jump list
gd                   Go to definition (with LSP)
gr                   Go to references (with LSP)
K                    Hover docs (with LSP)
```

### Marks & Jumps
```
ma                   Set mark 'a' at cursor
'a                   Jump to mark 'a'
:marks               List all marks
```

### Quickfix
```
:copen               Open quickfix list
:cn / :cp            Next / previous quickfix item
:cc N                Jump to quickfix item N
:cclose              Close quickfix list
```

### Terminal
```
:terminal            Open a terminal in current window
:vsp | terminal      Open terminal in vertical split
Ctrl-\ Ctrl-n        Exit terminal insert mode (back to normal)
```

### LSP (built-in, Neovim 0.5+)
```
:lua vim.lsp.buf.format()           Format current buffer
:lua vim.lsp.buf.rename()           Rename symbol under cursor
:lua vim.diagnostic.open_float()    Show diagnostic at cursor
:lua vim.diagnostic.goto_next()     Jump to next diagnostic
```

### Misc
```
:checkhealth         Run Neovim health checks
:Tutor               30-minute interactive tutorial
:help subject        Open help for a topic
:noh                 Clear search highlight
:set option?         Query current value of an option
:set number          Enable line numbers
:set relativenumber  Enable relative line numbers
:messages            Show recent messages/errors
:verbose map key     Show where a key mapping was defined
```

---

## Headless Scripting

Run nvim non-interactively for automation:

```bash
# Execute an ex command on a file and save
nvim --headless -c '%s/foo/bar/g' -c 'wq' file.txt

# Run a Lua script
nvim -l myscript.lua arg1 arg2

# Pipe text through nvim for processing
echo "hello world" | nvim -es -c '%s/hello/goodbye/g' -c '%p' -c 'q!'
```

---

## Notes

- The user's config lives at `~/.config/nvim/` — `init.lua` is the entry point
- LSP configs are at `~/.config/nvim/lsp/` (one file per language server)
- Filetype plugins are at `~/.config/nvim/ftplugin/` (e.g. `python.lua`, `rust.lua`)
- Snippets are at `~/.config/nvim/snippets/`
- `:checkhealth` is the first thing to run when something breaks
- `:verbose map <key>` is the fastest way to debug a conflicting keybind
