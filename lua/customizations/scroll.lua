-- <C-d> / <C-u> scroll a quarter of the window instead of half.
--
-- Half a page is a big jump to keep track of, a line at a time is too slow; a quarter reads
-- like a paged scroll. The 'scroll' option would do this but Neovim resets it to half the
-- window height on every resize, so the count is computed from the current height on each
-- press instead. mini.animate still animates these scrolls.

local function quarter() return math.max(1, math.floor(vim.fn.winheight(0) / 4)) end

vim.keymap.set({ 'n', 'x' }, '<C-d>', function() return quarter() .. '<C-d>' end, { expr = true, desc = 'Scroll down a quarter page' })
vim.keymap.set({ 'n', 'x' }, '<C-u>', function() return quarter() .. '<C-u>' end, { expr = true, desc = 'Scroll up a quarter page' })
