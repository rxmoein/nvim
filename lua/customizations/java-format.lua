-- Java formatting with IntelliJ's real formatting engine, and "format only new code" on save.
--
-- The team formats Java with IntelliJ's default code style. ICIJ/intellij-code-formatter runs
-- that engine standalone (no IDE needed); `bin/intellij-format` wraps the JAR, downloads it
-- on first use, picks a Java 21+ and formats one file in place in about 1 s using
-- `intellij-default-scheme.xml`. Output is byte-identical to "Reformat Code".
--
-- * <leader>f (kickstart's conform keymap) formats the whole buffer with it, because this
--   file registers the `intellij` formatter with conform for the java filetype.
-- * Saving formats only *new* code: lines added or changed since `vim.g.java_format_base`
--   (default `HEAD`; set e.g. 'origin/master' to mean "since the branch point"). The write
--   happens first, then the whole buffer is formatted once into a temp copy, diffed against
--   the buffer, and only the differences touching changed lines are applied, after which the
--   file is written again. Untracked files are formatted whole. Untouched lines never change.
-- * Without `bin/intellij-format`, jdtls' Eclipse formatter (see lsp-java.lua) formats only
--   the git hunks changed in the buffer, since it can only approximate IntelliJ's style.
-- * :FormatDisable / :FormatEnable (format-toggle.lua) switch both paths off and on.
--
-- Must run after kickstart's conform setup (SECTION 7); conform's own `format_on_save`
-- skips Java and leaves it to the hooks here.

local conform = require 'conform'

local intellij_format = vim.fn.stdpath 'config' .. '/bin/intellij-format'
local function has_intellij() return vim.fn.executable(intellij_format) == 1 end

local function autoformat_disabled(bufnr) return vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat end

-- Whole-buffer formatting for <leader>f. `stdin = false`: the wrapper formats conform's temp
-- file in place and conform reads it back. Falls back to jdtls when the wrapper is absent.
conform.formatters.intellij = {
  command = intellij_format,
  args = { '$FILENAME' },
  stdin = false,
  condition = has_intellij,
}
conform.formatters_by_ft.java = { 'intellij' }

-- [[ Fallback without IntelliJ: format only the git hunks changed in this buffer ]]
-- Bottom-up so earlier ranges stay valid. Untracked files have no hunks and are formatted whole.
local function format_changed_hunks(bufnr)
  local opts = { bufnr = bufnr, timeout_ms = 3000, lsp_format = 'fallback' }
  local ok, gitsigns = pcall(require, 'gitsigns')
  local hunks = ok and gitsigns.get_hunks(bufnr) or nil
  if hunks == nil then
    conform.format(opts)
    return
  end
  for i = #hunks, 1, -1 do
    local hunk = hunks[i]
    if hunk.type ~= 'delete' and hunk.added.count > 0 then
      local first = hunk.added.start
      local last = first + hunk.added.count - 1
      local last_line = vim.api.nvim_buf_get_lines(bufnr, last - 1, last, false)[1] or ''
      conform.format(vim.tbl_extend('force', opts, { range = { start = { first, 0 }, ['end'] = { last, #last_line } } }))
    end
  end
end

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.java',
  group = vim.api.nvim_create_augroup('custom-java-format-fallback', { clear = true }),
  callback = function(args)
    if autoformat_disabled(args.buf) or has_intellij() then return end
    format_changed_hunks(args.buf)
  end,
})

-- [[ IntelliJ: format only new code after the write ]]
vim.g.java_format_base = vim.g.java_format_base or 'HEAD'

-- Parse `git diff -U0` output into {first, last} line ranges on the new side (1-based).
local function changed_ranges_from_diff(diff_output)
  local ranges = {}
  for start, count in diff_output:gmatch '\n@@ %-%d+,?%d* %+(%d+),?(%d*) @@' do
    local n = tonumber(count ~= '' and count or '1')
    if n > 0 then ranges[#ranges + 1] = { tonumber(start), tonumber(start) + n - 1 } end
  end
  return ranges
end

local function overlaps(ranges, first, last)
  for _, r in ipairs(ranges) do
    if first <= r[2] and last >= r[1] then return true end
  end
  return false
end

local function format_new_java_code(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local dir = vim.fs.dirname(file)
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local original = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local function apply(formatted, ranges)
    if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then return end -- edited meanwhile
    local hunks = vim.diff(table.concat(original, '\n') .. '\n', table.concat(formatted, '\n') .. '\n', { result_type = 'indices' })
    local changed = false
    for i = #hunks, 1, -1 do
      local start_a, count_a, start_b, count_b = unpack(hunks[i])
      -- a pure insertion (count_a == 0) sits between start_a and start_a + 1
      local first, last = start_a, start_a + math.max(count_a, 1) - 1
      if ranges == nil or overlaps(ranges, first, last + (count_a == 0 and 1 or 0)) then
        local replacement = vim.list_slice(formatted, start_b, start_b + count_b - 1)
        local start_idx = count_a == 0 and start_a or start_a - 1 -- 0-based, insertion goes after line start_a
        vim.api.nvim_buf_set_lines(bufnr, start_idx, start_idx + count_a, false, replacement)
        changed = true
      end
    end
    if changed then vim.api.nvim_buf_call(bufnr, function() vim.cmd 'silent noautocmd update' end) end
  end

  local function run_formatter(ranges)
    local tmp = dir .. '/.intellij-format.' .. vim.fn.rand() .. '.' .. vim.fs.basename(file)
    vim.fn.writefile(original, tmp)
    vim.system({ intellij_format, tmp }, { text = true }, function(res)
      vim.schedule(function()
        local ok, formatted = pcall(vim.fn.readfile, tmp)
        pcall(vim.fn.delete, tmp)
        if res.code ~= 0 or not ok then
          vim.notify('intellij-format failed: ' .. (res.stderr or ''), vim.log.levels.WARN)
          return
        end
        apply(formatted, ranges)
      end)
    end)
  end

  -- Which lines are new? Untracked file -> all of them.
  vim.system({ 'git', '-C', dir, 'ls-files', '--error-unmatch', '--', file }, { text = true }, function(tracked)
    if tracked.code ~= 0 then
      vim.schedule(function() run_formatter(nil) end)
      return
    end
    vim.system({ 'git', '-C', dir, 'diff', '-U0', vim.g.java_format_base, '--', file }, { text = true }, function(diff)
      vim.schedule(function()
        if diff.code ~= 0 then return end -- not a git repo, bad base, ...
        local ranges = changed_ranges_from_diff('\n' .. (diff.stdout or ''))
        if #ranges > 0 then run_formatter(ranges) end
      end)
    end)
  end)
end

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.java',
  group = vim.api.nvim_create_augroup('custom-java-format-new-code', { clear = true }),
  callback = function(args)
    if autoformat_disabled(args.buf) or not has_intellij() then return end
    format_new_java_code(args.buf)
  end,
})
