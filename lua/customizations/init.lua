-- Loads every customization on top of kickstart, one file per feature.
--
-- Each file in this directory is self-contained and starts with a comment saying what it
-- does. The order below matters where noted (colorscheme before plugins that read colours,
-- folder-icons after mini.icons, java-format after conform, ...), so this list is explicit
-- instead of a directory scan. Comment a line out to switch that customization off.
--
-- Three more files here are *data* modules merged into kickstart's own setup calls in
-- `init.lua` rather than loaded from this list:
--   lsp-java.lua, lsp-web.lua  -> extra language servers   (SECTION 6)
--   completion-keys.lua        -> blink.cmp keymap changes (SECTION 8)

local modules = {
  'customizations.colorscheme', -- gruvbox, first so plugins below pick up its colours
  'customizations.options', -- small option changes (relative line numbers)
  'customizations.animate', -- mini.animate: cursor trail and smooth scroll on big jumps
  'customizations.scroll', -- <C-d> / <C-u> scroll a quarter page
  'customizations.diagnostics', -- live diagnostics while typing, `gl` line float
  'customizations.autoread', -- reload files changed on disk
  'customizations.autosave', -- write the buffer when leaving it
  'customizations.imports', -- <leader>ci import symbol, <leader>co organize imports
  'customizations.java-indent', -- 4-space indent for Java buffers
  'customizations.gitsigns', -- IntelliJ-style gutter bars + hunk keymaps
  'customizations.folder-icons', -- one plain folder glyph everywhere
  'customizations.autopairs', -- mini.pairs
  'customizations.snacks', -- explorer, buffer picker, symbol pickers, dashboard, indent guides
  'customizations.recent-files', -- <leader>p MRU picker, <Tab> previous file
  'customizations.neo-tree', -- `\` tree with nested Java packages collapsed
  'customizations.floaterm', -- floating terminals, lazygit toggle
  'customizations.dropbar', -- breadcrumb winbar
  'customizations.format-toggle', -- :FormatDisable / :FormatEnable
  'customizations.java-format', -- IntelliJ formatter, new-code-only formatting on save
  'customizations.treesitter-java', -- parsers for Java, Gradle and Maven files
}

for _, module in ipairs(modules) do
  require(module)
end
