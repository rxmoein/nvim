-- Java indents with 4 spaces.
--
-- This matters beyond editing: Neovim sends the buffer's shiftwidth/expandtab with every LSP
-- format request and jdtls uses them over its formatter profile, so with the default
-- shiftwidth of 8 the whole file would be re-indented by 8.

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  group = vim.api.nvim_create_augroup('custom-java-indent', { clear = true }),
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
  end,
})
