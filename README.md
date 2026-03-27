# .dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot). Supports **macOS** and **Linux**.

## One-click Install

```bash
git clone --recursive https://github.com/chaozwn/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && bash bootstrap.sh
```

That's it. `bootstrap.sh` will run the following steps automatically:

| Step | What it does |
|------|-------------|
| 1 | Install [Homebrew](https://brew.sh) (skipped if already installed) |
| 2 | Install all brew packages (`brew/brew-both.txt` + platform-specific list) |
| 3 | Set [fish](https://fishshell.com) as the default shell |
| 4 | Install [Nerd Fonts](https://www.nerdfonts.com) (JetBrains Mono) |
| 5 | Symlink all config files via dotbot |
| 6 | Install Node.js via [nvm](https://github.com/nvm-sh/nvm) + global npm packages |

## What's Included

| Tool | Config dir | Description |
|------|-----------|-------------|
| [fish](https://fishshell.com) | `fish/` | Shell |
| [starship](https://starship.rs) | `starship/` | Prompt |
| [tmux](https://github.com/tmux/tmux) | `tmux/` | Terminal multiplexer |
| [Neovim (LazyVim)](https://www.lazyvim.org) | `lazyvim/` | Editor |
| [yazi](https://yazi-rs.github.io) | `yazi/` | File manager |
| [lazygit](https://github.com/jesseduffield/lazygit) | `lazygit/` | Git TUI |
| [ghostty](https://ghostty.org) | `ghostty/` | Terminal emulator |
| [kitty](https://sw.kovidgoyal.net/kitty/) | `kitty/` | Terminal emulator |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | `fastfetch/` | System info |
| [glow](https://github.com/charmbracelet/glow) | `glow/` | Markdown reader |
| [yabai](https://github.com/koekeishiya/yabai) | `yabai/` | Window manager (macOS) |
| [skhd](https://github.com/koekeishiya/skhd) | `skhd/` | Hotkey daemon (macOS) |
| [sketchybar](https://github.com/FelixKratz/SketchyBar) | `sketchybar/` | Status bar (macOS) |
| [borders](https://github.com/FelixKratz/JankyBorders) | `borders/` | Window borders (macOS) |

## Manual Steps

Some things can't be fully automated:

- **macOS window management** — yabai requires [SIP partially disabled](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection) for full functionality.
- **Ghostty** — install from [ghostty.org](https://ghostty.org) or `brew install --cask ghostty`.
- **Neovim** — on first launch, LazyVim will auto-install plugins. Just wait for it to finish.

## Update

Pull the latest changes and re-link:

```bash
cd ~/.dotfiles && git pull && bash install
```

## Structure

```
.dotfiles/
├── bootstrap.sh          # Full one-click setup
├── install               # Dotbot entry point (symlinks only)
├── install.conf.yaml     # Dotbot config
├── brew/                 # Homebrew install scripts & package lists
├── scripts/              # Helper install scripts (fonts, etc.)
├── nvm/                  # Node.js version + global packages
└── <tool>/               # Config dirs (fish, tmux, lazyvim, ...)
```
