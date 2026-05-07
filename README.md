# .dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot). Supports **macOS**, **Arch Linux** (native `pacman`), **Fedora** / **Ubuntu**-family (native `dnf` / `apt`), and other **Linux** setups (Homebrew on x86_64).

## One-click Install

```bash
git clone --recursive https://github.com/chaozwn/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && bash bootstrap.sh
```

That's it. `bootstrap.sh` will run the following steps automatically:

| Step | What it does |
|------|-------------|
| 1–2 | **macOS / Linux (non-Arch-Fedora-Ubuntu or `DOTFILES_USE_BREW=1`)**: Install [Homebrew](https://brew.sh) and packages from `brew/brew-both.txt` + `brew/brew-mac.txt` or `brew/brew-linux.txt`. **Arch Linux (default)**: `scripts/bootstrap-arch.sh` via `pacman`. **Fedora**: `scripts/bootstap-fedora.sh` via `dnf`. **Ubuntu** / **Linux Mint** / **Pop!_OS** (default): `scripts/bootstrap-ubuntu.sh` via `apt` (enable `universe` if needed) and **[yazi](https://snapcraft.io/yazi) via `snap install`**. All without Homebrew unless you opt in. |
| 3 | Set [fish](https://fishshell.com) as the default shell (`/opt/homebrew`, Linuxbrew, or `/usr/bin/fish` on Arch) |
| 4 | Install [Nerd Fonts](https://www.nerdfonts.com) (JetBrains Mono): Homebrew cask on macOS; `pacman` package or `~/.dotfiles/fonts/*.ttf` on Linux |
| 5 | Symlink all config files via dotbot |
| 6 | Install Node.js via fish [nvm](https://github.com/jorgebucaran/nvm.fish) + global npm packages |

### macOS vs Arch / Fedora / Ubuntu

- **Same repo, same symlinks**: `fish/`, `tmux/`, editors, etc. are shared. mac-only tools (yabai, sketchybar, …) stay in the repo; on Linux they simply are not used.
- **Optional Homebrew on Arch** (x86_64): run `DOTFILES_USE_BREW=1 bash bootstrap.sh` to use Linuxbrew instead of `scripts/bootstrap-arch.sh`.
- **Per-machine overrides**: create `~/.config/fish/local.fish` (gitignored name `fish/local.fish` in repo) to unset proxy, extra `PATH`, etc., without forking the main `config.fish`.

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
