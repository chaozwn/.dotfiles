### Introduction

install `homebrew`

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

install `fish`

> mac

```shell
brew install fish
sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
```

> linux

```shell
brew install fish
sudo sh -c 'echo /home/linuxbrew/.linuxbrew/bin/fish >> /etc/shells'
chsh -s /home/linuxbrew/.linuxbrew/bin/fish
```

install kitty

```shell
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
```
