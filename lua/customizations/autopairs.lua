-- Autoclose brackets and quotes with mini.pairs (mini.nvim is installed by kickstart).
--
-- Typing `(`, `[`, `{`, `"`, `'` or `` ` `` inserts the pair with the cursor between them;
-- typing the closing character just steps over it, and <BS> between a pair deletes both.
--
-- <CR> between a pair expands it across three lines, e.g. with the cursor at `{|}`:
--     {
--         |
--     }
-- It does this via `<CR><C-o>O`, so the new lines are indented by whatever indent logic the
-- buffer already uses - the treesitter `indentexpr` for Java, Lua, etc., or
-- 'autoindent'/'cindent' elsewhere. Nothing filetype-specific to maintain here.
--
-- Quotes are deliberately not registered for <CR> (mini's default): a line break inside a
-- string literal is rarely what you want.

require('mini.pairs').setup()
