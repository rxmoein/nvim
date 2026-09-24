-- LSP import helpers under <leader>c.
--
-- * <leader>ci imports the unresolved symbol under the cursor without retyping it. Applies
--   directly when exactly one import matches; shows a picker only when the name is ambiguous.
-- * <leader>co adds all missing imports and removes unused ones in the whole file.
--
-- Both are global rather than in the LspAttach hook so a `:source` picks them up in open
-- buffers too; they simply do nothing when no server is attached.

vim.keymap.set('n', '<leader>ci', function()
  vim.lsp.buf.code_action {
    context = { only = { 'quickfix' } },
    filter = function(action) return action.title:match '^Import' ~= nil end,
    apply = true,
  }
end, { desc = '[C]ode [I]mport symbol under cursor' })

vim.keymap.set(
  'n',
  '<leader>co',
  function() vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true } end,
  { desc = '[C]ode [O]rganize imports' }
)

require('which-key').add { { '<leader>c', group = '[C]ode' } }
