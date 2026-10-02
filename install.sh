#!/usr/bin/env bash
#
# Usage: install.sh [--check]
#
# Symlinks each file in `dist/` into `$HOME` and compiles the terminfo entries.
# An existing regular file or a wrong symlink at a target is backed up to
# `<target>.bak.<timestamp>`. Safe to rerun from any directory.
#
#   --check  Report drift without changing anything. Prints nothing and exits 0
#            when clean; otherwise prints one line per problem and exits 1.

#===============================================================================
# CONFIG
#===============================================================================
# Files to link, as `source:target` pairs. Sources are in `dist/`; targets are
# in `$HOME`.
LINKS=(
  _hushlogin:.hushlogin
  _tmux.conf:.tmux.conf
  _vimrc:.vimrc
  _zlogin:.zlogin
  _zshenv:.zshenv
  _zshrc:.zshrc
)

#===============================================================================
# VARIABLES
#===============================================================================
# Absolute paths to the repo and its `dist/` directory.
REPO="$(cd "$(dirname "$0")" && pwd)"
DIR="${REPO}/dist"

#===============================================================================
# FUNCTIONS
#===============================================================================
#-------------------------------------------------------------------------------
# Add symlinks, backing up regular files or wrong symlinks, if any.
# Globals:
#   DIR
#   HOME
#   LINKS
# Outputs:
#   Writes a line to stdout for each backup and link.
#-------------------------------------------------------------------------------
install_links() {
  local timestamp pair src target backup
  timestamp="$(date +%Y%m%d%H%M%S)"

  for pair in "${LINKS[@]}"; do
    src="${DIR}/${pair%%:*}"
    target="${HOME}/${pair#*:}"

    # Skip if already the correct symlink.
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
      continue
    fi

    # Backup if target is a regular file or wrong symlink.
    if [ -e "$target" ] || [ -L "$target" ]; then
      backup="${target}.bak.${timestamp}"
      mv "$target" "$backup"
      echo "Backed up ${target} to ${backup}"
    fi

    ln -s "$src" "$target"
    echo "Linked ${target}"
  done
}

#-------------------------------------------------------------------------------
# Enable italics in tmux and vim. See README.md.
# Globals:
#   DIR
#-------------------------------------------------------------------------------
run_tic() {
  tic -x "${DIR}/terminfo/tmux.terminfo"
  tic -x "${DIR}/terminfo/xterm-256color.terminfo"
}

#-------------------------------------------------------------------------------
# Report drift without changing anything.
# Globals:
#   DIR
#   HOME
#   LINKS
# Outputs:
#   Writes one line to stdout per problem.
# Returns:
#   0 if there are no problems, 1 otherwise.
#-------------------------------------------------------------------------------
check() {
  local problems=0 pair src target name listed

  for pair in "${LINKS[@]}"; do
    src="${DIR}/${pair%%:*}"
    target="${HOME}/${pair#*:}"

    if [ -L "$target" ]; then
      if [ "$(readlink "$target")" != "$src" ]; then
        echo "Wrong symlink: ${target} -> $(readlink "$target")"
        problems=1
      fi
    elif [ -e "$target" ]; then
      echo "Not a symlink: ${target}"
      problems=1
    else
      echo "Missing: ${target}"
      problems=1
    fi
  done

  # Files in `dist/` that aren't in `LINKS`.
  while IFS= read -r name; do
    name="${name##*/}"
    case "$name" in
      .DS_Store | terminfo) continue ;;
    esac
    listed=0
    for pair in "${LINKS[@]}"; do
      if [ "${pair%%:*}" = "$name" ]; then
        listed=1
        break
      fi
    done
    if [ "$listed" -eq 0 ]; then
      echo "Not linked by install.sh: ${DIR}/${name}"
      problems=1
    fi
  done < <(find "$DIR" -mindepth 1 -maxdepth 1)

  check_repo || problems=1

  return "$problems"
}

#-------------------------------------------------------------------------------
# Report repo state that would leave `$HOME` out of date.
# Globals:
#   REPO
# Outputs:
#   Writes one line to stdout per problem.
# Returns:
#   0 if there are no problems, 1 otherwise.
#-------------------------------------------------------------------------------
check_repo() {
  local problems=0 name behind

  # Uncommitted changes under `dist/`.
  while IFS= read -r name; do
    echo "Uncommitted: ${name}"
    problems=1
  done < <(git -C "$REPO" status --porcelain -- dist)

  # Behind upstream, as of the last fetch.
  behind="$(git -C "$REPO" rev-list --count 'HEAD..@{upstream}' 2>/dev/null)"
  if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
    echo "Behind upstream by ${behind} commit(s); run git pull in ${REPO}"
    problems=1
  fi

  return "$problems"
}

#===============================================================================
# MAIN
#===============================================================================
case "${1:-}" in
  --check)
    check
    exit
    ;;
  "")
    install_links
    run_tic
    ;;
  *)
    echo "Usage: $0 [--check]" >&2
    exit 2
    ;;
esac
