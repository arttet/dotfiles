# ~/.config/nushell/modules/git.nu

# =============================================================================
# Git Layer
# =============================================================================
#
# ~/.config/git/config [alias] is the base layer (works from any shell).
# This module only adds on top of it:
#
#   - fast shell shortcuts delegating to the git config aliases
#   - interactive fzf flows (-i suffix) complementing lazygit
#   - g? cheat sheet
#
# Launchers: g = git, gg = lazygit. Run g? to see everything.
#
# =============================================================================

export alias g = git
export alias gg = lazygit

# -----------------------------------------------------------------------------
# Fast path: thin wrappers over git config aliases (single source of truth)
# -----------------------------------------------------------------------------

export alias gst = git st
export alias gsw = git sw
export alias gswc = git swc
export alias ga = git a
export alias gaa = git aa
export alias gc = git c
export alias gca = git ca
export alias gpf = git pf
export alias gwip = git wip
export alias gunwip = git unwip
export alias gundo = git undo

# -----------------------------------------------------------------------------
# Interactive path (fzf)
# -----------------------------------------------------------------------------

# Preview for changed files covering every state: unstaged diff, staged diff,
# and plain content for untracked files (plain `git diff` shows none of the
# last two). Runs under sh (--with-shell) so it works on Windows too.
const CHANGED_FILE_PREVIEW = 'git diff --color=always -- {}; git diff --cached --color=always -- {}; if ! git ls-files --error-unmatch -- {} >/dev/null 2>&1; then bat --style=numbers --color=always -- {} 2>/dev/null || cat -- {}; fi'

# Scroll the preview from the keyboard, vim-style. Plain j/k would land in
# the fuzzy query, so they are bound with Alt.
const PREVIEW_SCROLL = 'alt-j:preview-down,alt-k:preview-up,alt-d:preview-half-page-down,alt-u:preview-half-page-up'

def ensure-fzf [] {
    if (which fzf | is-empty) {
        error make --unspanned { msg: "fzf is required for this command" }
    }
}

def ensure-git-success [operation: string] {
    if $env.LAST_EXIT_CODE != 0 {
        error make --unspanned { msg: $"Git failed to ($operation)." }
    }
}

# Multi-select changed files in fzf with a diff preview.
def pick-changed-files [
    header: string
    --worktree-only
]: nothing -> list<string> {
    let files = if $worktree_only {
        git diff --name-only -z
        | split row (char nul)
        | where { is-not-empty }
    } else {
        [
            (git diff --name-only -z)
            (git diff --cached --name-only -z)
            (git ls-files --others --exclude-standard -z)
        ]
        | each { split row (char nul) }
        | flatten
        | where { is-not-empty }
        | uniq
    }
    if ($files | is-empty) {
        return []
    }
    (
        $files
        | str join (char nul)
        | fzf --read0 --print0 --multi --ansi --height 60% --layout=reverse
            --with-shell 'sh -c'
            --preview $CHANGED_FILE_PREVIEW
            --preview-window 'right:70%'
            --bind $PREVIEW_SCROLL
            --header $header
        | split row (char nul)
        | where { is-not-empty }
    )
}

# Switch to a branch picked in fzf. Remote branches keep their full ref in the
# picker and create a tracking branch when no matching local branch exists.
export def gswi [] {
    ensure-fzf
    let local_branches = (
        git branch --format='%(refname:short)'
        | lines
    )
    let branch = (
        git branch --all --format='%(refname:short)'
        | lines
        | where { |it| $it != "HEAD" and not ($it ends-with "/HEAD") }
        | to text
        | fzf --height 40% --layout=reverse
            --preview 'git log --oneline --graph --color=always --max-count=20 {}'
            --bind $PREVIEW_SCROLL
            --header '🌿 Switch Branch'
        | str trim
    )
    if ($branch | is-not-empty) {
        if $branch in $local_branches {
            git switch $branch
        } else {
            let remote = ($branch | split row '/' | first)
            let local_branch = ($branch | str replace --regex $"^($remote)/" '')
            if $local_branch in $local_branches {
                git switch $local_branch
            } else {
                git switch --track $branch
            }
        }
        ensure-git-success "switch branches"
    }
}

# Stage files picked in fzf with a diff preview.
export def gai [] {
    ensure-fzf
    let files = (pick-changed-files '✨ GIT ADD (TAB: select | ENTER: confirm)')
    if ($files | is-empty) {
        return
    }
    git add -- ...$files
    ensure-git-success "stage selected files"
    print $"✅ Staged ($files | length) file\(s\)."
}

# Lazygit-style commit flow: stage the selected files, then commit the complete
# index, including changes that were already staged. With no argument the editor
# opens with the full diff; pass a message for a quick one-liner.
export def gci [message?: string] {
    ensure-fzf
    let files = (pick-changed-files '📝 SELECT FILES TO COMMIT (TAB: select | ENTER: commit)')
    if ($files | is-empty) {
        return
    }
    git add -- ...$files
    ensure-git-success "stage selected files"
    git diff --cached --stat
    if ($message | is-empty) {
        git commit --verbose
    } else {
        git commit -m $message
    }
    ensure-git-success "commit staged changes"
}

# Discard working-tree changes of files picked in fzf.
export def gri [] {
    ensure-fzf
    let files = (
        pick-changed-files
            '🗑️ DISCARD TRACKED CHANGES (TAB: select | ENTER: confirm)'
            --worktree-only
    )
    if ($files | is-empty) {
        return
    }
    git restore -- ...$files
    ensure-git-success "discard selected changes"
    print $"🗑️ Discarded changes in ($files | length) file\(s\)."
}

# Delete merged branches picked in fzf (current, main, master, dev are hidden).
export def gbdi [] {
    delete-branches false
}

# Force-delete branches picked in fzf (-D), even if unmerged.
export def gbDi [] {
    delete-branches true
}

def delete-branches [force: bool] {
    ensure-fzf
    let current = (git branch --show-current | str trim)
    let branches = (
        git branch --format='%(refname:short)'
        | lines
        | where { |it| $it != $current and $it not-in [main master dev] }
    )
    if ($branches | is-empty) {
        print "No deletable branches."
        return
    }
    let header = if $force {
        '🔥 FORCE DELETE BRANCH -D (TAB: select | ENTER: delete)'
    } else {
        '🔥 DELETE BRANCH (TAB: select | ENTER: delete)'
    }
    let selection = (
        $branches
        | to text
        | fzf --multi --height 40% --layout=reverse
            --preview 'git log --oneline --graph --color=always --max-count=20 {}'
            --bind $PREVIEW_SCROLL
            --header $header
        | lines
    )
    if ($selection | is-empty) {
        return
    }
    if $force {
        git branch -D ...$selection
        ensure-git-success "force-delete selected branches"
    } else {
        git branch -d ...$selection
        ensure-git-success "delete selected branches"
    }
}

# Browse commits in fzf, then show the picked one in full.
export def --wrapped glgi [...rest] {
    ensure-fzf
    let line = (
        git log --graph --decorate --color=always
            --format='%C(reset)@@%H@@%C(auto)%h %s %d' -n 200 ...$rest
        | fzf --ansi --no-sort --layout=reverse --delimiter '@@'
            --with-nth '1,3..' --accept-nth 2
            --preview 'git show --color=always --stat {2}'
            --bind 'ctrl-s:toggle-sort'
            --bind $PREVIEW_SCROLL
            --header '🔎 BROWSE COMMITS (ENTER: full view | CTRL-S: toggle sort)'
        | str trim
    )
    if ($line | is-not-empty) {
        git show $line
        ensure-git-success "show the selected commit"
    }
}

# Pick a modified file in fzf and open it in $EDITOR.
export def gdfi [] {
    ensure-fzf
    let files = (
        git diff --name-only --relative -z
        | split row (char nul)
        | where { is-not-empty }
    )
    if ($files | is-empty) {
        print "No modified files."
        return
    }
    let file = (
        $files
        | str join (char nul)
        | fzf --read0 --print0 --height 60% --layout=reverse
            --with-shell 'sh -c'
            --preview 'git diff --color=always -- {}'
            --preview-window 'right:70%'
            --bind $PREVIEW_SCROLL
            --header '📝 OPEN MODIFIED FILE'
        | split row (char nul)
        | first
    )
    if ($file | is-not-empty) {
        let editor = ($env.EDITOR? | default "hx")
        run-external $editor $file
    }
}

# Browse stashes in fzf, then pop / apply / drop the picked one.
export def gsli [] {
    ensure-fzf
    let stashes = (git stash list | lines)
    if ($stashes | is-empty) {
        print "No stashes found."
        return
    }
    let stash = (
        $stashes
        | to text
        | fzf --delimiter ':' --height 60% --layout=reverse
            --preview 'git stash show --include-untracked --color=always -p {1}'
            --bind $PREVIEW_SCROLL
            --header '📦 STASHES (ENTER: choose action)'
        | str trim
    )
    if ($stash | is-empty) {
        return
    }
    let ref = ($stash | split row ':' | first)
    let action = (
        [pop apply drop]
        | to text
        | fzf --height 20% --layout=reverse --header $"Action for ($ref)"
        | str trim
    )
    if ($action | is-not-empty) {
        git stash $action $ref
        ensure-git-success $"($action) the selected stash"
    }
}

# Browse the reflog in fzf and detach onto the picked entry (rescue lost work).
export def grfi [] {
    ensure-fzf
    let entry = (
        git reflog --color=always
        | fzf --ansi --no-sort --layout=reverse
            --preview 'git show --color=always --stat {1}'
            --bind $PREVIEW_SCROLL
            --header '🕰️ REFLOG (ENTER: switch --detach)'
        | str trim
    )
    if ($entry | is-not-empty) {
        git switch --detach ($entry | split row ' ' | first)
        ensure-git-success "switch to the selected reflog entry"
    }
}

# -----------------------------------------------------------------------------
# Cheat sheet
# -----------------------------------------------------------------------------

export def "g?" [] {
    [
        [cmd desc];
        [g "git"]
        [gg "lazygit"]
        [gst "git status"]
        [gsw "git switch"]
        [gswc "git switch -c"]
        [ga "git add"]
        [gaa "git add -A"]
        [gc "git commit"]
        [gca "git commit --amend --no-edit"]
        [gpf "git push --force-with-lease"]
        [gwip "create WIP commit without hooks"]
        [gunwip "undo last WIP commit"]
        [gundo "undo last commit, keep changes unstaged"]
        [gai "interactive add/stage files"]
        [gci "lazygit-style commit: add selected files, commit full index"]
        [gri "interactive discard tracked working-tree changes"]
        [gswi "interactive switch branch"]
        [gbdi "interactive delete merged branches"]
        [gbDi "interactive force-delete branches"]
        [glgi "interactive commit browser"]
        [gdfi "pick modified file and open in $EDITOR"]
        [gsli "interactive stash pop/apply/drop"]
        [grfi "interactive reflog rescue"]
    ]
}
