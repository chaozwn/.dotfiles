return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "go", "gomod", "gowork", "gotmpl" },
      root = { "go.work", "go.mod" },
    })
  end,
  { import = "lazyvim.plugins.extras.lang.go" },
  -- 强制使用 Mason 安装的 golangci-lint,避免 $PATH 中残留的旧版本
  -- (例如 ~/go/bin/golangci-lint v1.57 用 go1.21 编译,无法解析 go1.24+ 的 export data,
  --  会报: "could not load export data ... unsupported version: 2",linter exit code 3)
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        golangcilint = {
          cmd = require("utils").mason_bin("golangci-lint"),
        },
      },
    },
  },
}
