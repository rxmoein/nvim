-- neo-tree with nested Java packages collapsed into one row.
--
-- `\` toggles the tree from any window: opens it revealing the current file, or closes it
-- when it is already open. `l` / `h` open and close nodes like other vim-style trees.
--
-- A chain of single-child directories is shown as one row, the way IDEs "compact middle
-- packages": `src/main/java/com/example/myapp` is one line, and the tree only branches where
-- a directory really has two entries. This is kickstart's optional neo-tree module plus that
-- grouping, kept here so the stock module in lua/kickstart/plugins/ stays untouched.

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree toggle reveal<CR>', { desc = 'NeoTree toggle', silent = true })

require('neo-tree').setup {
  -- Same folder glyphs as the snacks explorer (lua/customizations/snacks.lua): outlined
  -- folder when closed (nf-md-folder_outline), outlined folder with a check mark when open
  -- (nf-md-folder_check_outline). Empty folders use the same pair.
  default_component_configs = {
    icon = {
      folder_closed = '󰉖',
      folder_open = '󱥿',
      folder_empty = '󰉖',
      folder_empty_open = '󱥿',
    },
  },
  -- Applies to every source (files, buffers, git status). Both `l` and `h` toggle a folder
  -- open or closed. On a file, `l` opens it and `h` collapses the folder it is in.
  -- `l` replaces the default focus_preview; press `P` for the preview instead.
  window = {
    mappings = {
      ['l'] = 'open', -- neo-tree's open already toggles directories
      ['h'] = function(state)
        local node = state.tree:get_node()
        if node.type == 'directory' then
          state.commands.toggle_node(state)
        else
          state.commands.close_node(state)
        end
      end,
    },
  },
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
