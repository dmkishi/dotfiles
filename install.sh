#!/usr/bin/env bash

# Absolute path to the `dist/` directory, relative to this script.
DIR="$(cd "$(dirname "$0")" && pwd)/dist"

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

# Add symlinks, backing up anything already in the way.
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

# Enable italics in tmux and vim. See README.md.
run_tic() {
  tic -x "${DIR}/terminfo/tmux.terminfo"
  tic -x "${DIR}/terminfo/xterm-256color.terminfo"
}

install_links
run_tic
