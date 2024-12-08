#!/usr/bin/env bash

SRC="$(realpath src)"
ln -sf "${SRC}/_editorconfig" ~/.editorconfig
ln -sf "${SRC}/_hushlogin" ~/.hushlogin
ln -sf "${SRC}/_tmux".conf ~/.tmux.conf
ln -sf "${SRC}/_vimrc" ~/.vimrc
ln -sf "${SRC}/_zshenv" ~/.zshenv
ln -sf "${SRC}/_zshrc" ~/.zshrc
