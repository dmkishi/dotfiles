# Kishi's Dotfiles

## Shell startup-files loading order
https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/

### Zsh
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

### Bash
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