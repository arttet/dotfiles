# ~/.config/nushell/env.nu
# =============================================================================
# Nushell Environment Configuration
# =============================================================================

# =============================================================================
# XDG Base Directory Standards
# =============================================================================
# Enforce XDG standards for clean home directory
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

$env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($nu.home-dir | path join ".config"))
$env.XDG_CACHE_HOME = ($env.XDG_CACHE_HOME? | default ($nu.home-dir | path join ".cache"))
$env.XDG_DATA_HOME = ($env.XDG_DATA_HOME? | default ($nu.home-dir | path join ".local" "share"))
$env.XDG_STATE_HOME = ($env.XDG_STATE_HOME? | default ($nu.home-dir | path join ".local" "state"))


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
let local_bin = ($nu.home-dir | path join ".local" "bin")

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

# Mise shims resolve the active tool version per directory.  On Windows, add
# the WinGet mise binary first: the shim executables delegate to `mise.exe`.
let mise_data = ($nu.home-dir | path join ".local" "share" "mise")
let mise_shims = ($mise_data | path join "shims")
let mise_windows_bin = (
    ($env.LOCALAPPDATA? | default ($nu.home-dir | path join "AppData" "Local"))
    | path join "Microsoft" "WinGet" "Packages" "jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe" "mise" "bin"
)
let current_path = (
    if ($env.PATH? | describe) == "string" {
        $env.PATH | split row (char esep)
    } else if ($env.PATH? | describe) =~ "list" {
        $env.PATH
    } else {
        []
    }
)

if (($nu.os-info.name == "windows") and (($mise_windows_bin | path join "mise.exe") | path exists)) {
    if not ($current_path | any {|p| $p == $mise_windows_bin}) {
        $env.PATH = ($current_path | prepend $mise_windows_bin)
    }
}

let path_with_mise = (
    if ($env.PATH? | describe) == "string" {
        $env.PATH | split row (char esep)
    } else {
        $env.PATH
    }
)
if (($mise_shims | path exists) and ((which mise | is-not-empty))) {
    if not ($path_with_mise | any {|p| $p == $mise_shims}) {
        $env.PATH = ($path_with_mise | prepend $mise_shims)
    }
}
# =============================================================================
# Editor Configuration
# =============================================================================
# Priority: helix > neovim > vim > vi > nano

const EDITORS = ["hx", "nvim", "vim", "vi", "nano"]

let editor = (
    $EDITORS
    | where {|e| (which $e | is-not-empty) }
    | first
    | default "vi"
)

$env.EDITOR = $editor
$env.VISUAL = $editor

# =============================================================================
# Shell Identity
# =============================================================================
$env.SHELL = "nu"

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
# CLI Tools Configuration
# =============================================================================

# Starship Prompt
if ($env.TMUX? | is-not-empty) {
    $env.STARSHIP_CONFIG = $env.XDG_CONFIG_HOME | path join "starship" "starship.tmux.toml"
} else {
    $env.STARSHIP_CONFIG = $env.XDG_CONFIG_HOME | path join "starship" "starship.toml"
}

# FZF (A command-line fuzzy finder)
$env.FZF_DEFAULT_OPTS = [
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
] | str join " "

# Bat
$env.BAT_THEME = "Dracula"
$env.BAT_CONFIG_PATH = ($env.XDG_CONFIG_HOME | path join "bat" "config")

# GitHub CLI
$env.GH_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "gh")

# Eza
$env.EZA_COLORS = "da=36:di=34:ln=35:so=32:pi=33:ex=31:bd=34:cd=34:su=31:sg=31:tw=34:ow=34"

# Ripgrep
$env.RIPGREP_CONFIG_PATH = $env.XDG_CONFIG_HOME | path join "ripgrep" "config"

# Claude Code
$env.CLAUDE_CONFIG_DIR = $env.CLAUDE_CONFIG_DIR? | default ($env.XDG_CONFIG_HOME | path join "claude")

# Codex CLI
$env.CODEX_HOME = ($env.CODEX_HOME? | default ($env.XDG_CONFIG_HOME | path join "codex"))

# Kimi Code
$env.KIMI_CODE_HOME = ($env.KIMI_CODE_HOME? | default ($env.XDG_CONFIG_HOME | path join "kimi-code"))

# WakaTime CLI
$env.WAKATIME_HOME = ($env.WAKATIME_HOME? | default ($env.XDG_CONFIG_HOME | path join "wakatime"))

# Yazi CLI
$env.YAZI_CONFIG_HOME = ($env.YAZI_CONFIG_HOME? | default ($env.XDG_CONFIG_HOME | path join "yazi"))

# Zoxide
# $env._ZO_DATA_DIR = $env.XDG_DATA_HOME

# =============================================================================
# Platform-Specific Configuration
# =============================================================================

# Windows-specific
if $nu.os-info.name == "windows" {
    $env.ZELLIJ_CONFIG_DIR = $nu.home-dir | path join ".config" "zellij"
}
