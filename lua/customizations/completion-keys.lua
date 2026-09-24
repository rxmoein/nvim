-- blink.cmp keymap changes, merged into kickstart's `keymap` table in init.lua (SECTION 8).
--
-- <CR> accepts the highlighted completion; when the menu is closed it falls through to a
-- normal newline. <C-y> from the 'default' preset keeps working. This is a data module
-- because blink reads its keymap once during `setup`, so it cannot be changed afterwards.

return {
  ['<CR>'] = { 'accept', 'fallback' },
}
