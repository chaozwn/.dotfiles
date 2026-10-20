local in_tmux = vim.env.TMUX ~= nil

return {
  "smart-splits-nvim/smart-splits.nvim",
  -- tmux only forwards C-hjkl into Neovim after this plugin sets @pane-is-vim.
  lazy = not in_tmux,
  dependencies = {
    { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
  },
  keys = {
    { "<c-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
    { "<c-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" },
    { "<c-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" },
    { "<c-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
    { "<c-up>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    { "<c-down>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    { "<c-left>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    { "<c-right>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
  },
  opts = function()
    local opts = {
      ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
      ignored_buftypes = { "nofile" },
    }
    if vim.env.TMUX then
      opts.mux = { backend = "smart-splits-backend-tmux" }
    end
    return opts
  end,
}
