-- :FormatDisable / :FormatEnable switch format-on-save off and on for a session.
--
-- `:FormatDisable!` affects only the current buffer, `:FormatDisable` every buffer. The
-- flags `vim.g.disable_autoformat` and `vim.b.disable_autoformat` are read by conform's
-- `format_on_save` in init.lua and by the Java save hook in java-format.lua.

vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    vim.b.disable_autoformat = true -- this buffer only
  else
    vim.g.disable_autoformat = true
  end
end, { desc = 'Disable format on save (! for current buffer only)', bang = true })

vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = 'Re-enable format on save' })
