return {
  { import = "lazyvim.plugins.extras.editor.overseer" },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        {
          "<leader>o",
          group = "overseer",
          icon = "󱁤",
        },
      },
    },
  },
}
