-- Tab bar showing every open file, IDE style, with keys to walk and reorder it.
--
-- * `L` / `H` go to the next / previous tab (the vim defaults for H/L, jumping to the
--   top/bottom line of the screen, are given up for this).
-- * `<leader>bl` / `<leader>bh` move the current tab one place right / left.
-- * `<leader>b1`..`<leader>b9` jump straight to that tab by position.
-- * Closing a tab (mouse right click or `<leader>bd`) goes through snacks bufdelete so the
--   window layout survives.
--
-- The bar shrinks to make room for the neo-tree and snacks explorer sidebars, and shows the
-- worst LSP diagnostic of each file next to its name. File icons come from mini.icons
-- through kickstart's nvim-web-devicons mock.

vim.pack.add { { src = 'https://github.com/akinsho/bufferline.nvim', version = vim.version.range '*' } }

local bufferline = require 'bufferline'

bufferline.setup {
  options = {
    mode = 'buffers',
    style_preset = bufferline.style_preset.minimal,
    close_command = function(buf) Snacks.bufdelete(buf) end,
    right_mouse_command = function(buf) Snacks.bufdelete(buf) end,
    diagnostics = 'nvim_lsp',
    diagnostics_indicator = function(_, _, diag)
      local icons = { error = ' ', warning = ' ' }
      local text = (diag.error and icons.error .. diag.error .. ' ' or '') .. (diag.warning and icons.warning .. diag.warning or '')
      return vim.trim(text)
    end,
    show_buffer_close_icons = false,
    show_close_icon = false,
    always_show_bufferline = true,
    separator_style = 'thin',
    offsets = {
      { filetype = 'neo-tree', text = '', separator = true },
      { filetype = 'snacks_layout_box', text = '', separator = true },
    },
  },
}

local map = vim.keymap.set
map('n', 'L', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Next tab' })
map('n', 'H', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Previous tab' })
map('n', '<leader>bl', '<Cmd>BufferLineMoveNext<CR>', { desc = 'Move tab right' })
map('n', '<leader>bh', '<Cmd>BufferLineMovePrev<CR>', { desc = 'Move tab left' })
for i = 1, 9 do
  map('n', '<leader>b' .. i, function() bufferline.go_to(i, true) end, { desc = 'Go to tab ' .. i })
end
