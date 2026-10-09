# Zsh login environment.

_dotfiles_shell_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell/profile.d"
for _dotfiles_file in "$_dotfiles_shell_dir"/*.sh(N); do
  source "$_dotfiles_file"
done
unset _dotfiles_shell_dir _dotfiles_file
