local prefix_diff_view = "<leader>g"

return {
  "dlyongemallo/diffview.nvim",
  cmd = { "DiffviewOpen" },
  keys = {
    {
      prefix_diff_view .. "E",
      function()
        vim.cmd([[DiffviewOpen]])
      end,
      desc = "Open Git Diffview",
    },
    {
      prefix_diff_view .. "t",
      function()
        vim.cmd([[DiffviewFileHistory]])
      end,
      desc = "Open current branch git history",
    },
    {
      prefix_diff_view .. "T",
      function()
        vim.cmd([[DiffviewFileHistory %]])
      end,
      desc = "Open current file git history",
    },
  },
  opts = function()
    local actions = require("diffview.actions")

    return {
      enhanced_diff_hl = true,
      view = {
        default = { winbar_info = false, disable_diagnostics = true, layout = "diff2_horizontal" },
        file_history = { winbar_info = false, disable_diagnostics = true },
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = {
          position = "left",
          width = 35,
        },
      },
      hooks = {
        view_enter = function()
          vim.keymap.set("n", prefix_diff_view .. "d", function()
            vim.cmd([[DiffviewClose]])
          end, { desc = "Close Git Diffview", noremap = true, silent = true })
        end,
        view_leave = function()
          vim.keymap.set("n", prefix_diff_view .. "d", function()
            vim.cmd([[DiffviewOpen]])
          end, { desc = "Open Git Diffview", noremap = true, silent = true })
        end,
      },
      keymaps = {
        view = {
          { "n", "<leader>b", actions.focus_files, { desc = "Bring focus to the file panel" } },
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
        },
        file_panel = {
          { "n", "<leader>b", actions.focus_files, { desc = "Bring focus to the file panel" } },
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
        },
      },
    }
  end,
}
