# proxy
set -x https_proxy http://127.0.0.1:7890
set -x http_proxy http://127.0.0.1:7890
set -x all_proxy socks5://127.0.0.1:7890

# Cursor styles
set -gx fish_vi_force_cursor 1
set -gx fish_cursor_default block
set -gx fish_cursor_insert line blink
set -gx fish_cursor_visual block
set -gx fish_cursor_replace_one underscore

set -Ux TERM xterm-256color
set -Ux XDG_CONFIG_HOME ~/.config
set -Ux NODE_OPTIONS --max-old-space-size=4096 --experimental-vm-modules
# Path
set -x fish_user_paths
fish_add_path /opt/homebrew/bin
fish_add_path /home/linuxbrew/.linuxbrew/bin
fish_add_path ~/.local/bin
fish_add_path ~/.luarocks/bin
fish_add_path /usr/local/sbin
fish_add_path ~/.local/bin/pnpm-bins
fish_add_path ~/.local/share/bob-nvim/bin
fish_add_path ~/miniconda3/bin
fish_add_path ~/.cargo/bin
#fish_add_path ~/.local/share/bob-nvim/nvim-linux64/bin
fish_add_path ~/.local/share/bob-nvim/nvim-macos-arm64/bin
fish_add_path ~/.bun/bin

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# Fish
set fish_emoji_width 2
alias ssh "TERM=xterm-256color command ssh"
alias mosh "TERM=xterm-256color command mosh"

# Emacs
# set -l emacs_path /Applications/Emacs.app/Contents/MacOS
# set -Ux EMACS $emacs_path/Emacs
fish_add_path ~/.emacs.d/bin
# alias emacs $EMACS

# Go
set -x GOPATH ~/go
set -x GOROOT ~/.go
fish_add_path $GOPATH $GOPATH/bin

# fish_add_path -m /etc/profiles/per-user/folke/bin /run/current-system/sw/bin
# Exports
set -x LESS -rF
set -x COMPOSE_DOCKER_CLI_BUILD 1
set -x HOMEBREW_NO_AUTO_UPDATE 1
set -x DOTDROP_AUTOUPDATE no
set -x MANPAGER "nvim +Man!"
set -x MANROFFOPT -c

# 给help添加彩色打印
abbr -a --position anywhere --set-cursor -- -h "-h 2>&1 | bat --plain --language=help"
abbr j just

# Tmux
abbr t tmux
abbr tc 'tmux attach'
abbr ta 'tmux attach -t'
abbr tad 'tmux attach -d -t'
abbr ts 'tmux new -s'
abbr tl 'tmux ls'
abbr tk 'tmux kill-session -t'
abbr mux tmuxinator

# Files & Directories
abbr mv "mv -iv"
abbr cp "cp -riv"
abbr mkdir "mkdir -vp"
alias ls "eza --color=always --icons --group-directories-first"
alias la 'eza --color=always --icons --group-directories-first --all --header'
alias ll 'eza --color=always --icons --group-directories-first --all --header --long'
alias lg 'eza --color=always --icons --group-directories-first --all --header --long --git'
alias lt 'eza --tree -L 2 --icons'
abbr l ll
abbr ncdu "ncdu --color dark"

# Editor
abbr vim nvim
abbr vi nvim
abbr v nvim
abbr sv sudoedit
abbr vudo sudoedit
alias astronvim "NVIM_APPNAME=astronvim nvim"
abbr av astronvim

# Dev
abbr git hub
abbr topgit topgrade --only git_repos
# abbr g hub

set -x LG_CONFIG_FILE ~/.config/lazygit/config.yml

alias lazygit "TERM=xterm-256color command lazygit"
abbr gg lazygit
# abbr gl 'hub l --color | devmoji --log --color | less -rXF'
abbr gs "hub st"
abbr gb "hub checkout -b"
abbr gc "hub commit"
abbr gpr "hub pr checkout"
abbr gm "hub branch -l main | rg main > /dev/null 2>&1 && hub checkout main || hub checkout master"
abbr gcp "hub commit -p"
abbr gpp "hub push"
abbr gp "hub pull"

# Other
abbr df "grc /bin/df -h"
abbr ntop "ultra --monitor"
abbr ytop btm
abbr gotop btm
abbr fda "fd -IH"
abbr rga "rg -uu"
abbr grep rg
abbr suod sudo
abbr show-cursor "tput cnorm"
abbr hide-cursor "tput civis"

set -gx GOPATH "$HOME/go"
set -gx GOBIN "$GOPATH/bin"
set -gx PATH "$GOBIN" $PATH

if test -f "$HOME/.g/env"
    source "$HOME/.g/env"
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f ~/miniconda3/bin/conda
    eval ~/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "~/miniconda3/etc/fish/conf.d/conda.fish"
        . "~/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "~/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

zoxide init fish | source

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/zhaown/Downloads/google-cloud-sdk/path.fish.inc' ]; . '/Users/zhaown/Downloads/google-cloud-sdk/path.fish.inc'; end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# 设置java
set -Ux JAVA_HOME /Users/zhaown/workspace/ai_project/nest_admin_source/infinity-sql/release/byzer-lang-all-in-one-darwin-amd64-3.3.0-1.0.0/jdk8/Contents/Home  
fish_add_path $HOME/.local/bin
