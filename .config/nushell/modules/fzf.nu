# ~/.config/nushell/modules/fzf.nu

# =============================================================================
# FZF Integration Module
# =============================================================================

def resolve-clipboard-cmd [] {
    if (which pbcopy | is-not-empty) {
        "pbcopy"
    } else if (which clip.exe | is-not-empty) {
        "clip.exe"
    } else if (which xclip | is-not-empty) {
        "xclip -selection clipboard"
    } else if (which wl-copy | is-not-empty) {
        "wl-copy"
    } else {
        null
    }
}


# Interactive File Edit using fzf
export def fzf-edit [] {
    if (which fzf | is-empty) {
        error make { msg: "❌ fzf not found" }
    }

    let preview_cmd = (
        if (which bat | is-not-empty) {
            "bat --color=always --style=numbers --line-range=:500 {}"
        } else if (which cat | is-not-empty) {
            "cat {}"
        } else {
            "echo {}"
        }
    )

    mut fzf_opts = [
        $"--preview=($preview_cmd)"
        "--preview-window=right:50%:wrap"
        "--header=✏️  EDIT FILE | Enter: open | Ctrl-P: copy path | Ctrl-Y: copy content"
        "--color=header:italic"
    ]

    let clip_cmd = (resolve-clipboard-cmd)
    if $clip_cmd != null {
        let copy_path_action = 'execute-silent(echo {} | nu --stdin -c "$in | (_CLIP_)")'
        let copy_path_action = $copy_path_action | str replace '_CLIP_' $clip_cmd

        let copy_content_action = 'execute-silent(cat {} | nu --stdin -c "$in | (_CLIP_)")'
        let copy_content_action = $copy_content_action | str replace '_CLIP_' $clip_cmd

        $fzf_opts ++= [
            $"--bind=ctrl-p:($copy_path_action)"
            $"--bind=ctrl-y:($copy_content_action)"
        ]
    }

    if ($env.FZF_DEFAULT_OPTS? | is-not-empty) {
        let fzf_default_opts = $env.FZF_DEFAULT_OPTS | split row " " | where { |x| $x != "" }
        $fzf_opts ++= $fzf_default_opts
    }

    let selected: string = (
        ^fd -t f --hidden --follow --exclude .git
        | ^fzf ...$fzf_opts
        | str trim
    )

    if ($selected | is-not-empty) {
        let file = $selected
        let editor = ($env.EDITOR? | default "nvim")

        if ($file | path exists) {
            print $"📝 Opening: (ansi green)($file)(ansi reset)"
            ^$editor $file
        } else {
            print $"❌ File not found: (ansi red)($file)(ansi reset)"
        }
    }
}

export const FZF_EDIT_BINDING = {
    name: fzf_edit
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: { send: executehostcommand cmd: "fzf-edit" }
}


# Interactive Directory Search using fzf
export def fzf-cd --env [] {
    if (which fzf | is-empty) {
        error make { msg: "❌ fzf not found" }
    }

    let preview_cmd: string = (
        if (which eza | is-not-empty) {
            "^eza --tree --level=2 --icons --color=always {}"
        } else if (which tree | is-not-empty) {
            "^tree -C {}"
        } else {
            "ls -la {}"
        }
    )

    # Directory search options
    mut fzf_opts: list<string> = [
        $"--preview=($preview_cmd)"
        "--preview-window=right:50%:wrap"
        "--header=🚀 JUMP TO DIR | Enter: cd | Ctrl-P: copy path"
        "--color=header:italic"
    ]

    let clip_cmd = (resolve-clipboard-cmd)
    if $clip_cmd != null {
        let copy_path_action = 'execute-silent(echo {} | nu --stdin -c "$in | (_CLIP_)")'
        let copy_path_action = $copy_path_action | str replace '_CLIP_' $clip_cmd

        $fzf_opts ++= [
            $"--bind=ctrl-p:($copy_path_action)"
        ]
    }

    if ($env.FZF_DEFAULT_OPTS? | is-not-empty) {
        let fzf_default_opts: list<string> = $env.FZF_DEFAULT_OPTS | split row " " | where { |x| $x != "" }
        $fzf_opts ++= $fzf_default_opts
    }

    let selected = (
        ^fd -t d --hidden --follow --exclude .git
        | ^fzf ...$fzf_opts
        | str trim
    )

    if ($selected | is-not-empty) {
        let dir = $selected
        cd $dir
        print $"📂 Changed to: (ansi green)($dir)(ansi reset)"
    }
}

export const FZF_CD_KEYBINDING = {
    name: fzf_cd
    modifier: alt
    keycode: char_c
    mode: [emacs, vi_normal, vi_insert]
    event: { send: executehostcommand cmd: "fzf-cd" }
}

# Interactive History Search using fzf
export def fzf-history [] {
    if (which fzf | is-empty) {
        error make { msg: "❌ fzf not found" }
    }

    # History search options
    mut fzf_opts = [
        "--tac"
        "--no-sort"
        "--exact"
        "--header=📜 COMMAND HISTORY | Enter: insert | Ctrl-Y: copy command"
        "--color=header:italic"
    ]

    let parse_pattern = "{num} [{ts}] {command}"

    let clip_cmd = (resolve-clipboard-cmd)
    if $clip_cmd != null {
        let bind_template = 'execute-silent(echo {} | nu --stdin -c "_PARSE_ | get command.0 | str trim | _CLIP_")'

        let copy_action = (
            $bind_template
            | str replace '_PARSE_' $"parse '($parse_pattern)'"
            | str replace '_CLIP_' $clip_cmd
        )

        $fzf_opts ++= [
            $"--bind=ctrl-y:($copy_action)"
        ]
    }

    if ($env.FZF_DEFAULT_OPTS? | is-not-empty) {
        let fzf_default_opts = $env.FZF_DEFAULT_OPTS | split row " " | where { |x| $x != "" }
        $fzf_opts ++= $fzf_default_opts
    }

    let history_lines = (
        history
        | enumerate
        | each { |r|
            let ts = ($r.item.start_timestamp | date humanize)
            $"($r.index) [($ts)] ($r.item.command)"
        }
    )

    if ($history_lines | is-empty) {
        print "📭 No command history found"
        return
    }

    let selected = (
        $history_lines
        | str join (char newline)
        | ^fzf ...$fzf_opts
        | str trim
    )

    if ($selected | is-not-empty) {
        let history_line = $selected
        let cmd = (
            $history_line
            | parse $parse_pattern
            | get command.0
            | str trim
        )
        commandline edit --replace $cmd
    }
}

export const FZF_HISTORY_BINDING = {
    name: fzf_history
    modifier: control
    keycode: char_r
    mode: [emacs, vi_normal, vi_insert]
    event: { send: executehostcommand cmd: "fzf-history" }
}
