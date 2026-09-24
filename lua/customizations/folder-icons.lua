-- One plain folder glyph for every directory.
--
-- mini.icons gives well-known folders (src, doc, config, ...) their own glyphs. This
-- overrides `MiniIcons.get` so every directory shows the same outlined folder
-- (nf-md-folder_outline), like a plain tree. Must run after kickstart's `mini.icons` setup.

if not _G.MiniIcons then return end

local mini_icons_get = MiniIcons.get
MiniIcons.get = function(category, name)
  if category == 'directory' then return '󰉖', 'MiniIconsAzure', false end
  return mini_icons_get(category, name)
end
