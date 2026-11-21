#!/usr/bin/env bash
# Installs the dotfiles for the current user; safe to run again.
#   - ~/.bashrc sources dotfiles/bashrc.sh
#   - ~/.vimrc links to dotfiles/vimrc (an existing file is kept as ~/.vimrc.before-dotfiles)
# VS Code and the devcontainer CLI run this in every dev container (their dotfiles
# setting); on a new machine, clone this repo and run it once.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

line=". \"$here/dotfiles/bashrc.sh\""

if ! grep -qxF "$line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# Personal shell setup (github.com/amcaughan-personal/dev-environment)\n%s\n' "$line" >> "$HOME/.bashrc"
fi

if [[ -e "$HOME/.vimrc" && ! -L "$HOME/.vimrc" ]]; then
  mv "$HOME/.vimrc" "$HOME/.vimrc.before-dotfiles"
fi
ln -sfn "$here/dotfiles/vimrc" "$HOME/.vimrc"

echo "dotfiles from $here installed"
