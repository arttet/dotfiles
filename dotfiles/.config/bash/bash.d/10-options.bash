# ~/.config/bash/bash.d/10-options.sh
# ==============================================
# Bash Core Options & History
# ==============================================

# -------------------------------------------------------------------
# History Configuration
# -------------------------------------------------------------------
HISTDIR="${XDG_STATE_HOME:-$HOME/.local/state}/bash"
mkdir -p "$HISTDIR"

export HISTFILE="$HISTDIR/history"
export HISTSIZE=10000       # Memory buffer size
export HISTFILESIZE=20000   # Disk file size

# Format: YYYY-MM-DD HH:MM:SS
export HISTTIMEFORMAT='%F %T '
# ignoreboth: Ignore duplicates and commands starting with space
# erasedups: Remove all previous lines matching the current command
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history:date:* --help"

shopt -s histappend         # Append to history, don't overwrite
shopt -s cmdhist            # Save multi-line commands as one command
shopt -s histverify         # Verify history substitution before execution

# Real-time History Sync
# Appends to history file immediately after command execution
export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# -------------------------------------------------------------------
# Navigation
# -------------------------------------------------------------------
shopt -s autocd             # cd by typing directory name (e.g. 'Desktop' -> cd Desktop)
shopt -s cdspell            # autocorrect minor spelling errors in cd
shopt -s dirspell           # autocorrect directory names during completion

# -------------------------------------------------------------------
# Globbing (Pattern Matching)
# -------------------------------------------------------------------
shopt -s globstar           # enable ** for recursive glob (e.g. lib/**/*.js)
shopt -s nocaseglob         # case-insensitive globbing
shopt -s dotglob            # include hidden files in expansion
shopt -s extglob            # extended pattern matching (!(), *(), +(), etc.)
shopt -s nullglob           # patterns matching nothing expand to nothing (instead of literal string)

# -------------------------------------------------------------------
# Window & Aliases
# -------------------------------------------------------------------
shopt -s checkwinsize       # update LINES and COLUMNS after each command
shopt -s expand_aliases     # expand aliases in non-interactive shells

# -------------------------------------------------------------------
# Safety & Notifications
# -------------------------------------------------------------------
set -o notify               # notify of job completion immediately
set -o noclobber            # prevent file overwrite with > (use >| to override)
set -o vi                   # use vi-style line editing