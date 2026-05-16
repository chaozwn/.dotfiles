return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      root = { "tsconfig.json", "package.json", "jsconfig.json" },
    })
  end,
  { import = "lazyvim.plugins.extras.lang.typescript" },
  -- Two concerns handled here:
  -- 1. Safety: ensure `opts.servers.vtsls.filetypes` is a table so the
  --    upstream vue extra's `table.insert(opts.servers.vtsls.filetypes, "vue")`
  --    doesn't crash when tsgo is selected but vue extra still loads
  --    (e.g. via session restore opening a .vue buffer).
  -- 2. Tuning: bump `maxTsServerMemory` only when vtsls is actually the
  --    selected TS LSP (see `pack-vue.lua` for when that happens).
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.vtsls = opts.servers.vtsls or {}
      opts.servers.vtsls.filetypes = opts.servers.vtsls.filetypes or {}
      if vim.g.lazyvim_ts_lsp == "vtsls" then
        opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls, {
          settings = {
            typescript = {
              tsserver = { maxTsServerMemory = 8192 },
            },
          },
        })
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      -- "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {},
        -- ["neotest-vitest"] = {},
      },
    },
  },
}
