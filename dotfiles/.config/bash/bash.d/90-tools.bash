# Load init scripts prepared by `mise run setup:shell`.

_dotfiles_init_dir="${XDG_CACHE_HOME:-$HOME/.cache}/bash/init"
_dotfiles_missing=""

for _dotfiles_init in fzf zoxide carapace starship; do
  _dotfiles_init_file="$_dotfiles_init_dir/$_dotfiles_init.bash"
  if [ -r "$_dotfiles_init_file" ]; then
    # shellcheck source=/dev/null
    source "$_dotfiles_init_file"
  else
    _dotfiles_missing="${_dotfiles_missing}${_dotfiles_missing:+, }$_dotfiles_init"
  fi
done

if [ -n "$_dotfiles_missing" ]; then
  printf 'shell setup missing (%s); run: mise run setup:shell\n' "$_dotfiles_missing" >&2
fi

unset _dotfiles_init_dir _dotfiles_init _dotfiles_init_file _dotfiles_missing
