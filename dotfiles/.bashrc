# Bash interactive entrypoint.

# Exit early if not running interactively
[[ $- != *i* ]] && return

# Loads interactive shell settings
_dotfiles_bash_dir="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
[[ -r "${_dotfiles_bash_dir}/bashrc" ]] && source "${_dotfiles_bash_dir}/bashrc"

# Load machine-local overrides if they exist
[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
unset _dotfiles_bash_dir
