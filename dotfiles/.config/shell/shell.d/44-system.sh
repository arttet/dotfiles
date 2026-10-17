# Interactive process and cache maintenance helpers.

_dotfiles_confirm() {
  [ "${1:-}" = --yes ] && return 0
  [ -t 0 ] || return 1
  printf '%s [y/N] ' "$2" >&2
  IFS= read -r _dotfiles_answer
  case "$_dotfiles_answer" in
  y | Y | yes | YES)
    unset _dotfiles_answer
    return 0
    ;;
  *)
    unset _dotfiles_answer
    return 1
    ;;
  esac
}

fkill() {
  _dotfiles_signal=TERM
  [ "${1:-}" = --kill ] && _dotfiles_signal=KILL
  case "${OSTYPE:-}" in
  # MSYS and Cygwin ps has no -o; its first column is the PID and the last one the command.
  msys* | cygwin*) _dotfiles_processes=$(ps | awk 'NR > 1 { print $1, $NF }') ;;
  *) _dotfiles_processes=$(ps -eo pid=,comm=) ;;
  esac
  _dotfiles_pid=$(printf '%s\n' "$_dotfiles_processes" | fzf --no-preview --header 'Select process' | awk '{print $1}')
  unset _dotfiles_processes
  case "$_dotfiles_pid" in
  '' | *[!0-9]*)
    unset _dotfiles_pid _dotfiles_signal
    return 1
    ;;
  esac
  if kill -s "$_dotfiles_signal" "$_dotfiles_pid"; then
    unset _dotfiles_pid _dotfiles_signal
    return 0
  fi
  unset _dotfiles_pid _dotfiles_signal
  return 1
}

cleanup() {
  _dotfiles_yes=""
  _dotfiles_volumes=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
    --yes) _dotfiles_yes=--yes ;;
    --docker-volumes) _dotfiles_volumes=--volumes ;;
    *)
      printf 'usage: cleanup [--yes] [--docker-volumes]\n' >&2
      return 2
      ;;
    esac
    shift
  done

  _dotfiles_confirm "$_dotfiles_yes" 'Clean package and build caches?' || {
    printf 'cleanup cancelled\n' >&2
    return 1
  }

  if command -v apt >/dev/null 2>&1; then
    sudo apt autoremove -y && sudo apt clean
  elif command -v brew >/dev/null 2>&1; then
    brew cleanup
  fi
  command -v cargo-cache >/dev/null 2>&1 && cargo cache -a
  command -v go >/dev/null 2>&1 && go clean -cache -testcache -fuzzcache
  if command -v docker >/dev/null 2>&1; then
    docker system prune -af ${_dotfiles_volumes:+--volumes}
  fi
  unset _dotfiles_yes _dotfiles_volumes
}
