# Path: ~/.config/zsh/.zshrc
# ==============================================
# Zsh Interactive Configuration Entry Point
# ==============================================
#
# Loads interactive shell settings (XDG Base Directory compliant).
# Sources POSIX shell common configuration and Zsh-specific settings.

# Exit early if not running interactively
[[ -o interactive ]] || return 0

# POSIX Shell-specific interactive configuration
SHELL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell/shell.d"
for file in "$SHELL_DIR"/*.sh(N); do
  source "$file"
done

# Zsh-specific interactive configuration
ZSH_D_DIR="${ZDOTDIR}/zsh.d"
for file in "$ZSH_D_DIR"/*.zsh(N); do
  source "$file"
done
