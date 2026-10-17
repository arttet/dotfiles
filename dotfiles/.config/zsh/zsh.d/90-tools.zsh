# Load init scripts prepared by `mise run setup:shell`.

typeset _dotfiles_init_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"
typeset _dotfiles_missing=""
typeset _dotfiles_init _dotfiles_init_file

for _dotfiles_init in fzf zoxide carapace starship; do
  _dotfiles_init_file="$_dotfiles_init_dir/$_dotfiles_init.zsh"
  if [[ -r "$_dotfiles_init_file" ]]; then
    source "$_dotfiles_init_file"
  else
    _dotfiles_missing="${_dotfiles_missing}${_dotfiles_missing:+, }$_dotfiles_init"
  fi
done

if [[ -n "$_dotfiles_missing" ]]; then
  print -u2 -- "shell setup missing ($_dotfiles_missing); run: mise run setup:shell"
fi

unset _dotfiles_init_dir _dotfiles_init _dotfiles_init_file _dotfiles_missing
