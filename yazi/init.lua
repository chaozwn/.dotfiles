require("smart-enter"):setup {
  open_multi = true,
}
require("eza-preview"):setup()

-- Yatline expects color strings. Read them from the generated flavor so a
-- wallpaper change updates the bar on the next Yazi start.
local function flavor_text()
  local root = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config")
  local file = io.open(root .. "/yazi/flavors/noctalia.yazi/flavor.toml", "r")
  if not file then
    return ""
  end
  local text = file:read("*a")
  file:close()
  return text
end

local flavor = flavor_text()

local function flavor_hex(section, key, part)
  local body = flavor:match("%[" .. section .. "%]([^%[]*)") or ""
  local row = body:match("\n%s*" .. key .. "%s*=%s*{[^\n]*")
  if not row then
    return nil
  end
  return row:match(part .. '%s*=%s*"(#%x%x%x%x%x%x)"')
end

local noctalia_theme = {
  section_separator = { open = "", close = "" },
  part_separator = { open = "", close = "" },
  inverse_separator = { open = "", close = "" },

  style_a = {
    fg = flavor_hex("mode", "normal_main", "fg"),
    bg_mode = {
      normal = flavor_hex("mode", "normal_main", "bg"),
      select = flavor_hex("mode", "select_main", "bg"),
      un_set = flavor_hex("mode", "unset_main", "bg"),
    },
  },
  style_b = {
    fg = flavor_hex("mode", "normal_alt", "fg"),
    bg = flavor_hex("mode", "normal_alt", "bg"),
  },
  style_c = {
    fg = flavor_hex("mgr", "cwd", "fg"),
    bg = flavor_hex("which", "mask", "bg"),
  },

  permissions_t_fg = flavor_hex("status", "perm_type", "fg"),
  permissions_r_fg = flavor_hex("status", "perm_read", "fg"),
  permissions_w_fg = flavor_hex("status", "perm_write", "fg"),
  permissions_x_fg = flavor_hex("status", "perm_exec", "fg"),
  permissions_s_fg = flavor_hex("status", "perm_sep", "fg"),

  selected = { icon = "󱊅 ", fg = flavor_hex("mgr", "marker_selected", "fg") },
  copied = { icon = "󰆏 ", fg = flavor_hex("mgr", "marker_copied", "fg") },
  cut = { icon = "󰆐 ", fg = flavor_hex("mgr", "marker_cut", "fg") },

  total = { icon = "󰆙 ", fg = flavor_hex("mode", "select_main", "bg") },
  success = { icon = "󰄸 ", fg = flavor_hex("mode", "normal_main", "bg") },
  failed = { icon = "󰱝 ", fg = flavor_hex("notify", "title_error", "fg") },
}

require("searchjump"):setup {
  unmatch_fg = flavor_hex("tabs", "inactive", "fg"),
  match_str_fg = flavor_hex("mode", "normal_main", "fg"),
  match_str_bg = flavor_hex("mode", "normal_main", "bg"),
  label_fg = flavor_hex("mode", "unset_main", "fg"),
  label_bg = flavor_hex("mode", "unset_main", "bg"),
  only_current = false, -- only search the current window
  -- search_patterns = {}  -- demo:{"%.e%d+","s%d+e%d+"}
}

require("yatline"):setup {
  theme = noctalia_theme,
  tab_width = 20,
  tab_use_inverse = false,
  show_background = true,
  display_header_line = true,
  display_status_line = true,

  header_line = {
    left = {
      section_a = { { type = "line", custom = false, name = "tabs", params = { "left" } } },
      section_b = {},
      section_c = {},
    },
    right = {
      section_a = {
        { type = "string", custom = false, name = "date", params = { "%X" } },
      },
      section_b = {
        { type = "string", custom = false, name = "date", params = { "%Y-%m-%d" } },
      },
      section_c = {
        -- { type = "coloreds", custom = false, name = "githead" },
      },
    },
  },

  status_line = {
    left = {
      section_a = {
        { type = "string", custom = false, name = "tab_mode" },
      },
      section_b = {
        { type = "string", custom = false, name = "hovered_size" },
      },
      section_c = {
        { type = "string", custom = false, name = "hovered_name" },
        { type = "coloreds", custom = false, name = "count" },
      },
    },
    right = {
      section_a = {
        { type = "string", custom = false, name = "cursor_position" },
      },
      section_b = {
        { type = "string", custom = false, name = "cursor_percentage" },
      },
      section_c = {
        { type = "string", custom = false, name = "hovered_file_extension", params = { true } },
      },
    },
  },
}
