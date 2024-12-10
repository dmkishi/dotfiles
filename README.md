Kishi's Dotfiles
================================================================================

Install
--------------------------------------------------------------------------------
Filenames in `src/` has dot-prefixes replaced with underscores. This allows (a) the files to be conventionally visible and (b) explicitly documents the missing dot-prefix (there may be configuration files without dot-prefixes.)

```sh
ln -s ~/dotfiles/src/zshrc ~/_zshrc
ln -sf ~/dotfiles/src/zshrc ~/_zshrc  # Overwrite pre-existing symlink file
```


Startup Files and Loading Order[^1]
--------------------------------------------------------------------------------
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


Italics in Vim and tmux
--------------------------------------------------------------------------------
- https://sookocheff.com/post/vim/italics
- https://rsapkf.xyz/blog/enabling-italics-vim-tmux

Unfortunately, this is a compound effort involving multiple configuration files:

- Terminfo: Italics are enabled by updating the terminfo database, which allows terminal emulators to recognize escape codes for italics. Terminfo files must be created for tmux, tmux w/ 256 color support, and xterm with 256 color support, which must be compiled with the `tic` command. The compiled files are written to `~/.terminfo`.
- `.tmux.conf`: Direct tmux to use the new Terminfo.
- `.vimrc`: Italicize comments.


On Bash Files
--------------------------------------------------------------------------------
Simultaneous Zsh–Bash support has been discontinued in favor of a Zsh-only configuration. This vastly reduces maintenance especially as there is no reason to continue support for Bash on macOS (or elsewhere as Zsh can be installed instead.)
