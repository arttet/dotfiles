# Path: ~/.bashrc
# ==============================================
# Bash Interactive Configuration Entry Point
# ==============================================

# Exit early if not running interactively
[[ $- != *i* ]] && return

# Loads interactive shell settings
BASH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
[[ -r "${BASH_DIR}/bashrc" ]] && source "${BASH_DIR}/bashrc"

# Load machine-local overrides if they exist
[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
