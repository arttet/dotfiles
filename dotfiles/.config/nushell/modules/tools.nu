# Initializes or updates external shell tools.
#
# Generates configuration files in Nushell's standard autoload directory.
# These files are automatically sourced by Nushell on startup.
export def "init" [] {
    let autoload_dir = ($nu.data-dir | path join "vendor" "autoload")

    if not ($autoload_dir | path exists) {
        mkdir $autoload_dir
    }
    print $"Target directory: ($autoload_dir)"

    # Ensure local bin is in PATH for this session
    let local_bin = ($nu.home-path | path join ".local" "bin")
    let new_path = ($env.PATH | split row (char esep) | prepend $local_bin)

    # Define tools with their command names and generators
    let tools = [
        { name: "starship", file: "starship.nu", args: ["init", "nu"] },
        { name: "carapace", file: "carapace.nu", args: ["_carapace", "nushell"] },
        { name: "zoxide",   file: "zoxide.nu",   args: ["init", "nushell"] }
    ]

    with-env { PATH: $new_path } {
        for tool in $tools {
            let file_path = $autoload_dir | path join $tool.file

            # Check if tool exists (using the updated PATH)
            if (which $tool.name | is-not-empty) {
                print $"✓ Found ($tool.name). Generating ($tool.file)..."
                try {
                    # Run the command with its arguments
                    run-external $tool.name ...$tool.args | save -f $file_path
                    print $"  → ($tool.file) created successfully"
                } catch { |e|
                    print $"  ✗ Failed to generate ($tool.file): ($e.msg)"
                }
            } else {
                # Fallback: check if binary exists directly in local_bin
                let explicit_path = ($local_bin | path join $tool.name)
                if ($explicit_path | path exists) {
                     print $"✓ Found at ($explicit_path). Generating ($tool.file)..."
                     try {
                        run-external $explicit_path ...$tool.args | save -f $file_path
                        print $"  → ($tool.file) created successfully"
                     } catch { |e|
                        print $"  ✗ Failed to generate ($tool.file): ($e.msg)"
                     }
                } else {
                    print $"✗ ($tool.name) not found in PATH or .local/bin"
                    print $"  Install with: cargo install ($tool.name)"
                }
            }
        }
    }

    print "\n✓ Done! Restart Nushell to apply changes."
}

# Removes all generated tools configurations.
#
# Deletes the vendor/autoload directory. Use this to reset tools state.
export def "deinit" [] {
    let autoload_dir = ($nu.data-dir | path join "vendor" "autoload")

    if ($autoload_dir | path exists) {
        print $"Removing files from ($autoload_dir)..."

        # Try to remove individual files first (safer on Windows)
        try {
            let files = (ls $autoload_dir | where type == file | get name)
            for file in $files {
                print $"  Removing ($file | path basename)..."
                rm $file
            }

            # Then try to remove the directory
            try {
                rm $autoload_dir
                print "✓ Directory removed completely."
            } catch {
                print "⚠ Directory not empty or in use. Files removed, but directory remains."
            }
        } catch { |e|
            print $"✗ Error during cleanup: ($e.msg)"
            print "\n💡 Tip: Close and restart Nushell, then run 'clean' again."
        }

        print "✓ Tools removed. Restart Nushell to complete cleanup."
    } else {
        print "Nothing to clean (directory does not exist)."
    }
}

# Shows status of all configured tools
export def "status" [] {
    let autoload_dir = ($nu.data-dir | path join "vendor" "autoload")
    let local_bin = ($nu.home-path | path join ".local" "bin")

    print "Tool Status:\n"

    let tools = ["starship", "carapace", "zoxide"]

    for tool in $tools {
        let installed = (which $tool | is-not-empty) or (($local_bin | path join $tool) | path exists)
        let config_file = ($autoload_dir | path join $"($tool).nu")
        let configured = ($config_file | path exists)

        print $"($tool):"
        print $"  Installed: (if $installed { '✓' } else { '✗' })"
        print $"  Configured: (if $configured { '✓' } else { '✗' })"

        if $configured {
            let size = (ls $config_file | get size | first)
            print $"  Config size: ($size)"
        }
        print ""
    }
}
