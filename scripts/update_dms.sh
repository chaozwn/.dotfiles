#!/usr/bin/env bash
set -euo pipefail

DMS_RESTART="${DMS_RESTART:-1}"
DMS_FORCE_CLI="${DMS_FORCE_CLI:-0}"

usage() {
  cat <<'EOF'
Usage: bash scripts/update_dms.sh [--cli] [--no-restart]

Updates DankMaterialShell (dms) using the detected package manager.

Options:
  --cli         Force `dms update` instead of package-manager updates.
  --no-restart Skip `dms restart` after updating.

Environment:
  DMS_FORCE_CLI=1  Same as --cli.
  DMS_RESTART=0    Same as --no-restart.
EOF
}

log() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

aur_helper() {
  local helper

  for helper in paru yay; do
    if command_exists "$helper"; then
      command -v "$helper"
      return 0
    fi
  done

  return 1
}

first_pacman_package() {
  local pkg

  for pkg in dms-shell-bin dms-shell-git dms-shell dms; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      printf '%s\n' "$pkg"
      return 0
    fi
  done

  return 1
}

first_rpm_package() {
  local pkg

  for pkg in dms dms-git dms-shell; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
      printf '%s\n' "$pkg"
      return 0
    fi
  done

  return 1
}

first_dpkg_package() {
  local pkg

  for pkg in dms dms-git; do
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'ok installed'; then
      printf '%s\n' "$pkg"
      return 0
    fi
  done

  return 1
}

update_with_cli() {
  command_exists dms || die "dms command not found. Install DMS first, then rerun this script."

  log "Updating DMS via dms CLI..."
  dms update
}

restart_dms() {
  if [ "$DMS_RESTART" = "0" ]; then
    log "Skipping DMS restart (DMS_RESTART=0)."
    return 0
  fi

  if ! command_exists dms; then
    warn "dms command not found after update; skipping restart."
    return 0
  fi

  log "Restarting DMS..."
  if ! dms restart; then
    warn "DMS update finished, but restart failed. Check logs with: journalctl --user -u dms -n 50"
  fi
}

main() {
  local pkg helper

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --cli)
        DMS_FORCE_CLI=1
        ;;
      --no-restart)
        DMS_RESTART=0
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [ "$(uname -s)" != "Linux" ]; then
    die "DMS is Linux-only; this updater only supports Linux."
  fi

  if [ "$DMS_FORCE_CLI" = "1" ]; then
    update_with_cli
    restart_dms
    return 0
  fi

  if command_exists pacman && pkg="$(first_pacman_package)"; then
    helper="$(aur_helper || true)"
    if [ "$pkg" = "dms-shell-bin" ] || [ "$pkg" = "dms-shell-git" ]; then
      [ -n "$helper" ] || die "$pkg is an AUR package; install paru/yay or rerun with --cli for manual installs."
      log "Updating $pkg via $(basename "$helper")..."
      "$helper" -Syu --needed "$pkg"
    elif [ -n "$helper" ]; then
      log "Updating $pkg via $(basename "$helper")..."
      "$helper" -Syu --needed "$pkg"
    else
      log "Updating $pkg via pacman..."
      sudo pacman -Syu --needed "$pkg"
    fi
  elif command_exists dnf && command_exists rpm && pkg="$(first_rpm_package)"; then
    log "Updating $pkg via dnf..."
    sudo dnf upgrade -y "$pkg"
  elif command_exists apt-get && command_exists dpkg-query && pkg="$(first_dpkg_package)"; then
    log "Updating $pkg via apt..."
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install --only-upgrade -y "$pkg"
  elif command_exists zypper && command_exists rpm && pkg="$(first_rpm_package)"; then
    log "Updating $pkg via zypper..."
    sudo zypper refresh
    sudo zypper update -y "$pkg"
  else
    warn "No DMS package installation detected; falling back to dms CLI."
    update_with_cli
  fi

  restart_dms
}

main "$@"
