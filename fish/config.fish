# proxy (override in ~/.config/fish/local.fish if needed, e.g. on machines without 7890)
set -x https_proxy http://127.0.0.1:7890
set -x http_proxy http://127.0.0.1:7890
set -x all_proxy socks5://127.0.0.1:7890

# Cursor styles
set -gx fish_vi_force_cursor 1
set -gx fish_cursor_default block
set -gx fish_cursor_insert line blink
set -gx fish_cursor_visual block
set -gx fish_cursor_replace_one underscore

set -gx TERM xterm-256color
set -gx XDG_CONFIG_HOME ~/.config
set -gx NODE_OPTIONS --max-old-space-size=4096 --experimental-vm-modules

# Path
set -x fish_user_paths
if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
end
if test -d /home/linuxbrew/.linuxbrew/bin
    fish_add_path /home/linuxbrew/.linuxbrew/bin
end
fish_add_path ~/.local/bin
fish_add_path ~/.luarocks/bin
fish_add_path /usr/local/sbin
fish_add_path ~/.local/bin/pnpm-bins
fish_add_path ~/miniconda3/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.bun/bin

# Bob (Neovim): nvim-bin is the official shim (current bob); bob-nvim/bin is version root with bin/ (new tarball layout);
# nvim-*-*/bin is legacy extracted Neovim folder names.
if test -d ~/.local/share/bob/nvim-bin
    fish_add_path ~/.local/share/bob/nvim-bin
else if test -d ~/.local/share/bob-nvim/bin
    fish_add_path ~/.local/share/bob-nvim/bin
else
    set -l _bob_dirs
    switch (uname)
        case Darwin
            set _bob_dirs ~/.local/share/bob-nvim/nvim-macos-arm64/bin ~/.local/share/bob-nvim/nvim-macos-x86_64/bin
        case Linux
            set _bob_dirs ~/.local/share/bob-nvim/nvim-linux-arm64/bin ~/.local/share/bob-nvim/nvim-linux64/bin
    end
    for _bob in $_bob_dirs
        if test -d "$_bob"
            fish_add_path "$_bob"
            break
        end
    end
end

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
abbr topgit topgrade --only git_repos

set -x LG_CONFIG_FILE ~/.config/lazygit/config.yml

alias lazygit "TERM=xterm-256color command lazygit"
abbr gg lazygit
# abbr gl 'git log --color | devmoji --log --color | less -rXF'
abbr gs "git status"
abbr gb "git checkout -b"
abbr gc "git commit"
abbr gpr "gh pr checkout"
abbr gm "git branch -l main | rg main > /dev/null 2>&1 && git checkout main || git checkout master"
abbr gcp "git commit -p"
abbr gpp "git push"
abbr gp "git pull"

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

# Go (managed by g version manager)
set -gx GOPATH "$HOME/go"
set -gx GOBIN "$GOPATH/bin"
fish_add_path $GOBIN

if test -f "$HOME/.g/env"
    source "$HOME/.g/env"
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f ~/miniconda3/bin/conda
    eval ~/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f ~/miniconda3/etc/fish/conf.d/conda.fish
        . ~/miniconda3/etc/fish/conf.d/conda.fish
    else
        fish_add_path ~/miniconda3/bin
    end
end
# <<< conda initialize <<<

zoxide init fish | source

# The next line updates PATH for the Google Cloud SDK.
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
else if test -f "$HOME/Downloads/google-cloud-sdk/path.fish.inc"
    source "$HOME/Downloads/google-cloud-sdk/path.fish.inc"
end

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# Java — same project JDK on Mac if present; else Arch default / other common paths
set -l _jdk_project $HOME/workspace/ai_project/nest_admin_source/infinity-sql/release/byzer-lang-all-in-one-darwin-amd64-3.3.0-1.0.0/jdk8/Contents/Home
set -l _jdk_corretto $HOME/Library/Java/JavaVirtualMachines/corretto-17.0.8/Contents/Home
if test -d "$_jdk_project"
    set -gx JAVA_HOME "$_jdk_project"
else if test -d "$_jdk_corretto"
    set -gx JAVA_HOME "$_jdk_corretto"
else if test -d /usr/lib/jvm/default
    set -gx JAVA_HOME /usr/lib/jvm/default
else if test -d /usr/lib/jvm/java-17-openjdk
    set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
else if test -d /usr/lib/jvm/java-21-openjdk
    set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk
end
if set -q JAVA_HOME
    fish_add_path $JAVA_HOME/bin
end

# pnpm — Mac keeps ~/Library/pnpm; Linux uses XDG-style default
if test (uname) = Darwin
    set -gx PNPM_HOME "$HOME/Library/pnpm"
else
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
end
fish_add_path $PNPM_HOME

if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
