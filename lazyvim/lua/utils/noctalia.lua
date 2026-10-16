local M = {}

local function theme_file()
  return vim.fn.stdpath("config") .. "/lua/matugen.lua"
end

--- The generated matugen.lua also listens for SIGUSR1 and would paint an
--- opaque background. Keep a single handler that reapplies through here.
local function claim_signal()
  if _G.__matugen_signal then
    _G.__matugen_signal:stop()
    _G.__matugen_signal:close()
    _G.__matugen_signal = nil
  end
  if _G.__noctalia_signal then
    return
  end
  local signal = vim.uv.new_signal()
  if not signal then
    return
  end
  local ok = signal:start(
    "sigusr1",
    vim.schedule_wrap(function()
      M.apply({ redraw = true })
    end)
  )
  if not ok then
    signal:close()
    return
  end
  _G.__noctalia_signal = signal
end

--- Reload the generated Noctalia palette and push it to the UI.
--- `redraw` is only for live updates; the first apply happens during startup.
function M.apply(opts)
  opts = opts or {}
  package.loaded["matugen"] = nil
  local ok, matugen = pcall(require, "matugen")
  if not ok then
    vim.notify("Noctalia 主题加载失败: " .. tostring(matugen), vim.log.levels.WARN)
    return false
  end
  local applied, err = pcall(matugen.setup)
  if not applied then
    vim.notify("Noctalia 主题应用失败: " .. tostring(err), vim.log.levels.WARN)
    return false
  end

  claim_signal()
  vim.g.colors_name = "noctalia"
  if opts.redraw then
    pcall(vim.api.nvim_exec_autocmds, "ColorScheme", { pattern = "noctalia" })
    pcall(function()
      require("lualine").refresh()
    end)
    vim.cmd("redraw!")
  end
  return true
end

--- Watch lua/matugen.lua so an already-open Neovim follows wallpaper recolors.
--- SIGUSR1 from the Noctalia template is not enough: this Neovim build splits
--- the TUI from the editor, and highlight changes are not flushed until redraw.
function M.watch()
  if _G.__noctalia_theme_watch then
    return
  end

  local dir = vim.fn.fnamemodify(theme_file(), ":h")
  local handle = vim.uv.new_fs_event()
  local timer = vim.uv.new_timer()
  if not handle or not timer then
    if handle then
      handle:close()
    end
    if timer then
      timer:close()
    end
    return
  end

  local ok, err = handle:start(dir, {}, function(watch_err, filename)
    if watch_err or not filename or not filename:match("matugen%.lua$") then
      return
    end
    timer:stop()
    timer:start(
      80,
      0,
      vim.schedule_wrap(function()
        M.apply({ redraw = true })
      end)
    )
  end)
  if not ok then
    handle:close()
    timer:close()
    vim.notify("Noctalia 主题监听失败: " .. tostring(err), vim.log.levels.WARN)
    return
  end

  _G.__noctalia_theme_watch = true
end

function M.setup()
  M.apply()
  M.watch()
end

return M
