# 管理neovim的版本
function bob --wraps bob
    command bob $argv
    set used (cat ~/.local/share/bob/used)
    set src ~/.local/share/bob/$used
    set dest ~/.local/share/bob-nvim
    test -L $dest
    and unlink $dest
    ln -s $src $dest
end
