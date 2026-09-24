-- Diagnostics tweaks.
--
-- * Diagnostics refresh while typing instead of waiting for insert mode to end.
-- * A float with the diagnostic under the cursor opens by itself once the cursor has rested
--   for 400ms in normal mode (CursorHold).
-- * `gl` opens a float with the full diagnostic messages for the current line, useful when
--   the inline virtual text is truncated. Press `gl` again to move into the float and yank.
--
-- `vim.diagnostic.config` merges key by key, so this only overrides `update_in_insert` and
-- keeps the rest of kickstart's diagnostic configuration.

vim.diagnostic.config { update_in_insert = true }

vim.keymap.set('n', 'gl', function() vim.diagnostic.open_float { scope = 'line' } end, { desc = 'Show [L]ine diagnostics in a float' })

-- Auto-show the diagnostic under the cursor after it has rested for `updatetime` ms in
-- normal mode. `scope = 'cursor'` means nothing opens unless the cursor is on a diagnostic,
-- and `focus = false` keeps the cursor in the buffer so the float closes on the next move.
-- `updatetime` is global (kickstart sets 250 in init.lua); 400 also slows the LSP reference
-- highlight on CursorHold by the same amount, which is the trade-off for a calmer float.
vim.o.updatetime = 400

vim.api.nvim_create_autocmd('CursorHold', {
  group = vim.api.nvim_create_augroup('customizations-diagnostic-hover', { clear = true }),
  desc = 'Show the diagnostic under the cursor after the cursor has rested',
  callback = function()
    vim.diagnostic.open_float(nil, { scope = 'cursor', focus = false, focusable = false })
  end,
})
