# Path: ~/.bash_profile
# ==============================================
# Bash Login Configuration Entry Point
# ==============================================

# Loads profile shell settings
BASH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
[[ -r "${BASH_DIR}/bash_profile" ]] && source "${BASH_DIR}/bash_profile"

# Load machine-local overrides if they exist
[[ -r "$HOME/.bash_profile.local" ]] && source "$HOME/.bash_profile.local"

# Load interactive shell settings
[[ -r "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
