-- Code-context breadcrumb in the winbar (dropbar.nvim), like IntelliJ's breadcrumbs bar.
--
-- * <leader>; picks a symbol from the breadcrumb.
-- * [; jumps to the start of the enclosing context, ]; selects the next context.

vim.pack.add { 'https://github.com/Bekaboo/dropbar.nvim' }

require('dropbar').setup()

local dropbar_api = require 'dropbar.api'
vim.keymap.set('n', '<leader>;', dropbar_api.pick, { desc = 'Pick symbol in winbar' })
vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of context' })
vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
