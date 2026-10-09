#!/usr/bin/env zsh

setopt NO_UNSET

repo_root=${1:-$PWD}
test_root="$repo_root/.tools/tests/zsh-contracts"

fail() {
  print -u2 -- "FAIL: $1"
  exit 1
}

export HOME="$test_root/home"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$repo_root/dotfiles/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export PATH="/usr/bin:/bin"

source "$repo_root/dotfiles/.config/shell/shell.d/30-aliases.sh"
alias ls | grep -q "eza" || fail "ls does not use eza"
alias cat >/dev/null 2>&1 && fail "cat shadows the system command"
alias grep >/dev/null 2>&1 && fail "grep shadows the system command"
alias ps >/dev/null 2>&1 && fail "ps shadows the system command"
alias top >/dev/null 2>&1 && fail "top shadows the system command"
alias df >/dev/null 2>&1 && fail "df shadows the system command"
alias du >/dev/null 2>&1 && fail "du shadows the system command"
alias man >/dev/null 2>&1 && fail "man shadows the system command"

unset XDG_CACHE_HOME
ZSH_CACHE_DIR=""
source "$repo_root/dotfiles/.config/zsh/zsh.d/50-completion.zsh"
[[ $ZSH_CACHE_DIR == "$HOME/.cache/zsh" ]] || fail "Zsh completion has no XDG cache fallback"

print -- 'zsh shell contracts passed'
