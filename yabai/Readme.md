# 🛠️ Installation

## NOTE

`桌面与程序坞`关闭`根据最近的使用情况自动重新排列空间`

```shell
git clone https://github.com/chaozwn/yabai.git ~/.config/yabai
```

## Install yabai

```shell
brew install koekeishiya/formulae/yabai
brew install jq
```

## Start yabai

```shell
# start yabai
yabai --start-service
```

## Stop yabai

```shell
# stop yabai
yabai --stop-service
```

## Restart yabai

```shell
# restart yabai
yabai --restart-service
```

## Upgrade yabai

```shell
# upgrade yabai
brew upgrade yabai
```

### Update refresh

```shell
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
```
