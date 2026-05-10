# Rime

Personal customization layer on top of [iDvel/rime-ice](https://github.com/iDvel/rime-ice) (雾凇拼音), with a cross-platform vim mode implemented via `lua_processor`.

## Strategy

This folder only holds **my customization delta**, not the upstream dictionary / schema files.

- `scripts/install_rime.sh` clones `iDvel/rime-ice` into the user dir on first run
  - Linux (fcitx5): `~/.local/share/fcitx5/rime`
  - macOS (Squirrel): `~/Library/Rime`
- `dotbot` then symlinks `./rime/rime.lua`, every `*.custom.yaml` under `./rime/`, and every `*.lua` under `./rime/lua/` into that user dir, layered on top of rime-ice
- After any change, redeploy:
  - Linux fcitx5: `dbus-send --type=method_call --dest=org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.ReloadConfig` (or right-click tray → Restart)
  - macOS Squirrel: right-click Squirrel icon → 重新部署

## Files

| File                          | What it does                                                                  |
|-------------------------------|-------------------------------------------------------------------------------|
| `rime.lua`                    | librime-lua entry point; exports `vim_mode = require("vim_mode")`             |
| `default.custom.yaml`         | Global tweaks: page size, Shift_L=commit_code, key bindings (no schema list override; rime-ice's own list stands) |
| `rime_ice.custom.yaml`        | Hooks `lua_processor@vim_mode` into the rime_ice schema and registers a `vmode` switch (on by default) |
| `lua/vim_mode.lua`            | The processor itself: Esc / Ctrl+[ clears candidates and switches to ASCII; i/a/o/c leaves normal-mode state without forcing CN/ASCII afterwards |
| `squirrel.custom.yaml`        | macOS: solarized_dark theme + per-app `vmode: true` (Cursor, VSCode, kitty, Ghostty, JetBrains, Obsidian, …) |
| `fcitx5.custom.yaml`          | Linux: per-app initial ASCII / punctuation options, plus explicit `vmode: true` for common editor/shell app ids |

`*.custom.yaml` is gitignored by rime-ice itself, so layering them in won't conflict with `git pull` in the rime-ice user dir.

## Vim mode — how it works

Inspired by [lei4519/blog#85](https://github.com/lei4519/blog/issues/85).

With the `rime_ice` schema, `vmode` is enabled by default:

1. **Esc / Ctrl+[ pressed**:
   - clear any active preedit / candidate menu
   - switch to ASCII (English)
   - mark *normal mode*
2. **i / a / o / c pressed while in normal mode**:
   - clear normal-mode flag
   - stay in ASCII (English)
   - do not force input mode afterwards, so you can manually switch to Chinese in insert mode

Caveats (from upstream):
- Rime can't actually see Vim's mode, so this heuristic isn't 100%. Pressing Esc / Ctrl+[ when you're already in normal mode resets state harmlessly.
- Per-app initial ASCII / punctuation behavior depends on librime-rime correctly reporting the current app id. On Linux, set fcitx5 *Global Options → Shared Input State = No*, otherwise per-app options don't re-apply on focus change.
- DMS / Quickshell overlays can create transient input contexts after restart; keeping `vmode` enabled at the schema level avoids losing vim-mode when those app ids are empty or unstable.
- App identifiers on Linux:

  ```bash
  dbus-send --print-reply=literal --dest=org.fcitx.Fcitx5 \
    /controller org.fcitx.Fcitx.Controller1.DebugInfo
  ```

## Adding more customization

1. Drop the file into the right path under `./rime/` (matching the layout above).
2. The dotbot entries in `../install.conf.yaml` already cover `./rime/rime.lua`, `./rime/*.custom.yaml`, and `./rime/lua/*.lua`, so a re-run of `bash ../install` is enough.
3. Redeploy Rime.

## Mirroring vmode to other schemas

`rime_ice.custom.yaml` only patches the `rime_ice` schema. If you also use 双拼 etc., create a sibling file like `double_pinyin_flypy.custom.yaml` with the same body:

```yaml
patch:
  engine/processors/@before 1: lua_processor@vim_mode
  switches/+:
    - name: vmode
      states: [ NoVim, Vim ]
      reset: 1
```
