#!/usr/bin/env bash

DIR="$(realpath dist)"
ln -sf "${DIR}/_editorconfig" ~/.editorconfig
ln -sf "${DIR}/_hushlogin" ~/.hushlogin
ln -sf "${DIR}/_tmux".conf ~/.tmux.conf
ln -sf "${DIR}/_vimrc" ~/.vimrc
ln -sf "${DIR}/_zshenv" ~/.zshenv
ln -sf "${DIR}/_zshrc" ~/.zshrc
