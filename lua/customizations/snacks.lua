-- snacks.nvim: file explorer sidebar, buffer management, symbol pickers, dashboard and
-- indent guides.
--
-- * <leader>e toggles the explorer: opens it, focuses it and reveals the current file, or
--   closes it when it already has focus. Dotfiles are shown by default (`H` toggles them,
--   `I` toggles gitignored files); the sidebar is 55 columns wide.
-- * <leader>, buffer picker; <leader>bd / Q delete the buffer, <leader>bo all other buffers.
-- * <leader>ls / <leader>lS pick a symbol in the document / the workspace.
-- * Start screen with header and key hints (the default 'startup' section needs lazy.nvim).
-- * Indent guides; the scope the cursor is in is drawn brighter (SnacksIndentScope).

vim.pack.add { 'https://github.com/folke/snacks.nvim' }

require('snacks').setup {
  dashboard = {
    enabled = true,
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
    },
  },
  explorer = { enabled = true },
  indent = {
    enabled = true,
    indent = { char = '│', only_scope = false, only_current = false },
    scope = { enabled = true, char = '│', underline = false },
    animate = { enabled = false },
  },
  picker = {
    enabled = true,
    -- Outlined folder for closed dirs (nf-md-folder_outline), outlined folder with a
    -- check mark for open dirs (nf-md-folder_check_outline, U+F197F).
    icons = { files = { dir = '󰉖 ', dir_open = '󱥿 ' } },
    sources = {
      explorer = {
        layout = { layout = { width = 55, min_width = 55 } },
        hidden = true,
      },
    },
  },
}

local map = vim.keymap.set
map('n', '<leader>e', function()
  local explorer = Snacks.picker.get({ source = 'explorer' })[1]
  if not explorer then
    Snacks.explorer()
  elseif explorer:is_focused() then
    explorer:close()
  else
    explorer:focus()
    Snacks.explorer.reveal()
  end
end, { desc = 'File Explorer' })
map('n', '<leader>,', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
map('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'Delete Other Buffers' })
map('n', 'Q', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
map('n', '<leader>ls', function() Snacks.picker.lsp_symbols() end, { desc = 'Document Symbols' })
map('n', '<leader>lS', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'Workspace Symbols' })

require('which-key').add {
  { '<leader>b', group = '[B]uffer' },
  { '<leader>l', group = '[L]SP symbols' },
}
