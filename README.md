Kishi's Dotfiles
================================================================================
This is Zsh-only (at least regarding the shell.) Bash support has been discontinued after macOS 10.15 in 2019 switched its default shell to Zsh from Bash. On Unix-like devices, install Zsh and change it to the default shell.


Install
--------------------------------------------------------------------------------
```sh
cd ~  # Or wherever
git clone https://github.com/dmkishi/dotfiles.git
./dotfiles/install.sh
```


Technical Notes
--------------------------------------------------------------------------------
### Startup Files and Loading Order[^1]
Only `.zshenv` and `.zshrc` are used. See respective files for notes and descriptions.

|                  | Interactive Login  | Interactive non-login  | Script  |
|------------------|:------------------:|:----------------------:|:-------:|
| `/etc/zshenv`    | A                  | A                      | A       |
| `~/.zshenv`      | B                  | B                      | B       |
| `/etc/zprofile`  | C                  |                        |         |
| `~/.zprofile`    | D                  |                        |         |
| `/etc/zshrc`     | E                  | C                      |         |
| `~/.zshrc`       | F                  | D                      |         |
| `/etc/zlogin`    | G                  |                        |         |
| `~/.zlogin`      | H                  |                        |         |
| `~/.zlogout`     | I                  |                        |         |
| `/etc/zlogout`   | J                  |                        |         |

[^1]: https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/


### Enabling Italics in Vim and tmux
- https://sookocheff.com/post/vim/italics
- https://rsapkf.xyz/blog/enabling-italics-vim-tmux

Unfortunately, this is a compound effort involving multiple configuration files:

- Terminfo: Italics are enabled by updating the terminfo database, which allows terminal emulators to recognize escape codes for italics. Terminfo files must be created for tmux, tmux w/ 256 color support, and xterm with 256 color support, which must be compiled with the `tic` command. The compiled files are written to `~/.terminfo`.
- `.tmux.conf`: Direct tmux to use the new Terminfo.
- `.vimrc`: Italicize comments.
