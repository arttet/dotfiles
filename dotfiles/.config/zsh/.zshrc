# Zsh interactive configuration.

# Exit early if not running interactively
[[ -o interactive ]] || return 0

_dotfiles_shell_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell/shell.d"
for _dotfiles_file in "$_dotfiles_shell_dir"/*.sh(N); do
  source "$_dotfiles_file"
done

_dotfiles_zsh_dir="${ZDOTDIR}/zsh.d"
for _dotfiles_file in "$_dotfiles_zsh_dir"/*.zsh(N); do
  source "$_dotfiles_file"
done
unset _dotfiles_shell_dir _dotfiles_zsh_dir _dotfiles_file
