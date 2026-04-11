set --query nvm_mirror || set --global nvm_mirror https://nodejs.org/dist
set --query XDG_DATA_HOME || set --local XDG_DATA_HOME ~/.local/share
set --global nvm_data $XDG_DATA_HOME/nvm

# Canonical version: nvm/VERSION (and repo-root .nvmrc). Resolve dotfiles root from this file (works when ~/.config/fish is symlinked).
set -l _nvm_ver v22.13.0
set -l _conf (status filename)
if command -q realpath
    set _conf (realpath $_conf 2>/dev/null)
end
if test -n "$_conf"
    set -l _root (path dirname (path dirname (path dirname $_conf)))
    set -l _verfile $_root/nvm/VERSION
    if test -f "$_verfile"
        set _nvm_ver (string trim (cat "$_verfile"))
    end
end
# Only set defaults if missing so local `set -U nvm_*` is not overwritten on every shell start.
set --query nvm_default_version || set --universal nvm_default_version $_nvm_ver
set --query nvm_default_packages || set --universal nvm_default_packages yarn pnpm devmoji ultra

function _nvm_install --on-event nvm_install
    test ! -d $nvm_data && command mkdir -p $nvm_data
    echo "Downloading the Node distribution index..." 2>/dev/null
    _nvm_index_update
end

function _nvm_update --on-event nvm_update
    set --query --universal nvm_data && set --erase --universal nvm_data
    set --query --universal nvm_mirror && set --erase --universal nvm_mirror
    set --query nvm_mirror || set --global nvm_mirror https://nodejs.org/dist
end

function _nvm_uninstall --on-event nvm_uninstall
    command rm -rf $nvm_data

    set --query nvm_current_version && _nvm_version_deactivate $nvm_current_version

    set --names | string replace --filter --regex -- "^nvm" "set --erase nvm" | source
    functions --erase (functions --all | string match --entire --regex -- "^_nvm_")
end

if status is-interactive && set --query nvm_default_version && ! set --query nvm_current_version
    nvm use --silent $nvm_default_version
end

