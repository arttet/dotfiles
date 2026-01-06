# ~/.config/nushell/env.nu
# =============================================================================
# Nushell Environment Configuration
# =============================================================================

# =============================================================================
# XDG Base Directory Standards
# =============================================================================
# Enforce XDG standards for clean home directory
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

$env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($nu.home-path | path join ".config"))
$env.XDG_CACHE_HOME  = ($env.XDG_CACHE_HOME?  | default ($nu.home-path | path join ".cache"))
$env.XDG_DATA_HOME   = ($env.XDG_DATA_HOME?   | default ($nu.home-path | path join ".local" "share"))
$env.XDG_STATE_HOME  = ($env.XDG_STATE_HOME?  | default ($nu.home-path | path join ".local" "state"))

# Create directories if they don't exist
for dir in [$env.XDG_CONFIG_HOME $env.XDG_CACHE_HOME $env.XDG_DATA_HOME $env.XDG_STATE_HOME] {
    if not ($dir | path exists) {
        mkdir $dir
    }
}

# =============================================================================
# Locale Configuration
# =============================================================================
# Enforce UTF-8 locale to ensure consistent character handling
# Critical for emojis, special characters, and international text

$env.LC_ALL = "en_US.UTF-8"
$env.LANG = "en_US.UTF-8"
$env.LANGUAGE = "en_US.UTF-8"

# =============================================================================
# User PATH Configuration
# =============================================================================
# User binary directory (XDG-like standard for user-installed binaries)
# Security: Only add if directory is owned by user

# This directory is standard for user-installed binaries (XDG-like)
let local_bin = ($nu.home-path | path join ".local" "bin")

# Create directory if it doesn't exist
if not ($local_bin | path exists) {
    mkdir $local_bin
}

# Add to PATH only if:
# 1. Directory exists
# 2. Not already in PATH (prevent duplicates)
if ($local_bin | path exists) {
    # Get current PATH, handling both string and list formats
    let current_path = (
        if ($env.PATH? | describe) == "string" {
            $env.PATH | split row (char esep)
        } else if ($env.PATH? | describe) =~ "list" {
            $env.PATH
        } else {
            []
        }
    )

    # Check if local_bin is already in PATH
    let already_in_path = ($current_path | any {|p| $p == $local_bin})

    # Prepend if not already present
    if not $already_in_path {
        $env.PATH = ($current_path | prepend $local_bin)
    }
}

# Optional: Add Cargo binary directory
let cargo_bin = ($nu.home-path | path join ".cargo" "bin")
if ($cargo_bin | path exists) {
    let current_path = (
        if ($env.PATH | describe) == "string" {
            $env.PATH | split row (char esep)
        } else {
            $env.PATH
        }
    )

    let already_in_path = ($current_path | any {|p| $p == $cargo_bin})

    if not $already_in_path {
        $env.PATH = ($current_path | prepend $cargo_bin)
    }
}

# =============================================================================
# Editor Configuration
# =============================================================================
# Priority: nvim > vim > vi > nano
# Used by git, visudo, and other CLI tools

const EDITORS = ["nvim", "vim", "vi", "nano"]

let editor = (
    $EDITORS
    | where {|e| (which $e | is-not-empty) }
    | first
    | default "vi"
)

$env.EDITOR = $editor
$env.VISUAL = $editor

# =============================================================================
# Pager Configuration
# =============================================================================
# Default pager for man pages, git log, etc.

if (which less | is-not-empty) {
    # -R: Handle ANSI colors correctly
    # -M: Verbose prompt (show percentage, line numbers)
    # -i: Case-insensitive search
    # -j.5: Center search results vertically
    # --shift 5: Horizontal scroll step
    $env.LESS = "-R -M -i -j.5 --shift 5"
    $env.PAGER = "less"
} else if (which more | is-not-empty) {
    $env.PAGER = "more"
}

# =============================================================================
# Shell Identity
# =============================================================================
$env.SHELL = "nu"

# =============================================================================
# Tool-Specific Configuration
# =============================================================================

# Starship Prompt
# Custom configuration file location
if (which starship | is-not-empty) {
    if ($env.TMUX? | is-not-empty) {
        $env.STARSHIP_CONFIG = ($env.XDG_CONFIG_HOME | path join "starship" "starship.tmux.toml")
    } else {
        $env.STARSHIP_CONFIG = ($env.XDG_CONFIG_HOME | path join "starship" "starship.toml")
    }
}

# FZF (A command-line fuzzy finder)
if (which fzf | is-not-empty) {
    # Base options
    $env.FZF_DEFAULT_OPTS = [
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
    ] | str join " "
}

# Bat
if (which bat | is-not-empty) {
    $env.BAT_THEME = "Dracula"
    $env.BAT_STYLE = "numbers,changes,header"
}

# Eza
if (which eza | is-not-empty) {
    $env.EZA_COLORS = "da=36:di=34:ln=35:so=32:pi=33:ex=31:bd=34:cd=34:su=31:sg=31:tw=34:ow=34"
}

# Ripgrep
if (which rg | is-not-empty) {
    # Configuration file location
    let ripgreprc = ($env.XDG_CONFIG_HOME | path join "ripgrep" "config")
    if ($ripgreprc | path exists) {
        $env.RIPGREP_CONFIG_PATH = $ripgreprc
    }
}

# WakaTime CLI
$env.WAKATIME_HOME = ($env.WAKATIME_HOME? | default ($env.XDG_CONFIG_HOME | path join "wakatime"))

# Yazi CLI
if (which yazi | is-not-empty) {
    $env.YAZI_CONFIG_HOME = ($env.YAZI_CONFIG_HOME? | default ($env.XDG_CONFIG_HOME | path join "yazi"))
}

# Zoxide
if (which zoxide | is-not-empty) {
    # Zoxide will be initialized in config.nu via autoload
    $env._ZO_DATA_DIR = $env.XDG_DATA_HOME
}

# =============================================================================
# Platform-Specific Configuration
# =============================================================================

# Windows-specific
if $nu.os-info.name == "windows" {
}

# macOS-specific
if $nu.os-info.name == "macos" {
    # Homebrew
    let brew_prefix = "/opt/homebrew"
    if ($brew_prefix | path exists) {
        $env.PATH = (
            $env.PATH
            | split row (char esep)
            | prepend ($brew_prefix | path join "bin")
            | prepend ($brew_prefix | path join "sbin")
            | uniq
        )
    }
}

# =============================================================================
# Development Tools
# =============================================================================

# Node.js
# Respect XDG for npm global packages
$env.NPM_CONFIG_USERCONFIG = ($env.XDG_CONFIG_HOME | path join "npm" "npmrc")
$env.NODE_REPL_HISTORY = ($env.XDG_DATA_HOME | path join "node_repl_history")

# Rust
let cargo_home = ($env.CARGO_HOME? | default ($nu.home-path | path join ".cargo"))
$env.CARGO_HOME = $cargo_home

# Python
$env.PYTHONPYCACHEPREFIX = ($env.XDG_CACHE_HOME | path join "python")
$env.PYTHONUSERBASE = ($env.XDG_DATA_HOME | path join "python")

# Go
let go_path = ($env.GOPATH? | default ($nu.home-path | path join "go"))
$env.GOPATH = $go_path
if (($go_path | path join "bin") | path exists) {
    $env.PATH = (
        $env.PATH
        | split row (char esep)
        | prepend ($go_path | path join "bin")
        | uniq
    )
}


# =============================================================================
# Local Overrides (not tracked in git)
# =============================================================================
# Load machine-specific or private environment variables
# Add these files to .gitignore to keep sensitive data out of version control

# env.local.nu - General local overrides
# Uncomment if you have this file:
# source ~/.config/nushell/env.local.nu

# env.work.nu - Work-specific settings
# Uncomment if you have this file:
# source ~/.config/nushell/env.work.nu

# env.private.nu - Private API keys, tokens, etc.
# Uncomment if you have this file:
# source ~/.config/nushell/env.private.nu
