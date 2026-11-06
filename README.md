Kishi's Dotfiles
================================================================================
**Install and manage config files** for Zsh, tmux, Vim, etc. across multiple machines.

Note: **Zsh only**. Bash support has been discontinued after macOS switched its default shell to Zsh. On Unix-like devices, [install Zsh](#zsh-on-debianubuntu) and make it the default shell.

Features
--------------------------------------------------------------------------------
- Run from anywhere. Safe to rerun.
- Installation:
  - Exits without changes if Zsh is missing or is not the login shell.
  - Dotfiles are symlinked into `~`.
    - Files in the way are backed up to `<filename>.bak.<timestamp>`.
  - Terminfo entries are compiled for [italics](#enabling-italics-in-vim-and-tmux).
- [Drift check](#check-for-drift):
  - Reports without changing anything:
    - Missing or wrong symlinks.
    - Files in `dist/` that `install.sh` doesn't link.
    - Uncommitted changes in `dist/`.
    - Commits behind upstream, as of the last fetch.
  - Runs on login.

Install
--------------------------------------------------------------------------------
```sh
cd ~  # Or wherever
git clone https://github.com/dmkishi/dotfiles.git
./dotfiles/install.sh
```

### Zsh on Debian/Ubuntu
1. Install Zsh:  `sudo apt install zsh`
1. Make it default: `chsh -s "$(command -v zsh)"`
1. Log out and back in.
1. Check that it worked: `echo $SHELL`

Usage
--------------------------------------------------------------------------------
### Check for Drift
```sh
./dotfiles/install.sh --check
```

Prints nothing and exits 0 when clean; otherwise prints one line per problem and exits 1.

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

[^1]: <https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/>

### Enabling Italics in Vim and tmux
- <https://sookocheff.com/post/vim/italics>
- <https://rsapkf.xyz/blog/enabling-italics-vim-tmux>

Unfortunately, this is a compound effort involving multiple configuration files:

- Terminfo: Italics are enabled by updating the terminfo database, which allows terminal emulators to recognize escape codes for italics. Terminfo files must be created for tmux, tmux w/ 256 color support, and xterm with 256 color support, which must be compiled with the `tic` command. The compiled files are written to `~/.terminfo`.
- `.tmux.conf`: Direct tmux to use the new Terminfo.
- `.vimrc`: Italicize comments.

Related Projects
--------------------------------------------------------------------------------
- [chezmoi](https://www.chezmoi.io) is an advanced and well maintained dotfile manager.

Changelog
--------------------------------------------------------------------------------
### v0.8.1 (2026-11-06)
- Fixes:
  - Dotfiles: switch to pnpm global bin directory (`$PNPM_HOME/bin`) in `PATH`.

### v0.8.0 (2026-10-12)
- Features:
  - Dotfiles:
    - Add Tailscale SSH message.
    - Add pnpm to `PATH`.
    - Add alias `youtube-dl` → `yt-dlp`.
    - Restore Python pyenv initializer.
      - Guard initializer when not installed.
    - Disable nvm bash completion.
  - Install:
    - Make safe to rerun from any directory, backing up files in the way.
    - Add drift check. Run on login.
    - Fail at first failed command.
    - Fail if Zsh is missing or is not the login shell.
- Chores:
  - Improve README and add changelog.
