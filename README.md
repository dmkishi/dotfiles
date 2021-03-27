# Kishi's Dotfiles

Simultaneous Zsh-Bash support has been discontinued in favor of a Zsh-only
configuration. This vastly simplifies maintenance especially as there is no
reason to continue support for Bash on macOS. Bash support on Debian-based
Raspberry Pi and Ubuntu environments will be maintained separately.




## Install
Filenames in `src/` has dot-prefixes replaced with underscores. This allows (a)
the files to be conventionally visible and (b) explicitly documents the missing
dot-prefix (there may be configuration files without dot-prefixes.)

```sh
ln -s ~/dotfiles/src/zshrc ~/_zshrc
ln -sf ~/dotfiles/src/zshrc ~/_zshrc  # Overwrite pre-existing symlink file
```




## Shell Startup Files Loading Order
https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/

**Zsh**
|                     | Interactive Login  | Interactive non-login  | Script  |
|---------------------|:------------------:|:----------------------:|:-------:|
| `/etc/zshenv`       | A                  | A                      | A       |
| `~/.zshenv`         | B                  | B                      | B       |
| `/etc/zprofile`     | C                  |                        |         |
| `~/.zprofile`       | D                  |                        |         |
| `/etc/zshrc`        | E                  | C                      |         |
| `~/.zshrc`          | F                  | D                      |         |
| `/etc/zlogin`       | G                  |                        |         |
| `~/.zlogin`         | H                  |                        |         |
| `~/.zlogout`        | I                  |                        |         |
| `/etc/zlogout`      | J                  |                        |         |

**Bash**
|                     | Interactive Login  | Interactive non-login  | Script  |
|---------------------|:------------------:|:----------------------:|:-------:|
| `/etc/profile`      | A                  |                        |         |
| `/etc/bash.bashrc`  |                    | A                      |         |
| `~/.bashrc`         |                    | B                      |         |
| `~/.bash_profile`   | B1*                |                        |         |
| `~/.bash_login`     | B2*                |                        |         |
| `~/.profile`        | B3*                |                        |         |
| `BASH_ENV`          |                    |                        | A       |
| `~/.bash_logout`    | C                  |                        |         |

*As soon as one is found, it skips to "C"
