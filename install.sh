#!/usr/bin/env bash
#
# Usage: install.sh [--check]
#
# Symlinks each file in `dist/` into `$HOME` and compiles the terminfo entries.
# Anything else already at a target is backed up to `<target>.bak.<timestamp>`.
# Safe to rerun from any directory. Exits 1 without changing anything if Zsh is
# missing or isn't the login shell. Stops at the first failed command, keeping
# any links already made.
#
#   --check  Report drift without changing anything. Prints nothing and exits 0
#            when clean; otherwise prints one line per problem and exits 1.

set -euo pipefail

#===============================================================================
# CONFIG
#===============================================================================
# Files to link, as `source:target` pairs: sources are in `dist/`; targets are
# in `$HOME`.
readonly LINKS=(
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
readonly REPO
readonly DIST="${REPO}/dist"

#===============================================================================
# HELPER FUNCTIONS
#===============================================================================
#-------------------------------------------------------------------------------
# Check whether a path is a symlink to the given source.
# Arguments:
#   Path to check.
#   Expected symlink source.
# Returns:
#   0 if the path is a symlink to the source, 1 otherwise.
#-------------------------------------------------------------------------------
is_linked() {
  [[ -L "$1" && "$(readlink "$1")" == "$2" ]]
}

#-------------------------------------------------------------------------------
# Check whether a path is the source of a `LINKS` pair.
# Globals:
#   LINKS
# Arguments:
#   Absolute path to check.
# Returns:
#   0 if the path is listed, 1 otherwise.
#-------------------------------------------------------------------------------
is_listed() {
  local pair

  for pair in "${LINKS[@]}"; do
    if [[ "$(link_src "$pair")" == "$1" ]]; then
      return 0
    fi
  done
  return 1
}

#-------------------------------------------------------------------------------
# Print the source path of a `LINKS` pair.
# Globals:
#   DIST
# Arguments:
#   A `source:target` pair.
# Outputs:
#   Writes the absolute source path to stdout.
#-------------------------------------------------------------------------------
link_src() {
  echo "${DIST}/${1%%:*}"
}

#-------------------------------------------------------------------------------
# Print the target path of a `LINKS` pair.
# Globals:
#   HOME
# Arguments:
#   A `source:target` pair.
# Outputs:
#   Writes the absolute target path to stdout.
#-------------------------------------------------------------------------------
link_target() {
  echo "${HOME}/${1#*:}"
}

#-------------------------------------------------------------------------------
# Arguments:
#   Message words, joined with spaces.
# Outputs:
#   Writes the message to stderr.
#-------------------------------------------------------------------------------
print_error() {
  echo "Error: $*" >&2
}

#-------------------------------------------------------------------------------
# Outputs:
#   Writes usage to stderr.
#-------------------------------------------------------------------------------
print_usage() {
  echo "Usage: $0 [--check]" >&2
}

#===============================================================================
# TASK FUNCTIONS
#===============================================================================
#-------------------------------------------------------------------------------
# Report targets that aren't the correct symlink.
# Globals:
#   LINKS
# Outputs:
#   Writes one line to stdout per problem.
# Returns:
#   0 if there are no problems, 1 otherwise.
#-------------------------------------------------------------------------------
check_links() {
  local problems=0 pair src target

  for pair in "${LINKS[@]}"; do
    src="$(link_src "$pair")"
    target="$(link_target "$pair")"

    if is_linked "$target" "$src"; then
      continue
    elif [[ -L "$target" ]]; then
      echo "Wrong symlink: ${target} -> $(readlink "$target")"
    elif [[ -e "$target" ]]; then
      echo "Not a symlink: ${target}"
    else
      echo "Missing: ${target}"
    fi
    problems=1
  done

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
  local problems=0 line behind

  # Uncommitted changes under `dist/`.
  while IFS= read -r line; do
    echo "Uncommitted: ${line}"
    problems=1
  done < <(git -C "$REPO" status --porcelain -- dist)

  # Behind upstream, as of the last fetch.
  behind="$(git -C "$REPO" rev-list --count 'HEAD..@{upstream}' 2>/dev/null)" \
    || behind=0
  if (( behind > 0 )); then
    echo "Behind upstream by ${behind} commit(s); run git pull in ${REPO}"
    problems=1
  fi

  return "$problems"
}

#-------------------------------------------------------------------------------
# Check that Zsh is installed and is the login shell. See README.md.
# Outputs:
#   Writes an error to stderr, if any.
# Returns:
#   0 if Zsh is the login shell, 1 otherwise.
#-------------------------------------------------------------------------------
check_shell() {
  local user login_shell
  user="$(id -un)"

  if ! command -v zsh >/dev/null; then
    print_error "Zsh is not installed. See README.md."
    return 1
  fi

  # Read from the user database, since `$SHELL` is stale until next login.
  case "$(uname)" in
    Darwin)
      login_shell="$(dscl . -read "/Users/${user}" UserShell \
        | awk '{print $2}')"
      ;;
    *) login_shell="$(getent passwd "$user" | cut -d: -f7)" ;;
  esac

  case "$login_shell" in
    */zsh) ;;
    *)
      print_error "Login shell is ${login_shell:-unknown}, not Zsh." \
        "Run: chsh -s \"\$(command -v zsh)\""
      return 1
      ;;
  esac
}

#-------------------------------------------------------------------------------
# Report files in `dist/` that aren't in `LINKS`.
# Globals:
#   DIST
# Outputs:
#   Writes one line to stdout per problem.
# Returns:
#   0 if there are no problems, 1 otherwise.
#-------------------------------------------------------------------------------
check_unlisted() {
  local problems=0 path

  while IFS= read -r path; do
    # `terminfo/` is compiled by install_terminfo, not linked.
    case "${path##*/}" in
      .DS_Store | terminfo) continue ;;
    esac
    if ! is_listed "$path"; then
      echo "Not linked by install.sh: ${path}"
      problems=1
    fi
  done < <(find "$DIST" -mindepth 1 -maxdepth 1)

  return "$problems"
}

#-------------------------------------------------------------------------------
# Add symlinks, backing up anything else already at each target.
# Globals:
#   LINKS
# Outputs:
#   Writes a line to stdout for each backup and link.
#-------------------------------------------------------------------------------
install_links() {
  local timestamp pair src target backup
  timestamp="$(date +%Y%m%d%H%M%S)"

  for pair in "${LINKS[@]}"; do
    src="$(link_src "$pair")"
    target="$(link_target "$pair")"

    if is_linked "$target" "$src"; then
      continue
    fi

    # Back up a file, directory, or wrong or broken symlink.
    if [[ -e "$target" || -L "$target" ]]; then
      backup="${target}.bak.${timestamp}"
      mv "$target" "$backup"
      echo "Backed up ${target} to ${backup}"
    fi

    ln -s "$src" "$target"
    echo "Linked ${target}"
  done
}

#-------------------------------------------------------------------------------
# Compile the terminfo entries in `dist/terminfo/` to enable italics in tmux and
# vim. See README.md.
# Globals:
#   DIST
#-------------------------------------------------------------------------------
install_terminfo() {
  tic -x "${DIST}/terminfo/tmux.terminfo"
  tic -x "${DIST}/terminfo/xterm-256color.terminfo"
}

#===============================================================================
# MAIN
#===============================================================================
main() {
  local problems=0

  case "${1:-}" in
    --check)
      check_links || problems=1
      check_unlisted || problems=1
      check_repo || problems=1
      exit "$problems"
      ;;
    "")
      check_shell || exit 1
      install_links
      install_terminfo
      ;;
    *)
      print_usage
      exit 2
      ;;
  esac
}

main "$@"
