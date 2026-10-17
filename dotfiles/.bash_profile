# Bash login entrypoint.

# Loads profile shell settings
_dotfiles_bash_dir="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
[[ -r "${_dotfiles_bash_dir}/bash_profile" ]] && source "${_dotfiles_bash_dir}/bash_profile"

# Load machine-local overrides if they exist
[[ -r "$HOME/.bash_profile.local" ]] && source "$HOME/.bash_profile.local"

# Load interactive shell settings
[[ -r "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
unset _dotfiles_bash_dir
