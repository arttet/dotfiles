# Path: ~/.config/zsh/.zprofile
# ==============================================
# Zsh Login Configuration Entry Point
# ==============================================
#
# Loads login shell profile scripts (XDG Base Directory compliant).
# Executed at login to set up environment and path variables.

SHELL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell/profile.d"
for file in "$SHELL_DIR"/*.sh(N); do
  source "$file"
done
