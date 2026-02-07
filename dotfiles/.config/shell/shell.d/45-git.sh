# ~/.config/shell/shell.d/45-git.sh
# ==============================================
# Enhanced Git Helpers
# Dependencies: git, fzf, bat (optional for previews)
# ==============================================

command -v git >/dev/null 2>&1 || return 0

# -------------------------------------------------------------------
# Quick Aliases
# -------------------------------------------------------------------

# gcm
# Description: Git add, commit with message.
# Usage: gcm "message"
gcm()   { [ -n "$1" ] && git add -A && git commit -m "$1" && printf "\033[0;32m✅ Committed: \033[1;32m$1\033[0m\n"; }

# gcp
# Description: Git add, commit, and push.
# Usage: gcp "message"
gcp()   { [ -n "$1" ] && git add -A && git commit -m "$1" && git push && printf "\033[0;32m🚀 Pushed: \033[1;32m$1\033[0m\n"; }

# gundo
# Description: Soft reset (undo last commit, keep changes staged).
# Usage: gundo
gundo() { git reset --soft HEAD~1 && printf "\033[0;33m↩️  Last commit undone (files kept staged)\033[0m\n"; }

# gst
# Description: Short git status with branch info.
# Usage: gst
gst()   { git status --short --branch; }

# -------------------------------------------------------------------
# Interactive FZF Functions
# -------------------------------------------------------------------

# gadd
# Description: Interactively select files to add using fzf.
# Usage: gadd
gadd() {
    git status -s | \
    fzf -m --ansi \
        --preview 'git diff --color=always -- {-1}' \
        --preview-window=right:70% \
        --header "✨ GIT ADD (TAB: Select | ENTER: Confirm)" \
        --color header:italic | \
    cut -c4- | sed 's/^"//;s/"$//' | xargs -r git add && printf "\033[0;32m✅ Files added.\033[0m\n"
}

# grest
# Description: Interactively select files to restore (discard changes) using fzf.
# Usage: grest
grest() {
    git status -s | \
    fzf -m --ansi \
        --preview 'git diff --color=always -- {-1}' \
        --header "🗑️  DISCARD CHANGES (TAB: Select | ENTER: Confirm)" \
        --color header:italic:red | \
    cut -c4- | sed 's/^"//;s/"$//' | xargs -r git restore && printf "\033[0;31m🗑️  Changes discarded.\033[0m\n"
}

# gbdel
# Description: Interactively delete branches (excluding protected ones) using fzf.
# Usage: gbdel
gbdel() {
    git branch | grep -vE "^\*|master|main|dev" | \
    fzf -m --header "🔥 DELETE BRANCH (TAB: Select | ENTER: Delete)" \
        --color header:italic:red | \
    xargs -r git branch -D && printf "\033[0;31m🔥 Branch(es) deleted.\033[0m\n"
}

# gcob
# Description: Interactively checkout a branch with preview.
# Usage: gcob
gcob() {
    branch=$(git branch --all --format='%(refname:short)' | \
             grep -v "HEAD" | \
             fzf --preview 'git log --oneline --graph --color=always --max-count=20 {}' \
                 --header "🌿 CHECKOUT BRANCH")
    if [ -n "$branch" ]; then
        git checkout "${branch#origin/}"
        printf "\033[0;32m🌿 Switched to: \033[1;32m${branch#origin/}\033[0m\n"
    fi
}

# fbr - Checkout git branch (Alternative to gcob)
# Description: Legacy fuzzy branch checkout.
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $((2 + $(wc -l <<< "$branches"))) +m --header "🌿 CHECKOUT BRANCH (Legacy)" --preview 'git log --oneline --graph --color=always --max-count=20 {}') &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fco - Checkout git commit with fzf
# Description: Checkout a specific commit.
fco() {
    local commits commit
    commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
    commit=$(echo "$commits" | fzf --tac +s +m -e --header "🕰️  CHECKOUT COMMIT" --preview 'git show --color=always {1}') &&
    git checkout $(echo "$commit" | sed "s/ .*//")
}

# fshow - Git commit browser
# Description: Browser for git commits with preview.
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF" \
        --header "🔎 BROWSE COMMITS (ENTER to View)" \
        --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | xargs git show --color=always'
}

# gdf
# Description: Interactively view diffs of modified files.
# Usage: gdf
gdf() {
    git diff --name-only --relative | \
    fzf --preview 'git diff --color=always -- {}' \
        --preview-window=right:70% \
        --header "Select file to open" | \
    xargs -r ${EDITOR:-vim}
}

# gll
# Description: Rich git log browser with sort toggle.
# Usage: gll
gll() {
    git log --graph --color=always \
        --format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset' "$@" | \
    fzf --ansi --no-sort --reverse \
        --preview 'git show --color=always {2}' \
        --bind 'ctrl-s:toggle-sort' \
        --header 'ENTER: View Detail | CTRL-S: Toggle Sort'
}
