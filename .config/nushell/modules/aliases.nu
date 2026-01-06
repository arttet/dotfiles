# ~/.config/nushell/modules/aliases.nu
# =============================================================================
# Nushell Aliases & Modern Tool Replacements
# =============================================================================
#
# This module provides:
#   - Short convenience aliases for common developer commands
#   - Modern replacements for classic UNIX tools with graceful fallbacks
#
# Each command automatically selects a modern tool if it is available.
# If not, the original system command is executed.
#
# This file is safe to source on any system.


# =============================================================================
# Standard Navigation
# =============================================================================

export alias .. = cd ..
export alias ... = cd ../..
export alias .... = cd ../../..
export alias _ = cd -

# =============================================================================
# Editor
# =============================================================================

# Open the Neovim editor
export alias n = nvim

# Open the Neovim editor in the current directory
export alias "n." = nvim .


# =============================================================================
# Make
# =============================================================================

# Run the default build workflow
export alias m = make

# Build the project
export alias mb = make build

# Run the test suite
export alias mt = make test


# =============================================================================
# Cargo
# =============================================================================

# Build the project
export alias cb = cargo build

# Build the project in release mode
export alias cbr = cargo build --release

# Run the application
export alias cr = cargo run

# Run all tests
export alias ct = cargo test

# Perform static analysis and validation
export alias cc = cargo check


# =============================================================================
# Node.js
# =============================================================================

# Install project dependencies
export alias ni = npm install

# Start the development environment
export alias nd = npm run dev

# Start the application
export alias ns = npm start

# Build the production bundle
export alias nb = npm run build


# =============================================================================
# Python
# =============================================================================

# Install a Python package
export alias pi = pip install

# Display installed Python packages
export alias pl = pip list


# =============================================================================
# File Viewing
# Uses: bat (if available), otherwise falls back to cat
# =============================================================================

# View files with syntax highlighting
export def --wrapped cat [...args] {
    let theme = ($env.BAT_THEME? | default "Catppuccin Mocha")

    if (which bat | is-not-empty) {
        bat --theme $theme ...$args
    } else if (which batcat | is-not-empty) {
        batcat --theme $theme ...$args
    } else {
        ^cat ...$args
    }
}

# View files with plain output (no headers, no line numbers)
export def --wrapped catp [...args] {
    let theme = ($env.BAT_THEME? | default "Catppuccin Mocha")

    if (which bat | is-not-empty) {
        bat --theme $theme --plain ...$args
    } else if (which batcat | is-not-empty) {
        batcat --theme $theme --plain ...$args
    } else {
        ^cat ...$args
    }
}

# View files without paging (display the entire file at once)
export def --wrapped catl [...args] {
    let theme = ($env.BAT_THEME? | default "Catppuccin Mocha")

    if (which bat | is-not-empty) {
        bat --theme $theme --paging=never ...$args
    } else if (which batcat | is-not-empty) {
        batcat --theme $theme --paging=never ...$args
    } else {
        ^cat ...$args
    }
}


# =============================================================================
# Directory Listing
# Uses: eza (if available), otherwise falls back to ls
# =============================================================================

# List directory contents
export def --wrapped ls [...args] {
    if (which eza | is-not-empty) {
        eza --icons ...$args
    } else {
        ^ls ...$args
    }
}

# List files in long format
export def --wrapped ll [...args] {
    if (which eza | is-not-empty) {
        eza --long --group --icons --time-style=long-iso ...$args
    } else {
        ^ls --long --classify=auto --color=auto ...$args
    }
}

# List all files including hidden ones
export def --wrapped la [...args] {
    if (which eza | is-not-empty) {
        eza --all --long --group --icons --time-style=long-iso ...$args
    } else {
        ^ls --all --long ...$args
    }
}

# Show a directory tree (depth = 2)
export def --wrapped lt [...args] {
    if (which eza | is-not-empty) {
        eza --tree --level=2 --icons ...$args
    } else {
        ^ls ...$args
    }
}

# Show a directory tree in long format
export def --wrapped llt [...args] {
    if (which eza | is-not-empty) {
        eza --long --tree --level=2 --icons ...$args
    } else {
        ^ls --long ...$args
    }
}

# List all files including hidden ones in a tree view
export def --wrapped lat [...args] {
    if (which eza | is-not-empty) {
        eza --all --long --tree --level=2 --group --icons --time-style=long-iso ...$args
    } else {
        ^ls --all --long ...$args
    }
}

# List files with git status information
export def --wrapped lg [...args] {
    if (which eza | is-not-empty) {
        eza --long --git --icons ...$args
    } else {
        ^ls ...$args
    }
}


# =============================================================================
# File Search
# Uses: fd (if available), otherwise falls back to find
# =============================================================================

# Find files excluding .git
export def --wrapped ffind [...args] {
    if (which fd | is-not-empty) {
        fd --hidden --follow --exclude .git ...$args
    } else {
        ^find ...$args
    }
}

# Find all files including ignored ones
export def --wrapped fda [...args] {
    if (which fd | is-not-empty) {
        fd --hidden --follow --no-ignore ...$args
    } else {
        ^find ...$args
    }
}


# =============================================================================
# Text Search
# Uses: ripgrep (rg) if available, otherwise falls back to grep
# =============================================================================

# Search text with colored output
export def --wrapped grep [...args] {
    if (which rg | is-not-empty) {
        rg --color=auto ...$args
    } else {
        ^grep ...$args
    }
}

# Search all files including ignored ones
export def --wrapped rga [...args] {
    if (which rg | is-not-empty) {
        rg --hidden --no-ignore ...$args
    } else {
        ^grep ...$args
    }
}

# Show only filenames with matches
export def --wrapped rgf [...args] {
    if (which rg | is-not-empty) {
        rg --files-with-matches ...$args
    } else {
        ^grep -l ...$args
    }
}


# =============================================================================
# Process Management
# Uses: procs (if available), otherwise falls back to ps
# =============================================================================

# List running processes
export def --wrapped ps [...args] {
    if (which procs | is-not-empty) {
        procs ...$args
    } else {
        ^ps ...$args
    }
}

# Show processes in a tree view
export def --wrapped pst [...args] {
    if (which procs | is-not-empty) {
        procs --tree ...$args
    } else {
        ^ps ...$args
    }
}

# Watch processes in real time
export def --wrapped psw [...args] {
    if (which procs | is-not-empty) {
        procs --watch ...$args
    } else {
        ^ps ...$args
    }
}


# =============================================================================
# System Monitoring
# Uses: bottom (btm) if available, otherwise falls back to top
# =============================================================================

# Monitor system resources interactively
export def --wrapped top [...args] {
    if (which btm | is-not-empty) {
        btm ...$args
    } else {
        ^top ...$args
    }
}


# =============================================================================
# Disk Usage
# =============================================================================
# df:
#   Uses: duf (if available), otherwise falls back to df
# du:
#   Uses: dua (if available), otherwise falls back to du
# =============================================================================

# Display disk usage overview
export def --wrapped df [...args] {
    if (which duf | is-not-empty) {
        duf ...$args
    } else {
        ^df ...$args
    }
}

# Browse disk usage interactively
export def --wrapped du [...args] {
    if (which dua | is-not-empty) {
        dua interactive ...$args
    } else {
        ^du ...$args
    }
}

# Show disk usage summary
export def --wrapped duu [...args] {
    if (which dua | is-not-empty) {
        dua ...$args
    } else {
        ^du ...$args
    }
}


# =============================================================================
# Documentation
# Uses: tldr (if available), otherwise falls back to man
# =============================================================================

# Display simplified manuals
export def --wrapped man [...args] {
    if (which tldr | is-not-empty) {
        tldr ...$args
    } else {
        ^man ...$args
    }
}
