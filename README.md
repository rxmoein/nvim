# nvim

Personal Neovim config, grown out of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
Everything lives in one `init.lua` plus `lua/custom/plugins/`, and plugins are
managed with the built-in `vim.pack`, so there is no plugin manager to install.

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

**Optional, off by default.** `lua/kickstart/plugins/` holds opt-in modules
enabled at the bottom of `init.lua`. Only `neo-tree.lua` is switched on; the
rest are commented out:

- `debug.lua`: `nvim-dap` with `delve` for Go. Needs `brew install go`.
- `lint.lua`: `markdownlint` for Markdown. Install via `:Mason` or `npm i -g markdownlint-cli`.
- `indent_line.lua`, `autopairs.lua`: no dependencies.

### 5. Clone the config

```sh
git clone <this repo> ~/.config/nvim
```

### 6. First start

```sh
nvim
```

- `vim.pack` clones every plugin on the first launch and builds `fzf-native`.
- Mason installs the servers listed in `init.lua` (SECTION 6). Watch progress
  with `:Mason`.
- Treesitter installs the parsers listed in SECTION 9 (`bash`, `c`, `diff`,
  `groovy`, `html`, `java`, `kotlin`, `lua`, `luadoc`, `markdown`,
  `markdown_inline`, `query`, `vim`, `vimdoc`, `xml`).
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
| `init.lua` | options, keymaps, plugins, LSP, formatting, completion, treesitter; split into numbered `SECTION` blocks |
| `lua/custom/plugins/*.lua` | own additions, loaded automatically by `lua/custom/plugins/init.lua` |
| `lua/custom/plugins/floaterm.lua` | floating terminals and the lazygit toggle |
| `lua/kickstart/plugins/` | opt-in kickstart modules, enabled by uncommenting a `require` in `init.lua` |
| `lua/kickstart/health.lua` | `:checkhealth kickstart` |

## Lazygit

`lua/custom/plugins/floaterm.lua` opens lazygit in a floating terminal with
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
