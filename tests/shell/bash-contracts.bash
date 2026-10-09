#!/usr/bin/env bash

set -u

repo_root=${1:-$PWD}
test_root="$repo_root/.tools/tests/bash-contracts"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

export HOME="$test_root/home"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$repo_root/dotfiles/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export PATH="/usr/bin:/bin"
PROMPT_COMMAND=""

source "$repo_root/dotfiles/.config/bash/bash.d/10-options.bash"
source "$repo_root/dotfiles/.config/bash/bash.d/10-options.bash"

history_hooks=${PROMPT_COMMAND//[^;]/}
[[ $PROMPT_COMMAND == *"_dotfiles_history_sync"* ]] || fail "Bash history sync is not installed"
[[ ${#history_hooks} -lt 3 ]] || fail "Bash history sync is duplicated after reload"

source "$repo_root/dotfiles/.config/shell/shell.d/30-aliases.sh"
alias ls | grep -q "eza" || fail "ls does not use eza"
alias cat >/dev/null 2>&1 && fail "cat shadows the system command"
alias grep >/dev/null 2>&1 && fail "grep shadows the system command"
alias ps >/dev/null 2>&1 && fail "ps shadows the system command"
alias top >/dev/null 2>&1 && fail "top shadows the system command"
alias df >/dev/null 2>&1 && fail "df shadows the system command"
alias du >/dev/null 2>&1 && fail "du shadows the system command"
alias man >/dev/null 2>&1 && fail "man shadows the system command"

source "$repo_root/dotfiles/.config/shell/shell.d/43-net.sh"
declare -F download >/dev/null && fail "unsafe download helper is still exported"

source "$repo_root/dotfiles/.config/shell/shell.d/44-system.sh"
ps() { printf '42 worker\n'; }
fzf() { command cat; }
kill() { _test_kill_args="$*"; }
fkill || fail "fkill rejected a selected process"
[[ $_test_kill_args == '-s TERM 42' ]] || fail "fkill does not default to SIGTERM"
fkill --kill || fail "fkill --kill rejected a selected process"
[[ $_test_kill_args == '-s KILL 42' ]] || fail "fkill --kill does not request SIGKILL"

_test_git_called=false
git() { _test_git_called=true; }
source "$repo_root/dotfiles/.config/shell/shell.d/45-git.sh"
gundo >/dev/null 2>&1 && fail "gundo changed history without confirmation"
[[ $_test_git_called == false ]] || fail "gundo invoked git after cancellation"

printf 'bash shell contracts passed\n'
