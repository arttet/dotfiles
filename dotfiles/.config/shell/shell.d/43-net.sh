# Small network helpers. Calls happen only when a helper is invoked.

cht() {
  [ "$#" -gt 0 ] || {
    printf 'usage: cht topic [query]\n' >&2
    return 2
  }
  _dotfiles_query=$(printf '%s' "$*" | tr ' ' '+')
  curl -fsSL "https://cht.sh/$_dotfiles_query" | bat --style=plain --paging=never
  unset _dotfiles_query
}

weather() {
  [ "$#" -eq 1 ] || {
    printf 'usage: weather city\n' >&2
    return 2
  }
  case "$1" in
  *[!A-Za-z\ -]*)
    printf 'weather: city may contain only letters, spaces and hyphens\n' >&2
    return 2
    ;;
  esac
  _dotfiles_city=$(printf '%s' "$1" | tr ' ' '+')
  curl -fsSL "https://wttr.in/$_dotfiles_city"
  unset _dotfiles_city
}
