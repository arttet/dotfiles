# ~/.config/zsh/zsh.d/10-options.zsh
# ==============================================
# Zsh Core Options & History
# ==============================================

# -------------------------------------------------------------------
# History Configuration
# -------------------------------------------------------------------
HISTDIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
mkdir -p "$HISTDIR"

export HISTFILE="$HISTDIR/history"
export HISTSIZE=10000       # Memory buffer size
export SAVEHIST=20000       # Disk file size

# Advanced History Control
setopt APPEND_HISTORY       # Append to history file
setopt EXTENDED_HISTORY     # Save time and duration of commands
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when history is full
setopt HIST_IGNORE_DUPS     # Ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate lines
setopt HIST_FIND_NO_DUPS    # Don't show dupes in history search
setopt HIST_IGNORE_SPACE    # Don't save commands starting with space
setopt HIST_VERIFY          # Show command before executing on substitution
setopt SHARE_HISTORY        # Share history between sessions immediately

alias history='fc -li 1'

# -------------------------------------------------------------------
# Navigation
# -------------------------------------------------------------------
setopt AUTO_CD              # Change dir by typing name only (e.g. 'Desktop' -> cd Desktop)
setopt AUTO_PUSHD           # Push current dir to stack on cd
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates to stack
setopt PUSHD_SILENT         # Don't print stack after cd

# -------------------------------------------------------------------
# Job Control
# -------------------------------------------------------------------
setopt LONG_LIST_JOBS       # List jobs in long format
setopt NOTIFY               # Report status of bg jobs immediately
setopt NO_BEEP              # Silence system beep!

# -------------------------------------------------------------------
# Matching
# -------------------------------------------------------------------
setopt GLOB_DOTS            # Match hidden files without explicit dot
setopt EXTENDED_GLOB        # Power features (like ^, ~, #)
setopt NO_CASE_GLOB         # Case insensitive globbing
