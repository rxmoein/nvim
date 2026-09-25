-- Animated cursor jumps and scrolling (mini.animate, part of the mini.nvim kickstart installs).
--
-- Big jumps (]m, <C-d>, searches, `G`) otherwise land instantly and the eye loses its place.
-- Here the cursor draws a short trail from where it was to where it went, and scrolls slide
-- instead of snapping, so the direction and distance of a jump stay visible. Both take about
-- 150 ms. Window resize/open/close animations are off: they fight the floating terminals and
-- pickers. The neo-tree sidebar is exempt: `Neotree reveal` moves the cursor from the top of
-- the tree to the current file's row on every open, which would otherwise draw a trail.

local animate = require 'mini.animate'
local duration = 150

animate.setup {
  cursor = { timing = animate.gen_timing.linear { duration = duration, unit = 'total' } },
  scroll = { timing = animate.gen_timing.linear { duration = duration, unit = 'total' } },
  resize = { enable = false },
  open = { enable = false },
  close = { enable = false },
}

-- mini.animate honours `vim.b.minianimate_disable`; set it for tree buffers.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'neo-tree',
  callback = function(ev) vim.b[ev.buf].minianimate_disable = true end,
  desc = 'No cursor/scroll animation inside the neo-tree sidebar',
})
