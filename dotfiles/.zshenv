# Early environment shared by login and interactive Zsh sessions.

case "$OSTYPE" in
msys* | cygwin*)
  case "$HOME" in
  [A-Za-z]:\\*) export HOME="$(cygpath -u "$HOME")" ;;
  esac
  ;;
esac

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
