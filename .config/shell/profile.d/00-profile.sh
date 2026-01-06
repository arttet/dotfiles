# ~/.config/shell/profile.d/00-profile.sh
# =============================================================================
# Shell Environment Configuration
# =============================================================================

# =============================================================================
# Locale Configuration
# =============================================================================
# Enforce UTF-8 locale to ensure consistent character handling
# Critical for emojis, special characters, and international text

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# =============================================================================
# User PATH Configuration
# =============================================================================
# User binary directory (XDG-like standard for user-installed binaries)
# Security: Only add if directory is owned by user

# This directory is standard for user-installed binaries (XDG-like)
LOCAL_BIN="$HOME/.local/bin"

# Create directory if it doesn't exist
[ -d "$LOCAL_BIN" ] || mkdir -p "$LOCAL_BIN"

# Security: Only add if owned by user and not world-writable
# This prevents privilege escalation if another user creates a malicious binary in a shared directory.
if [ -d "$LOCAL_BIN" ] && [ -O "$LOCAL_BIN" ]; then
    # Prepend to PATH if not already present
    case ":$PATH:" in
        *":$LOCAL_BIN:"*) ;;
        *) PATH="$LOCAL_BIN:$PATH" ;;
    esac
fi

export PATH

# =============================================================================
# Editor Configuration
# =============================================================================
# Priority: nvim > vim > vi
# Used by git, visudo, and other CLI tools

if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
    export VISUAL=vim
else
    export EDITOR=vi
    export VISUAL=vi
fi

# =============================================================================
# Pager Configuration
# =============================================================================
# Default pager for man pages, git log, etc.

# -R: Repaint screen (handle colors correctly)
# -M: Verbose prompt (show percentage, line numbers)
# -i: Ignore case in searches
# -j.5: Center search results
# --shift 5: Horizontal scroll step
export LESS="-R -M -i -j.5 --shift 5"

# =============================================================================
# Tool-Specific Configuration
# =============================================================================

# Starship Prompt
# Set custom configuration file location if fzf is available
if command -v fzf >/dev/null 2>&1; then
    export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
fi

# FZF (A command-line fuzzy finder)
if command -v fzf >/dev/null 2>&1; then
    FZF_DEFAULT_OPTS_ARRAY=(
        "--height=60%"
        "--layout=reverse"
        "--border"
        "--cycle"
        "--inline-info"
        # Dracula/Nord hybrid theme
        "--color=fg:#d0d0d0,bg:#121212,hl:#5f87af"
        "--color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff"
        "--color=info:#afaf87,prompt:#d7005f,pointer:#af5fff"
        "--color=marker:#87ff00,spinner:#af5fff,header:#87afaf"
        # Key-bindings
        "--bind=ctrl-/:toggle-preview"
        "--bind=ctrl-u:preview-half-page-up"
        "--bind=ctrl-d:preview-half-page-down"
    )
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS_ARRAY[*]}"

    ###
    # Ctrl+T: Interactive File Edit using fzf
    ###
    if command -v fd >/dev/null 2>&1; then
        export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow --exclude .git"
    else
        export FZF_CTRL_T_COMMAND="find . -type f 2>/dev/null"
    fi

    FZF_CTRL_T_OPTS_ARRAY=()

    if command -v bat >/dev/null 2>&1; then
        FZF_CTRL_T_OPTS_ARRAY+=(
            "--preview='bat --color=always --style=numbers --line-range=:500 {}'"
        )
    else
        FZF_CTRL_T_OPTS_ARRAY+=(
            "--preview='cat {}'"
        )
    fi

    FZF_CTRL_T_OPTS_ARRAY+=(
        "--preview-window=right:50%:wrap"
        "--header='✏️  EDIT FILE | Enter: open'"
        "--color=header:italic"
    )

    export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS_ARRAY[*]}"

    ###
    # Ctrl+R: Interactive History Search using fzf
    ###

    FZF_CTRL_R_OPTS_ARRAY=(
        "--exact"
        "--header='📜 COMMAND HISTORY | Enter: insert'"
        "--color=header:italic"
    )
    export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS_ARRAY[*]}"

    ###
    # Ctrl+C: Interactive History Search using fzf
    ###
    if command -v fd >/dev/null 2>&1; then
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    else
        export FZF_ALT_C_COMMAND="find . -type d 2>/dev/null"
    fi

    FZF_ALT_C_OPTS_ARRAY=()
    if command -v eza >/dev/null 2>&1; then
        FZF_ALT_C_OPTS_ARRAY+=(
            "--preview='eza --tree --level=2 --icons --color=always {}'"
        )
    elif command -v tree >/dev/null 2>&1; then
        FZF_ALT_C_OPTS_ARRAY+=(
            "--preview='tree -C {}'"
        )
    else
        FZF_ALT_C_OPTS_ARRAY+=(
            "--preview='ls -R {}'"
        )
    fi

    FZF_ALT_C_OPTS_ARRAY+=(
        "--header='🚀 JUMP TO DIR | Enter: cd'"
        "--color=header:italic"
    )
    export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS_ARRAY[*]}"
fi

# WakaTime CLI
# https://github.com/wakatime/wakatime-cli/
# https://wakatime.com/dashboard/
export WAKATIME_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/wakatime"

# Yazi CLI
if command -v yazi >/dev/null 2>&1; then
    # Set configuration directory to follow XDG standards
    export YAZI_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"
fi
