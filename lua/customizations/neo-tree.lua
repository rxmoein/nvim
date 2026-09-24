-- neo-tree with nested Java packages collapsed into one row.
--
-- `\` reveals the current file in a tree; `\` inside the tree closes it. A chain of
-- single-child directories is shown as one row, the way IDEs "compact middle packages":
-- `src/main/java/com/example/myapp` is one line, and the tree only branches where a
-- directory really has two entries. This is kickstart's optional neo-tree module plus that
-- grouping, kept here so the stock module in lua/kickstart/plugins/ stays untouched.

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    -- Needs `scan_mode = 'deep'`: grouping runs while children are being read, so with the
    -- default lazy ('shallow') scan the top level renders ungrouped.
    group_empty_dirs = true,
    scan_mode = 'deep',
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
