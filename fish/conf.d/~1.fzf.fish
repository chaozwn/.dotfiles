# 设置tokyonight主题
source ~/.config/fish/themes/tokyonight_moon.sh

# 设置fzf界面为60%
set -x FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS 
  --cycle
  --layout=reverse
  --height 60%
  --ansi
  --preview-window=right:70%
  --bind=ctrl-u:half-page-up,ctrl-d:half-page-down,ctrl-x:jump
  --bind=ctrl-f:preview-page-down,ctrl-b:preview-page-up
  --bind=ctrl-a:beginning-of-line,ctrl-e:end-of-line
  --bind=ctrl-j:down,ctrl-k:up
"

# 设置diffview的highlighter
set fzf_diff_highlighter delta --paging=never --width=20

# 设置fzf搜索
# <C-t> 搜索目录
# <C-g> 搜索git log
# <C-s> 搜索git status
# <C-p> 搜索progress
fzf_configure_bindings \
    --directory=\ct \
    --git_log=\cg \
    --git_status=\cs \
    --history= \
    --processes=\cp \
    --variables=
