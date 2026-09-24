-- Code-context breadcrumb in the winbar (dropbar.nvim), like IntelliJ's breadcrumbs bar.
--
-- * <leader>; picks a symbol from the breadcrumb.
-- * [; jumps to the start of the enclosing context, ]; selects the next context.

vim.pack.add { 'https://github.com/Bekaboo/dropbar.nvim' }

-- Same outlined folder glyph as neo-tree and the snacks explorer (nf-md-folder_outline)
-- instead of dropbar's filled default, so directories look the same in the breadcrumb.
require('dropbar').setup {
  icons = { kinds = { symbols = { Folder = '󰉖 ' } } },
}

local dropbar_api = require 'dropbar.api'
vim.keymap.set('n', '<leader>;', dropbar_api.pick, { desc = 'Pick symbol in winbar' })
vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of context' })
vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
