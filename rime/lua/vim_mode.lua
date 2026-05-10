-- Cross-platform Rime "vim mode" via lua_processor.
-- Source / credit:
--   https://github.com/lei4519/blog/issues/85
--   https://github.com/halfmoonvic/Rime/blob/master/lua/vim_mode.lua
--
-- Behavior (when the `vmode` switch is on; rime_ice enables it by default):
--   * Press <Esc> / <C-[>:
--       - clear any active preedit / candidate menu first
--       - always switch to ASCII (English) mode
--       - mark "in normal mode"
--   * Press i / a / o / c while in normal mode:
--       - clear normal-mode flag, but keep ASCII mode
--
-- Notes:
--   * Module-level state means it's per-engine, shared across windows. Good
--     enough in practice — see issue #85 for caveats.
--   * We filter out key release events to avoid press+release double-fire.

local kRejected = 0  -- consumed by us
local kAccepted = 1  -- handled by us, stop here
local kNoop     = 2  -- pass through to next processor

-- Flip to true and redeploy to write debug lines to TRACE_FILE.
local DEBUG = false

local TRACE_FILE = "/tmp/vim_mode_trace.log"

local function notify(msg)
  if not DEBUG then return end
  local f = io.open(TRACE_FILE, "a")
  if f then
    f:write(os.date("%H:%M:%S "), tostring(msg), "\n")
    f:close()
  end
end

-- Write a header on module load when debugging, so we can prove the file got `require`d.
if DEBUG then
  local f = io.open(TRACE_FILE, "a")
  if f then
    f:write("---- module loaded at ", os.date("%H:%M:%S"), " ----\n")
    f:close()
  end
end

-- Module-level state
local in_normal_mode = false

local KEY_ESC = 65307
local KEY_I = 105
local KEY_A = 97
local KEY_O = 111
local KEY_C = 99

local function is_exit_key(key)
  return key.keycode == KEY_ESC or key:repr() == "Control+bracketleft"
end

local function is_insert_key(keycode)
  return keycode == KEY_I or keycode == KEY_A or keycode == KEY_O or keycode == KEY_C
end

local function vim_mode(key, env)
  if key:release() then
    return kNoop
  end

  local ctx = env.engine.context
  local vmode_on = ctx:get_option("vmode")
  local kc = key.keycode

  notify(string.format(
    "key=%s kc=%d vmode=%s ascii=%s composing=%s menu=%s normal=%s",
    key:repr(),
    kc,
    tostring(vmode_on),
    tostring(ctx:get_option("ascii_mode")),
    tostring(ctx:is_composing()),
    tostring(ctx:has_menu()),
    tostring(in_normal_mode)
  ))

  if not vmode_on then
    return kNoop
  end

  if in_normal_mode and is_insert_key(kc) then
    in_normal_mode = false
    notify("leave normal mode via insert key")
    return kNoop
  end

  if is_exit_key(key) then
    in_normal_mode = true
    if ctx:is_composing() or ctx:has_menu() then
      ctx:clear()
    end
    ctx:set_option("ascii_mode", true)
    notify(string.format("enter normal mode; ascii=%s", tostring(ctx:get_option("ascii_mode"))))
  end

  return kNoop
end

return vim_mode