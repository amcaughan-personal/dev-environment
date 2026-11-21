# shellcheck shell=bash
# Personal shell setup, sourced from ~/.bashrc (see install.sh). The same on the host and
# in every dev container; anything specific to one machine stays in that machine's ~/.bashrc.

# mise: tool versions per directory, from each repo's .tool-versions.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
elif [ -x "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME/.local/bin/mise" activate bash)"
fi

# Prompt: user@host:dir (branch)$, in colour. In a dev container, host is the container's name.
parse_git_branch() {
  local branch
  branch="$(git branch --show-current 2>/dev/null)"
  [ -n "$branch" ] && printf ' (%s)' "$branch"
}
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;33m\]$(parse_git_branch)\[\033[00m\]\$ '

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'

alias tf='terraform'
alias tg='terragrunt'

# dc [repo-dir]: a shell in a repo's dev container, started if needed (or the one VS Code is
# running). Only where the devcontainer CLI is installed, i.e. on the host.
if command -v devcontainer >/dev/null 2>&1; then
  dc() {
    local dir="${1:-.}"
    devcontainer up --workspace-folder "$dir" \
      --dotfiles-repository https://github.com/amcaughan-personal/dev-environment >/dev/null &&
      devcontainer exec --workspace-folder "$dir" --remote-env "TERM=$TERM" bash
  }
fi
