# ~/.config/nushell/modules/history.nu

# =============================================================================
# History Tools
# =============================================================================
#
# Maintenance helpers for Nushell's SQLite command history
# ($nu.history-path, file_format: "sqlite" in config.nu).
#
# =============================================================================

def history-db [] {
    let db = $nu.history-path
    if not ($db | path exists) {
        error make --unspanned { msg: $"No history database found at ($db)." }
    }
    $db
}

def count-rows [db: string]: nothing -> int {
    open $db | query db "SELECT count(*) AS n FROM history" | get n.0
}

# Show overall stats and the most frequently used commands.
export def "history-tools stats" [
    --limit: int = 15 # number of top commands to show
] {
    let db = (history-db)

    let total = (count-rows $db)
    let unique = (open $db | query db "SELECT count(DISTINCT command_line) AS n FROM history" | get n.0)

    print $"Total commands:  ($total)"
    print $"Unique commands: ($unique)"
    print ""
    print $"Top ($limit) commands:"

    open $db
    | query db $"SELECT command_line, count\(*) AS count FROM history GROUP BY command_line ORDER BY count DESC LIMIT ($limit)"
    | rename command count
}

# Remove duplicate commands, keeping only the most recent occurrence of each.
export def "history-tools dedup" [] {
    let db = (history-db)

    let before = (count-rows $db)
    open $db | query db "DELETE FROM history WHERE id NOT IN (SELECT MAX(id) FROM history GROUP BY command_line)"
    open $db | query db "VACUUM"
    let after = (count-rows $db)

    print $"Removed ($before - $after) duplicate entries, ($after) remain."
}

# Delete history entries older than the given number of days.
export def "history-tools prune" [
    --days: int = 90 # delete entries older than this many days
] {
    let db = (history-db)

    let cutoff_ms = ((((date now) - ($days * 1day)) | into int) / 1_000_000 | math round)
    let before = (count-rows $db)
    open $db | query db $"DELETE FROM history WHERE start_timestamp < ($cutoff_ms)"
    open $db | query db "VACUUM"
    let after = (count-rows $db)

    print $"Removed ($before - $after) entries older than ($days) days, ($after) remain."
}

# Permanently delete all command history (asks for confirmation).
export def "history-tools wipe" [] {
    let db = (history-db)

    let confirm = (input $"This will permanently delete all command history from ($db). Type 'yes' to continue: ")
    if $confirm != "yes" {
        print "Aborted."
        return
    }

    open $db | query db "DELETE FROM history"
    open $db | query db "VACUUM"
    print "History wiped."
}
