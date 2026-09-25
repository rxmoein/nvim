-- Colorscheme: monokai-pro (spectrum filter) instead of kickstart's tokyonight.
--
-- https://github.com/loctvl842/monokai-pro.nvim
-- Filters: classic | octagon | pro | machine | ristretto | spectrum

vim.pack.add { 'https://github.com/loctvl842/monokai-pro.nvim' }

vim.o.background = 'dark'
require('monokai-pro').setup {
  filter = 'spectrum',
  override_palette = function()
    return {
      dark2 = '#0f0f0f',
      dark1 = '#141414',
      background = '#1a1a1a',
    }
  end,
  transparent_background = false,
  terminal_colors = true,
  devicons = true,
  styles = {
    comment = { italic = true },
    keyword = { italic = true },
    type = { italic = true },
    storageclass = { italic = true },
    structure = { italic = true },
    parameter = { italic = true },
    annotation = { italic = true },
    tag_attribute = { italic = true },
  },
  inc_search = 'background', -- underline | background
  background_clear = { 'telescope', 'notify' },

  -- The theme's own snacks.nvim support only styles the floating picker and dashboard.
  -- The explorer sidebar (<leader>e) inherits NormalFloat, which this theme draws as dim
  -- gray text on a panel lighter than the editor, framed by the darker sidebar colour, with
  -- unstyled file names and near-invisible dotfiles. Disable the theme's snacks groups and
  -- define the whole set here with one consistent sidebar background.
  disabled_plugins = { 'folke/snacks.nvim' },
  override = function(c)
    local side = c.sideBar.background
    return {
      -- Picker / explorer windows: one background for body, input and borders.
      SnacksPicker = { bg = side, fg = c.editor.foreground },
      SnacksPickerList = { bg = side, fg = c.editor.foreground },
      SnacksPickerInput = { bg = side, fg = c.editor.foreground },
      SnacksPickerPreview = { bg = c.editor.background, fg = c.editor.foreground },
      SnacksPickerBorder = { bg = side, fg = c.base.dimmed4 },
      SnacksPickerPreviewBorder = { bg = c.editor.background, fg = c.base.dimmed4 },
      SnacksPickerTitle = { bg = side, fg = c.base.yellow, bold = true },
      SnacksPickerPreviewTitle = { bg = c.editor.background, fg = c.base.yellow, bold = true },
      SnacksPickerPrompt = { bg = side, fg = c.base.blue },
      SnacksPickerListCursorLine = { bg = c.list.activeSelectionBackground },
      SnacksPickerPreviewCursorLine = { bg = c.editor.lineHighlightBackground },
      SnacksPickerTotals = { fg = c.base.dimmed3 },
      SnacksPickerToggle = { bg = c.base.dimmed5, fg = c.base.cyan },
      SnacksPickerSelected = { fg = c.base.magenta },
      SnacksPickerMatch = { fg = c.base.yellow, bold = true },

      -- Explorer entries.
      SnacksPickerFile = { fg = c.editor.foreground },
      SnacksPickerDirectory = { fg = c.editor.foreground },
      SnacksPickerDir = { fg = c.base.dimmed2 },
      SnacksPickerTree = { fg = c.base.dimmed4 },
      SnacksPickerPathHidden = { fg = c.base.dimmed3 },
      SnacksPickerPathIgnored = { fg = c.base.dimmed3 },
      SnacksPickerIconFile = { fg = c.editor.foreground },

      -- Git status in the explorer.
      SnacksPickerGitStatusUntracked = { fg = c.gitDecoration.untrackedResourceForeground },
      SnacksPickerGitStatusAdded = { fg = c.gitDecoration.addedResourceForeground },
      SnacksPickerGitStatusModified = { fg = c.gitDecoration.modifiedResourceForeground },
      SnacksPickerGitStatusDeleted = { fg = c.gitDecoration.deletedResourceForeground },
      SnacksPickerGitStatusIgnored = { fg = c.base.dimmed3 },

      -- Indent guides (snacks.indent). Snacks falls back to `NonText` / `Special` for these,
      -- and the theme's snacks spec never defines them, so use the theme's own indent-guide
      -- palette: dim lines everywhere, the current scope a step brighter.
      SnacksIndent = { fg = c.editorIndentGuide.background, nocombine = true },
      SnacksIndentScope = { fg = c.editorIndentGuide.activeBackground, nocombine = true },

      -- Dashboard (the theme's own values, kept because its snacks spec is disabled).
      SnacksDashboardNormal = { bg = c.editor.background, fg = c.editor.foreground },
      SnacksDashboardDesc = { fg = c.base.dimmed1 },
      SnacksDashboardIcon = { fg = c.base.blue },
      SnacksDashboardFooter = { fg = c.base.green },
      SnacksDashboardHeader = { fg = c.base.yellow },
      SnacksDashboardSpecial = { fg = c.base.yellow, bold = true },

      -- Breadcrumb (dropbar) icons. dropbar links its folder and file icon groups to
      -- `Directory`, which this theme draws on the tab-bar background, so the icons sat on a
      -- lighter box than the rest of the winbar. Keep the foreground, drop the background.
      DropBarIconKindFolder = { fg = c.statusBar.foreground },
      DropBarIconKindFile = { fg = c.statusBar.foreground },
    }
  end,
}

-- Note: `:colorscheme monokai-pro` forces the 'pro' filter, so use the per-filter name.
vim.cmd.colorscheme 'monokai-pro-spectrum'
