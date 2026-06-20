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
# Priority: helix > neovim > vim > vi
# Used by git, visudo, and other CLI tools

if command -v hx >/dev/null 2>&1; then
  export EDITOR=hx
  export VISUAL=hx
elif command -v nvim >/dev/null 2>&1; then
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
    # Catppuccin Mocha
    "--color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa"
    "--color=fg+:#cdd6f4,bg+:#313244,hl+:#89dceb"
    "--color=info:#cba6f7,prompt:#89b4fa,pointer:#f5c2e7"
    "--color=marker:#a6e3a1,spinner:#cba6f7,header:#6c7086"
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

# Claude Code
export CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/claude}"

# Codex CLI
export CODEX_HOME="${CODEX_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/codex}"

# Kimi Code
export KIMI_CODE_HOME="${KIMI_CODE_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/kimi-code}"

# Yazi CLI
if command -v yazi >/dev/null 2>&1; then
  # Set configuration directory to follow XDG standards
  export YAZI_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"
fi

# Ripgrep
if command -v rg >/dev/null 2>&1; then
  RIPGREP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/config"
  [ -f "$RIPGREP_CONFIG" ] && export RIPGREP_CONFIG_PATH="$RIPGREP_CONFIG"
fi

# Bat
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
  export BAT_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/bat/config"
fi

# GitHub CLI
if command -v gh >/dev/null 2>&1; then
  export GH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gh"
fi
