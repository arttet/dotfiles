# ~/.config/bash/bash.d/50-completion.sh
# ==============================================
# Bash Completion Configuration
# ==============================================

# Completion Cache Directory
BASH_COMPLETION_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bash/completion"
[[ -d "$BASH_COMPLETION_CACHE" ]] || mkdir -p "$BASH_COMPLETION_CACHE"

# -------------------------------------------------------------------
# Readline Settings (Interactive)
# -------------------------------------------------------------------
if [[ $- == *i* ]]; then
    bind "set completion-ignore-case on"         # Case-insensitive completion
    bind "set show-all-if-ambiguous on"          # Show options immediately (don't wait for 2nd Tab)
    bind "set colored-stats on"                  # Color the common prefix
    bind "set visible-stats on"                  # Show extra file info (like ls -F)
    bind "set mark-symlinked-directories on"     # Add slash to symlinked directories
    bind "set colored-completion-prefix on"      # Highlight the part you typed
    bind "set menu-complete-display-prefix on"   # Better menu display
fi

# -------------------------------------------------------------------
# Load System Completion
# -------------------------------------------------------------------
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
fi