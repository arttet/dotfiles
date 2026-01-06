# ~/.config/nushell/modules/yazi.nu
# =============================================================================
# File Manager: Yazi
# Uses: yazi, preserves cwd changes
# =============================================================================

# Launch Yazi file manager with all passed arguments
# Tracks current working directory and updates shell cwd after exit
export def --env --wrapped y [...args] {
    # Check if yazi is available
    if (which yazi | is-empty) {
        error make { msg: "❌ yazi not found" }
    }

    # Prepare temporary file to store yazi's cwd
    let tmp = (
        ($env.TMPDIR? | default (
            if $nu.os-info.name == "windows" { $env.TEMP } else { "/tmp" }
        ))
        + $"/yazi-cwd.(random chars)"
    )

    # Run yazi, passing all arguments and temporary cwd file
    ^yazi ...$args --cwd-file $tmp

    # Read new cwd from the temp file if it exists
    if ($tmp | path exists) {
        let cwd = (open $tmp | str trim)

        # Change directory if yazi updated it and it's different from current
        if ($cwd | is-not-empty) and ($cwd != $env.PWD) {
            cd $cwd
            print $"📂 Changed to: (ansi green)($cwd)(ansi reset)"
        }

        # Clean up temporary file
        rm -f $tmp
    }
}
