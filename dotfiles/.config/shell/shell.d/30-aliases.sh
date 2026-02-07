# ~/.config/shell/shell.d/30-aliases.sh
# ==============================================
# Quick Navigation & Modern Tool Aliases
# ==============================================

# -------------------------------------------------------------------
# Navigation Shortcuts
# -------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -' # Go to previous directory

# Make
if command -v make >/dev/null 2>&1; then
    alias m='make'
fi

# Cargo (Rust package manager & build tool)
if command -v cargo >/dev/null 2>&1; then
    alias cb='cargo build'              # Build project
    alias cbr='cargo build --release'   # Release build (optimized)
    alias cr='cargo run'                # Run project
    alias crr='cargo run --release'     # Run optimized
    alias ct='cargo test'               # Run tests
    alias cc='cargo check'              # Quick check without building
    alias cf='cargo fmt'                # Format code
    alias ca='cargo add'                # Add dependency
    alias caa='cargo add --dev'         # Add dev dependency
    alias cdoc='cargo doc --open'       # Generate & open docs
fi

# Npm (Node.js package manager)
if command -v npm >/dev/null 2>&1; then
    alias nd='npm run dev'
    alias nb='npm run build'
    alias ns='npm start'
    alias nt='npm test'
    alias ni='npm install'
    alias nau='npm audit fix'           # Fix security vulnerabilities
fi

# Pip (Python package manager)
if command -v pip >/dev/null 2>&1; then
    alias pi='pip install'
    alias pu='pip uninstall'
    alias pl='pip list'
    alias pf='pip install -e .'         # Install in development mode
fi

# -------------------------------------------------------------------
# Editor Shortcuts
# -------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
    alias n='nvim'
elif command -v vim >/dev/null 2>&1; then
    alias n='vim'
fi

# -------------------------------------------------------------------
# Modern Tool Replacements
# -------------------------------------------------------------------

# Bat (cat replacement with syntax highlighting)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --theme="${BAT_THEME:-gruvbox-dark}"'
    alias catp='bat --theme="${BAT_THEME:-gruvbox-dark}" --plain'        # No lines/header
    alias catl='bat --theme="${BAT_THEME:-gruvbox-dark}" --paging=never' # No paging
    alias catpl='bat --theme="${BAT_THEME:-gruvbox-dark}" --plain --paging=never'
elif command -v batcat >/dev/null 2>&1; then
    # Debian/Ubuntu often names it batcat
    alias cat='batcat --theme="${BAT_THEME:-gruvbox-dark}"'
    alias catp='batcat --theme="${BAT_THEME:-gruvbox-dark}" --plain'
    alias catl='batcat --theme="${BAT_THEME:-gruvbox-dark}" --paging=never'
    alias catpl='batcat --theme="${BAT_THEME:-gruvbox-dark}" --plain --paging=never'
fi

# Eza (ls replacement)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias ll='eza --long --group --icons --time-style=long-iso'      # Long format
    alias la='eza --long --all --group --icons --time-style=long-iso' # Show hidden
    alias lt='eza --tree --level=2 --icons'                           # Tree view
    alias llt='eza --long --tree --level=2 --icons'                   # Long tree view
    alias lg='eza --long --git --icons'                               # Git status
fi

# Fd (find replacement)
if command -v fd >/dev/null 2>&1; then
    alias ffind='fd --hidden --follow --exclude .git'
    alias fda='fd --hidden --follow --no-ignore'
fi

# Ripgrep (grep replacement)
if command -v rg >/dev/null 2>&1; then
    alias grep='rg --color=auto'
    alias rga='rg --hidden --no-ignore'      # Search everything (including ignored)
    alias rgf='rg --files-with-matches'      # Only show filenames
fi

# Procs (ps replacement)
if command -v procs >/dev/null 2>&1; then
    alias ps='procs'
    alias pst='procs --tree'
    alias psw='procs --watch'
fi

# Bottom (top replacement)
command -v btm >/dev/null 2>&1 && alias top='btm'

# Duf (df replacement)
command -v duf >/dev/null 2>&1 && alias df='duf'

# Dua (du replacement)
if command -v dua >/dev/null 2>&1; then
    alias du='dua interactive'
    alias duu='dua'
fi

# TLDR (man replacement)
command -v tldr >/dev/null 2>&1 && alias man='tldr'
