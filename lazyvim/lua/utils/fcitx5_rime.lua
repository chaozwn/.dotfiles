local M = {}

local SET_ASCII_CMD = {
  "gdbus",
  "call",
  "--session",
  "--dest",
  "org.fcitx.Fcitx5",
  "--object-path",
  "/rime",
  "--method",
  "org.fcitx.Fcitx.Rime1.SetAsciiMode",
  "true",
}

local function is_linux()
  return (vim.uv or vim.loop).os_uname().sysname == "Linux"
end

local function is_normal_mode()
  return vim.api.nvim_get_mode().mode:sub(1, 1) == "n"
end

function M.set_ascii_mode()
  vim.system(SET_ASCII_CMD, { text = true }, function(result)
    if result.code == 0 or not vim.g.fcitx5_rime_debug then
      return
    end

    vim.schedule(function()
      vim.notify(("fcitx5-rime SetAsciiMode failed: %s"):format(vim.trim(result.stderr or "")), vim.log.levels.WARN)
    end)
  end)
end

function M.setup()
  if not is_linux() or vim.fn.executable("gdbus") ~= 1 then
    return
  end

  local scheduled = false
  local sync_if_normal = function()
    if scheduled then
      return
    end

    scheduled = true
    vim.schedule(function()
      scheduled = false
      if is_normal_mode() then
        M.set_ascii_mode()
      end
    end)
  end

  local group = vim.api.nvim_create_augroup("Fcitx5RimeNormalModeAscii", { clear = true })

  vim.api.nvim_create_autocmd({ "FocusGained", "VimEnter", "WinEnter" }, {
    group = group,
    desc = "Switch fcitx5-rime to ASCII when Neovim is in normal mode",
    callback = sync_if_normal,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    desc = "Keep fcitx5-rime ASCII when entering normal mode",
    callback = sync_if_normal,
  })

  sync_if_normal()
end

return M
