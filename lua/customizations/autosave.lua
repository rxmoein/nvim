-- Auto-save when leaving a buffer for another file.
--
-- Any switch counts: `:e`, pickers, `<Tab>`, go-to-definition, ... Only real, named,
-- writable, non-scratch buffers are written, and `update` writes only if modified.
-- `nested = true` lets BufWritePost hooks (Java new-code formatting, see java-format.lua)
-- run for these writes too.

vim.api.nvim_create_autocmd('BufLeave', {
  desc = 'Save modified file when switching to another buffer',
  group = vim.api.nvim_create_augroup('custom-autosave-on-leave', { clear = true }),
  nested = true,
  callback = function(args)
    local bo = vim.bo[args.buf]
    if bo.modified and bo.buftype == '' and bo.modifiable and not bo.readonly and vim.api.nvim_buf_get_name(args.buf) ~= '' then
      vim.api.nvim_buf_call(args.buf, function() vim.cmd 'silent update' end)
    end
  end,
})
