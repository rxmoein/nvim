-- Language servers for the web stack, merged into kickstart's `servers` table (SECTION 6).
--
--   angularls -> Angular templates and components
--   ts_ls     -> TypeScript / JavaScript, with most inlay hints switched on
--   html, cssls
--
-- All are installed by Mason and need Node.js on the machine (`brew install node`).

local ts_inlay_hints = {
  includeInlayParameterNameHints = 'all',
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

---@type table<string, vim.lsp.Config>
return {
  angularls = {},
  ts_ls = {
    settings = {
      typescript = { inlayHints = ts_inlay_hints },
      javascript = { inlayHints = ts_inlay_hints },
    },
  },
  html = {},
  cssls = {},
}
