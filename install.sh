#!/usr/bin/env bash

# Absolute path to the `dist/` directory.
DIR="$(realpath dist)"

# Add symlinks.
ln -sf "${DIR}/_hushlogin" ~/.hushlogin
ln -sf "${DIR}/_tmux.conf" ~/.tmux.conf
ln -sf "${DIR}/_vimrc" ~/.vimrc
ln -sf "${DIR}/_zlogin" ~/.zlogin
ln -sf "${DIR}/_zshenv" ~/.zshenv
ln -sf "${DIR}/_zshrc" ~/.zshrc

# Enable italics in tmux and vim. See README.md.
tic -x "${DIR}/terminfo/tmux.terminfo"
tic -x "${DIR}/terminfo/xterm-256color.terminfo"
