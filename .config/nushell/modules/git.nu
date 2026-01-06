# ~/.config/nushell/modules/git.nu

# =============================================================================
# Git Aliases and Wrappers
# =============================================================================

# Basic aliases
export alias gst = git status --short --branch
export alias g   = git
export alias ga  = git add
export alias gd  = git diff
export alias gl  = git pull
export alias gp  = git push
export alias gco = git checkout

# Enhanced Functions

# Commit with message
export def --wrapped gcm [msg: string, ...rest] {
    git add -A
    git commit -m $msg ...$rest
}

# Commit and Push
export def --wrapped gcp [msg: string, ...rest] {
    git add -A
    git commit -m $msg ...$rest
    git push
}

# Undo last commit
export def gundo [] {
    git reset --soft "HEAD~1"
    print "↩️  Last commit undone (changes staged)"
}

# Checkout Branch
export def gcob [] {
    if (which fzf | is-empty) {
        print "Error: fzf is required for this command"
        return
    }

    let branch = (git branch --all --format='%(refname:short)'
        | lines
        | where ($it != "HEAD")
        | str replace "origin/" ""
        | uniq
        | to text
        | fzf --height 40% --layout=reverse --preview 'git log --oneline --graph --color=always --max-count=20 {}'
    )

    if ($branch | is-not-empty) {
        git checkout ($branch | str trim)
    }
}
