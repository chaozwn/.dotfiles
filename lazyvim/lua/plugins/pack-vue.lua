-- Detect Vue at spec-load time. If the project wants Vue, force the
-- TypeScript LSP to `vtsls` BEFORE LazyVim's typescript extra is
-- required (it reads `vim.g.lazyvim_ts_lsp` at import time), since
-- `tsgo` doesn't support `@vue/typescript-plugin`.
local needs_vue = LazyVim.extras.wants({
  ft = "vue",
  root = { "vue.config.js" },
})
if needs_vue then
  vim.g.lazyvim_ts_lsp = "vtsls"
end

return {
  recommended = function()
    return needs_vue
  end,
  { import = "lazyvim.plugins.extras.lang.vue" },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              tsserver = { maxTsServerMemory = 8192 },
            },
          },
        },
        volar = {
          settings = {
            vue = {
              server = {
                maxOldSpaceSize = 8192,
              },
            },
          },
        },
      },
    },
  },
}
