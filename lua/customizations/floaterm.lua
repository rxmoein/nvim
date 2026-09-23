-- Floating terminals (vim-floaterm) and a lazygit toggle.
--
-- * <leader>gg and <C-g> toggle lazygit in a floating terminal. <C-g> is the one ctrl-letter
--   lazygit does not bind, so it also works from inside the terminal: one key to show and
--   hide, from either side. Files opened from lazygit (`e`) land in the parent window, and
--   changes lazygit made on disk are picked up when it closes.
-- * <leader>gt and <F12> toggle a plain floating terminal; <F12> also hides it from inside.
--
-- lazygit itself and its diff highlighting are installed per machine, see README.

do
  vim.pack.add { 'https://github.com/voldikss/vim-floaterm' }

  -- Floating window geometry/appearance (see `:help floaterm-settings`).
  vim.g.floaterm_width = 0.9
  vim.g.floaterm_height = 0.9
  vim.g.floaterm_title = ''
  vim.g.floaterm_borderchars = '─│─│╭╮╯╰'
  -- Files opened from inside a floaterm (e.g. lazygit's `e`) land in the parent window.
  vim.g.floaterm_opener = 'edit'
  vim.g.floaterm_autoclose = 1

  --- Toggle a persistent lazygit terminal, creating it on first use.
  local function toggle_lazygit()
    if vim.fn.executable 'lazygit' == 0 then
      vim.notify('lazygit is not installed (try `brew install lazygit`)', vim.log.levels.ERROR)
      return
    end
    -- NOTE: `FloatermToggle lazygit` does not fail when no such terminal exists --
    -- it silently opens a plain shell under that name -- so ask the buflist first.
    if vim.fn['floaterm#terminal#get_bufnr'] 'lazygit' == -1 then
      vim.cmd 'FloatermNew --name=lazygit --title=lazygit lazygit'
    else
      vim.cmd 'FloatermToggle lazygit'
    end
  end

  -- Exposed as a command so the terminal-mode mapping can reach it after `<C-\><C-n>`.
  vim.api.nvim_create_user_command('LazygitToggle', toggle_lazygit, { desc = 'Toggle the lazygit floaterm' })

  local map = vim.keymap.set
  map('n', '<leader>gg', '<cmd>LazygitToggle<CR>', { desc = 'Lazy[g]it' })
  -- `<C-g>` is the one ctrl-letter lazygit does not bind, so it can toggle from
  -- inside the terminal as well -- one key to show and hide, from either side.
  map('n', '<C-g>', '<cmd>LazygitToggle<CR>', { desc = 'Toggle lazygit' })
  map('t', '<C-g>', '<C-\\><C-n><cmd>LazygitToggle<CR>', { desc = 'Toggle lazygit' })
  map('n', '<leader>gt', '<cmd>FloatermToggle<CR>', { desc = 'Floating [t]erminal' })
  require('which-key').add { { '<leader>g', group = '[G]it / terminal' } }
  map('t', '<F12>', '<C-\\><C-n><cmd>FloatermToggle<CR>', { desc = 'Hide floating terminal' })
  map('n', '<F12>', '<cmd>FloatermToggle<CR>', { desc = 'Floating terminal' })

  -- Pick up changes lazygit made on disk (branch switches, commits, discards).
  vim.api.nvim_create_autocmd('TermClose', {
    pattern = '*lazygit*',
    callback = function()
      vim.cmd 'checktime'
      pcall(function() require('gitsigns').refresh() end)
    end,
  })
end
