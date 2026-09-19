-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    -- Collapse a chain of single-child directories into one row, the way IDEs
    -- "compact middle packages": `src/main/java/com/example/myapp` is one line,
    -- and the tree only branches where a directory really has two entries.
    -- Needs `scan_mode = 'deep'`: grouping runs while children are being read, so
    -- with the default lazy ('shallow') scan the top level renders ungrouped.
    group_empty_dirs = true,
    scan_mode = 'deep',
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
