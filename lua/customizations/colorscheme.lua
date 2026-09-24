-- Colorscheme: gruvbox instead of kickstart's tokyonight.
--
-- Matches Doom Emacs' doom-gruvbox (classic palette, dark medium: bg #282828, fg #ebdbb2).
-- Set `contrast = 'hard'` for the #1d2021 variant, or 'soft' for #32302f.

vim.pack.add { 'https://github.com/ellisonleao/gruvbox.nvim' }

vim.o.background = 'dark'
require('gruvbox').setup {
  contrast = '', -- '', 'soft' or 'hard'
  italic = { strings = false, emphasis = true, comments = true, operators = false, folds = true },
  bold = true,
  transparent_mode = false,
}

vim.cmd.colorscheme 'gruvbox'
