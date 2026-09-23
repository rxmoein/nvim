# nvim

Personal Neovim config, grown out of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
`init.lua` is kept close to stock kickstart; everything added on top lives in
`lua/customizations/`, one file per feature, each starting with a comment that
says what it does. Plugins are managed with the built-in `vim.pack`, so there
is no plugin manager to install.

This document is the checklist for reproducing the setup on a new machine.

## Setting up a new machine

### 1. Neovim 0.12 or newer

`vim.pack` and the treesitter setup need Neovim 0.12+.

```sh
brew install neovim
nvim --version
```

If the stable formula is older than 0.12, use `brew install --HEAD neovim`.

### 2. Core tools

Used by the config itself, by telescope and by `:checkhealth kickstart`.

```sh
xcode-select --install          # git, make, gcc (C compiler for treesitter and fzf-native)
brew install ripgrep fd unzip tree-sitter
```

| Tool | Used for |
| :- | :- |
| `git`, `unzip` | `vim.pack` and Mason downloads |
| `make`, `gcc` | building `telescope-fzf-native` and treesitter parsers |
| `ripgrep` | live grep in telescope and snacks |
| `fd` | file finding in telescope and snacks |
| `tree-sitter` | CLI used by `nvim-treesitter` (main branch) to compile parsers |

### 3. Nerd Font

`vim.g.have_nerd_font` is `true`, so the statusline, tree and which-key expect
a patched font.

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

Select "JetBrainsMono Nerd Font" in the terminal. For kitty that is
`font_family JetBrainsMono Nerd Font` in `kitty.conf`, see [Kitty](#kitty).

### 4. Language runtimes

Mason installs the language servers, but each server needs its runtime present.

| Server (Mason) | Language | Runtime to install |
| :- | :- | :- |
| `ts_ls`, `angularls`, `html`, `cssls` | TypeScript, Angular, HTML, CSS | Node.js: `brew install node` |
| `jdtls` | Java, Gradle and Maven projects | JDK 21 or newer, see below |
| `lua_ls`, `stylua` | Lua, this config | none, Mason ships binaries |

**Java.** `jdtls` runs on JDK 21+. The config scans `~/.sdkman/candidates/java/*`
and `/Library/Java/JavaVirtualMachines/*` to offer every installed JDK as a
runtime, and pins the Gradle importer to the newest LTS it finds. Install at
least one LTS through either path:

```sh
# sdkman
curl -s "https://get.sdkman.io" | bash
sdk install java 21.0.5-tem

# or Homebrew
brew install --cask temurin@21
```

`java -version` on `$PATH` may still be an older JDK; that is fine as long as a
21+ JDK exists in one of the scanned locations.

**Optional, off by default.** `lua/kickstart/plugins/` holds kickstart's
opt-in modules, enabled in SECTION 10 of `init.lua`. All are commented out
(the tree comes from `lua/customizations/neo-tree.lua` instead):

- `debug.lua`: `nvim-dap` with `delve` for Go. Needs `brew install go`.
- `lint.lua`: `markdownlint` for Markdown. Install via `:Mason` or `npm i -g markdownlint-cli`.
- `indent_line.lua`, `autopairs.lua`, `neo-tree.lua`: no dependencies.

### 5. Clone the config

```sh
git clone <this repo> ~/.config/nvim
```

### 6. First start

```sh
nvim
```

- `vim.pack` clones every plugin on the first launch and builds `fzf-native`.
- Mason installs the servers listed in `init.lua` (SECTION 6) plus those in
  `lua/customizations/lsp-java.lua` and `lsp-web.lua`. Watch progress with
  `:Mason`.
- Treesitter installs the parsers listed in SECTION 9 (`bash`, `c`, `diff`,
  `html`, `lua`, `luadoc`, `markdown`, `markdown_inline`, `query`, `vim`,
  `vimdoc`) plus `groovy`, `java`, `kotlin` and `xml` from
  `lua/customizations/treesitter-java.lua`.
- Run `:checkhealth kickstart` to confirm the Neovim version and the core
  tools. Mason warnings for languages you do not use can be ignored.

Plugin updates: `:lua vim.pack.update()` fetches, `:write` applies, `:quit`
cancels. `:lua vim.pack.update(nil, { offline = true })` only shows state.

### 7. Terminal extras

The rest of this document covers the tools around Neovim that are not part of
the repo: [Lazygit](#lazygit) with delta diff highlighting, and the
[Kitty](#kitty) terminal config.

## Layout

| Path | Contents |
| :- | :- |
| `init.lua` | stock kickstart: options, keymaps, plugins, LSP, formatting, completion, treesitter; split into numbered `SECTION` blocks. Ends with `require 'customizations'` |
| `lua/customizations/init.lua` | loads the customizations below in a fixed order; comment a line out to switch one off |
| `lua/customizations/*.lua` | one file per customization, see the table below |
| `lua/kickstart/plugins/` | opt-in kickstart modules, enabled by uncommenting a `require` in `init.lua` |
| `lua/kickstart/health.lua` | `:checkhealth kickstart` |
| `lua/custom/plugins/` | kickstart's original drop-in directory, unused |

### Customizations

Each file starts with a comment describing what it does and which keys it adds.

| File | What it does |
| :- | :- |
| `colorscheme.lua` | gruvbox (doom-gruvbox palette) instead of tokyonight |
| `options.lua` | relative line numbers |
| `diagnostics.lua` | diagnostics refresh while typing; `gl` line diagnostics float |
| `autoread.lua` | reload files changed on disk |
| `autosave.lua` | write the buffer when leaving it for another one |
| `imports.lua` | `<Space>ci` import symbol, `<Space>co` organize imports |
| `java-indent.lua` | 4-space indent for Java buffers |
| `gitsigns.lua` | IntelliJ-style gutter bars, hunk keymaps under `<Space>h` |
| `folder-icons.lua` | one plain folder glyph for every directory |
| `autopairs.lua` | mini.pairs: autoclose brackets and quotes, `<CR>` expands a pair |
| `snacks.lua` | file explorer, buffer and symbol pickers, dashboard, indent guides |
| `recent-files.lua` | `<Space>p` recent files picker, `<Tab>` previous file |
| `neo-tree.lua` | `\` tree with nested Java packages collapsed into one row |
| `floaterm.lua` | floating terminals, lazygit toggle |
| `dropbar.lua` | breadcrumb winbar |
| `format-toggle.lua` | `:FormatDisable` / `:FormatEnable` |
| `java-format.lua` | IntelliJ formatter for Java, new-code-only formatting on save |
| `treesitter-java.lua` | parsers for Java, Gradle and Maven files |
| `lsp-java.lua` | jdtls with JDK auto-detection, Lombok and the IntelliJ-like profile (data module, merged in SECTION 6) |
| `lsp-web.lua` | angularls, ts_ls, html, cssls (data module, merged in SECTION 6) |
| `completion-keys.lua` | `<CR>` accepts a completion (data module, merged in SECTION 8) |

The three data modules return tables that `init.lua` merges into kickstart's
own `setup` calls, because those plugins read their configuration once.

## Keymaps

Leader is `<Space>`. These are the mappings added on top of stock kickstart;
`<Space>sk` lists every mapping with its description. LSP and git mappings are
buffer-local and only exist where a server or gitsigns is attached.

Files auto-save when you leave their buffer for another one (any switch: `:e`,
pickers, `<Tab>`, go-to-definition). Only named, writable, non-scratch buffers
are written, and the Java new-code formatting runs for those saves too.

### Files and buffers

| Keys | Mode | What it does |
| :- | :- | :- |
| `<Space>p` | n | Opens a floating "Recent files" list of open buffers, most recently viewed first, with the previous file preselected. Move with `j`/`k`/`gg`/`G`, open with `<Space>`, `h`, `l` or `<CR>`, cancel with `<Esc>` or `q`. |
| `<Tab>` | n | Jumps straight to the previously viewed file. Press again to come back, so it toggles between the last two files. Shares a keycode with `<C-i>` in most terminals. |
| `<Space>e` | n | Toggles the snacks file explorer: opens it, focuses it and reveals the current file, or closes it when already focused. |
| `\` | n | Reveals the current file in neo-tree, with nested Java packages collapsed into one row. |
| `<Space>,` | n | Snacks buffer picker. |
| `<Space>bd`, `Q` | n | Deletes the current buffer without closing the window. |
| `<Space>bo` | n | Deletes every buffer except the current one. |

### Diagnostics and code

| Keys | Mode | What it does |
| :- | :- | :- |
| `gl` | n | Opens a floating window with the full diagnostic messages for the current line, useful when the inline text is truncated. Press again to move into the float and yank from it. |
| `<Space>ci` | n | Imports the unresolved symbol under the cursor. Applies directly when one import matches, shows a picker when the name is ambiguous. |
| `<Space>co` | n | Organizes imports in the whole file: adds missing ones and removes unused ones. |
| `<Space>ls` | n | Snacks picker over the symbols in the current document. |
| `<Space>lS` | n | Snacks picker over the symbols in the whole workspace. |
| `<Space>;` | n | Picks a symbol from the dropbar breadcrumb in the winbar. |
| `[;` / `];` | n | Jumps to the start of the enclosing context, or selects the next context in the breadcrumb. |
| `<Space>f` | n, v | Formats the buffer or selection with conform. |
| `<Space>th` | n | Toggles LSP inlay hints. |

### Git

| Keys | Mode | What it does |
| :- | :- | :- |
| `<Space>gg`, `<C-g>` | n, t | Toggles lazygit in a floating terminal. `<C-g>` also works from inside the terminal, so one key shows and hides it. |
| `]c` / `[c` | n | Jumps to the next or previous hunk. |
| `<Space>hs` / `<Space>hr` | n, v | Stages or resets the hunk under the cursor, or the selected lines. |
| `<Space>hS` / `<Space>hR` | n | Stages or resets the whole buffer. |
| `<Space>hp` / `<Space>hi` | n | Previews the hunk in a float, or inline. |
| `<Space>hb` | n | Shows the full blame for the current line. |
| `<Space>hd` / `<Space>hD` | n | Diffs the buffer against the index, or against the last commit. |
| `<Space>hq` / `<Space>hQ` | n | Puts the hunks of this file, or of the whole repo, in the quickfix list. |
| `<Space>tb` / `<Space>tw` | n | Toggles the current-line blame, or intra-line word diff. |
| `ih` | o, x | Text object for the hunk under the cursor, for example `vih` or `dih`. |

### Windows and terminals

| Keys | Mode | What it does |
| :- | :- | :- |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | Moves focus to the window on that side. |
| `<Space>gt`, `<F12>` | n, t | Toggles a floating terminal. `<F12>` also hides it from inside. |
| `<Esc><Esc>` | t | Leaves terminal mode. |

## Java formatting

The team formats Java with IntelliJ's default code style, so Java is formatted
with **IntelliJ's real formatting engine**, run standalone through
[ICIJ/intellij-code-formatter](https://github.com/ICIJ/intellij-code-formatter)
(embeds the IntelliJ 2025.3 platform, no IDE needed, works while the IDE is
open). Output is byte-identical to "Reformat Code" with default settings,
verified on files from the codebase. About 1 s per run.

- `bin/intellij-format <file>` is the wrapper conform calls (formatter
  `intellij`). It downloads the JAR (~160 MB) to
  `~/.local/share/nvim/intellij-format/` on first use, picks a Java 21+ from
  `JAVA_HOME`, sdkman or `/Library/Java`, and formats the file in place using
  `intellij-default-scheme.xml` (IntelliJ defaults; swap in an exported scheme
  to change the style). The version is pinned at the top of the script.
- `<Space>f` formats the whole buffer with it.
- Saving a Java file formats **only new code**: the write happens first, then
  the whole buffer is formatted once into a temp copy, diffed against the
  buffer, and only the differences that touch lines added or changed since
  `vim.g.java_format_base` (default `HEAD`, set e.g. `'origin/master'` to mean
  "since the branch point") are applied, after which the file is written again.
  Untracked files are formatted whole. Lines you did not touch are never
  changed, even if they were badly formatted before.
- `:FormatDisable` / `:FormatDisable!` / `:FormatEnable` switch the save hook
  off and on.
- The same JAR has a `--check` mode (non-zero exit, lists files), usable in CI
  if formatting should ever be enforced.

**Fallback without IntelliJ.** jdtls uses the Eclipse formatter with
`java-formatter.xml` (via `java.format.settings.url`), which approximates
IntelliJ's defaults: 4-space indent, 8-space continuation, keep existing line
breaks, never introduce new wraps, no comment reflow, method parameters and try
resources aligned on the column, parentheses left where the author put them.
Import order and star-import thresholds match IntelliJ too. Two things Eclipse
cannot reproduce, verified against the codebase: annotations on record
components are always joined onto the component line, and wrapped method
parameters are always column-aligned (IntelliJ aligns only when the first
parameter follows the `(`). Because of that, the fallback formats **only the
git hunks you changed** on save (via gitsigns). The Java buffer options
(`shiftwidth=4`, spaces) are set explicitly because jdtls takes the indent
width from the format request, not from the profile.

## Lazygit

`lua/customizations/floaterm.lua` opens lazygit in a floating terminal with
`<leader>gg` or `<C-g>` (the same key hides it again). Lazygit itself and its
diff highlighting are not part of this config, so set them up once per machine.

### Install

```sh
brew install lazygit git-delta
```

`delta` is the pager that gives the diff panel syntax highlighting. Without it
lazygit falls back to plain red/green diffs.

### Diff highlighting

Lazygit reads its config from `~/Library/Application Support/lazygit/config.yml`
on macOS (`~/.config/lazygit/config.yml` on Linux). Add:

```yaml
git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never --line-numbers --hyperlinks
```

- Drop `--dark` on a light terminal theme.
- Add `--side-by-side` for two columns; pair it with lazygit's full screen mode.
- Pick a syntax theme with `delta --list-syntax-themes` and set it once:

  ```sh
  git config --global delta.syntax-theme "Monokai Extended"
  ```

Restart lazygit and open any file diff to confirm the colors.

### Reading diffs

- `+` cycles the screen mode; full mode gives the diff panel the whole terminal.
- `Enter` on a file opens the staging view with a larger diff.
- `}` and `{` grow or shrink the context lines until the whole file is visible.
- `Ctrl+W` toggles whitespace changes.

## Kitty

Kitty is not managed by this repo. Install it and copy the active settings
below into `~/.config/kitty/kitty.conf`; everything else in that file is the
commented default.

```sh
brew install --cask kitty
```

### Active config

```conf
font_size 15.0
hide_window_decorations yes

#: Tabs: cmd-based so the keys never reach nvim, lazygit or the shell
map cmd+1 goto_tab 1
map cmd+2 goto_tab 2
map cmd+3 goto_tab 3
map cmd+4 goto_tab 4
map cmd+5 goto_tab 5
map cmd+6 goto_tab 6
map cmd+7 goto_tab 7
map cmd+8 goto_tab 8
map cmd+9 goto_tab 9
map cmd+shift+] next_tab
map cmd+shift+[ previous_tab
map cmd+t new_tab_with_cwd
map cmd+w close_tab
map cmd+shift+t set_tab_title
map cmd+alt+] move_tab_forward
map cmd+alt+[ move_tab_backward

#: Free the ctrl combos for the shell and nvim
map ctrl+tab no_op
map ctrl+shift+tab no_op
map ctrl+shift+left no_op
map ctrl+shift+right no_op
```

### Why cmd for tabs

macOS never forwards `cmd` combinations to the program running inside the
terminal, so these bindings cannot collide with the `ctrl+h/j/k/l` window
moves or `<C-g>` lazygit toggle in this config. The kitty defaults on
`ctrl+tab` and `ctrl+shift+arrow` are disabled for the same reason.

Reload kitty with `ctrl+shift+f5` after editing the file.
