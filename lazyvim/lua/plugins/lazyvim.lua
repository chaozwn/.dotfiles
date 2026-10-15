return {
  "LazyVim/LazyVim",
  opts = {
    colorscheme = function()
      local ok, noctalia = pcall(require, "utils.noctalia")
      if ok then
        noctalia.setup()
        return
      end
      local fallback, matugen = pcall(require, "matugen")
      if fallback then
        matugen.setup()
      end
    end,
  },
}
