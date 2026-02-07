# Path: ~/.zshenv
# ==============================================
# Zsh Environment Configuration Entry Point
# ==============================================
#
# Sets up environment variables early in Zsh startup (before .zprofile).
# Handles OS-specific setup and XDG Base Directory compliance.

# Windows (MSYS/Git Bash/Cygwin) - normalize HOME path
case "$OSTYPE" in
  msys*|cygwin*)
    export HOME="$(cygpath -u "$USERPROFILE")"
  ;;
esac

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Zsh Configuration Directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Cache Directory for Zsh
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
  mkdir -p "$ZSH_CACHE_DIR"
fi
