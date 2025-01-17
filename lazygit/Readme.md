# Lazygit Neovim config

set below config in you bashrc or zshrc

```sh
export XDG_CONFIG_HOME="$HOME/.config"
```

```shell
git clone https://github.com/chaozwn/lazygit.git ~/.config/lazygit
```

# Install 

```shell
brew install delta
npm install -g git-cz
```

# add ~/.gigconfig

```
[core]
    editor = nvim
    pager = delta

[interactive]
    diffFilter = delta --color-only --show-syntax-themes --features=interactive

[delta]
    side-by-side = true
    line-numbers = true
    minus-style                   = syntax "#3f2d3d"
    minus-non-emph-style          = syntax "#3f2d3d"
    minus-emph-style              = syntax "#763842"
    minus-empty-line-marker-style = syntax "#3f2d3d"
    line-numbers-minus-style      = "#914c54"
    plus-style                    = syntax "#283b4d"
    plus-non-emph-style           = syntax "#283b4d"
    plus-emph-style               = syntax "#316172"
    plus-empty-line-marker-style  = syntax "#283b4d"
    line-numbers-plus-style       = "#449dab"
    line-numbers-zero-style       = "#3b4261"

[safe]
    directory = /opt/homebrew
    directory = /opt/homebrew/Library/Taps/homebrew/homebrew-core/
    directory = /opt/homebrew/Library/Taps/homebrew/homebrew-cask/
    directory = /opt/homebrew/Library/Taps/homebrew/homebrew-services/

[pull]
    rebase = true

[merge]
    conflictStyle = zdiff3

[delta "interactive"]
    keep-plus-minus-markers = false

[rerere]
    enabled = true

[rebase]
    updateRefs = true

[alias]
    ; https://stackoverflow.com/questions/1057564/pretty-git-branch-graphs
    lg1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all
    lg2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'
    lg = lg1

    ; How to stash changes while keeping the changes in the working directory? (Git)
    ; https://stackoverflow.com/a/60557208/1336788
    stash-keep = "!f() { git stash store --message \"$(date +'%Y-%m-%d %H:%M:%S')\" \"$1\"; }; f $(git stash create)"

[commit]
    verbose = true
[init]
    defaultBranch = main
[push]
    default = upstream
```
