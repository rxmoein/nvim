-- Recent files picker and previous-file toggle, IntelliJ "Recent Files" style.
--
-- * <leader>p opens a floating list of open files in most-recently-viewed order with the
--   previous file preselected. Move with j/k/gg/G, open the highlighted file with <Space>,
--   h, l or <CR>, cancel with <Esc> or q.
-- * <Tab> jumps straight to the previously viewed file (the entry <leader>p highlights).
--   Press again to come back, so it toggles between the last two files. Note that <Tab>
--   shares a keycode with <C-i> in most terminals.
--
-- The order is tracked per session from BufEnter and seeded from `lastused` of buffers that
-- were already open. Icons come from mini.icons when available.

local mru = {} -- buffer numbers, most recently viewed first
local float_win, float_buf, origin_win
local icon_ns = vim.api.nvim_create_namespace 'mru_picker_icons'
local group = vim.api.nvim_create_augroup('custom-mru-picker', { clear = true })

local function is_file_buffer(buf) return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= '' end

local function remove(buf)
  for i, b in ipairs(mru) do
    if b == buf then
      table.remove(mru, i)
      return
    end
  end
end

local function touch(buf)
  remove(buf)
  table.insert(mru, 1, buf)
end

-- Seed the history from buffers that were already open, newest first.
local infos = vim.fn.getbufinfo { buflisted = 1 }
table.sort(infos, function(x, y) return x.lastused > y.lastused end)
for _, info in ipairs(infos) do
  if is_file_buffer(info.bufnr) then table.insert(mru, info.bufnr) end
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  desc = 'Track most recently viewed buffers',
  callback = function(args)
    if is_file_buffer(args.buf) then touch(args.buf) end
  end,
})
vim.api.nvim_create_autocmd('BufDelete', { group = group, callback = function(args) remove(args.buf) end })

local function close_picker()
  if float_win and vim.api.nvim_win_is_valid(float_win) then vim.api.nvim_win_close(float_win, true) end
  float_win, float_buf = nil, nil
end

local function open_selected()
  local target = mru[vim.api.nvim_win_get_cursor(float_win)[1]]
  close_picker()
  if target and is_file_buffer(target) and origin_win and vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
    vim.api.nvim_win_set_buf(origin_win, target)
  end
end

vim.keymap.set('n', '<leader>p', function()
  mru = vim.tbl_filter(is_file_buffer, mru)
  if #mru < 2 then return end
  origin_win = vim.api.nvim_get_current_win()

  -- One row per buffer: " <icon> <path> [+]", with the icon coloured by mini.icons.
  local lines, icon_hls = {}, {}
  for i, b in ipairs(mru) do
    local path = vim.api.nvim_buf_get_name(b)
    local icon, hl = ' ', nil
    if _G.MiniIcons then
      icon, hl = MiniIcons.get('file', path)
    end
    local name = vim.fn.fnamemodify(path, ':~:.')
    lines[i] = string.format(' %s %s%s ', icon, name, vim.bo[b].modified and ' [+]' or '')
    icon_hls[i] = { hl = hl, len = #icon + 1 } -- byte length of " <icon>"
  end
  local width = 30
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(width, vim.o.columns - 4)
  local height = math.min(#lines, math.max(1, math.floor(vim.o.lines * 0.5)))

  float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  for i, entry in ipairs(icon_hls) do
    if entry.hl then vim.api.nvim_buf_set_extmark(float_buf, icon_ns, i - 1, 1, { end_col = entry.len, hl_group = entry.hl }) end
  end
  vim.bo[float_buf].modifiable = false
  vim.bo[float_buf].bufhidden = 'wipe'
  float_win = vim.api.nvim_open_win(float_buf, true, {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    title = ' Recent files ',
    title_pos = 'center',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
  })
  vim.wo[float_win].cursorline = true
  -- Some colorschemes give CursorLine and NormalFloat the same background, so use the
  -- completion-menu selection colour for the active row and the editor background for the float.
  vim.wo[float_win].winhighlight = 'CursorLine:PmenuSel,NormalFloat:Normal'
  vim.api.nvim_win_set_cursor(float_win, { 2, 0 })

  -- nowait: fire immediately instead of waiting for longer global mappings such as <leader>p
  local opts = { buffer = float_buf, nowait = true, silent = true }
  for _, key in ipairs { '<Space>', 'h', 'l', '<CR>' } do
    vim.keymap.set('n', key, open_selected, opts)
  end
  for _, key in ipairs { '<Esc>', 'q' } do
    vim.keymap.set('n', key, close_picker, opts)
  end
  vim.api.nvim_create_autocmd('BufLeave', { buffer = float_buf, once = true, callback = close_picker })
end, { desc = 'Recent files [P]icker (MRU)' })

vim.keymap.set('n', '<Tab>', function()
  mru = vim.tbl_filter(is_file_buffer, mru)
  local cur = vim.api.nvim_get_current_buf()
  local target = mru[1] ~= cur and mru[1] or mru[2]
  if target then vim.api.nvim_set_current_buf(target) end
end, { desc = 'Switch to previous file (MRU)' })
