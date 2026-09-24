-- Reload a buffer when its file changes on disk (git checkout, formatters, external tools).
--
-- `autoread` alone only checks on a few events, so `checktime` is also run when Neovim
-- regains focus, when a buffer is entered and when the cursor rests. Buffers with unsaved
-- edits are never overwritten; Neovim asks first.

vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  desc = 'Reload file changed outside of Neovim',
  group = vim.api.nvim_create_augroup('custom-autoread', { clear = true }),
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == '' then vim.cmd.checktime() end
  end,
})
