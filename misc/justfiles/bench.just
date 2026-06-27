hyperfine := "hyperfine --warmup 2 --runs 10" + if os_family() == "windows" { "" } else { " --shell=none" }
json := env("BENCH_JSON", "")
markdown := env("BENCH_MARKDOWN", "")
show_output := env("BENCH_SHOW_OUTPUT", "")
home := env("HOME", env("USERPROFILE", ""))
tmux_config := env("BENCH_TMUX_CONFIG", home + "/.config/tmux/tmux.conf")

bash_raw := "bash --noprofile --norc -c exit"
bash_configured := "bash --noprofile --norc -i -c 'export HOME=\\$PWD/dotfiles; export XDG_CONFIG_HOME=\\$HOME/.config; source \\$XDG_CONFIG_HOME/bash/bash_profile; export HOME=\\$PWD/dotfiles; source \\$XDG_CONFIG_HOME/bash/bashrc; exit'"
zsh_raw := "zsh -f -c exit"
zsh_configured := "zsh --login --interactive -c exit"
nu_raw := "nu --no-config-file --no-std-lib -c exit"
nu_configured := "nu --login --interactive -c exit"
tmux_raw := "tmux -L dotfiles-bench-raw -f /dev/null new-session -d -s benchmark"
tmux_configured := "tmux -L dotfiles-bench-configured -f '" + tmux_config + "' new-session -d -s benchmark"
pwsh_raw := "pwsh -NoLogo -NoProfile -Command exit"
pwsh_configured := "pwsh -NoLogo -Command exit"
tmux_cleanup := "sh -c 'tmux -L dotfiles-bench-raw kill-server 2>/dev/null || true; tmux -L dotfiles-bench-configured kill-server 2>/dev/null || true'"

[doc('Run benchmarks for all supported tools')]
default: nu bash zsh
    {{ if os_family() == "windows" { "just bench pwsh" } else { "just bench tmux" } }}

[doc('Benchmark Nushell startup (raw vs configured)')]
nu: (_run "nu" nu_raw nu_configured)

[doc('Benchmark Bash startup (raw vs configured)')]
bash: (_run "bash" bash_raw bash_configured)

[doc('Benchmark Zsh startup (raw vs configured)')]
zsh: (_run "zsh" zsh_raw zsh_configured)

[doc('Benchmark Tmux startup (raw vs configured)')]
[unix]
tmux: (_run "tmux" tmux_raw tmux_configured tmux_cleanup tmux_cleanup)

[doc('Benchmark PowerShell startup (raw vs configured)')]
[windows]
pwsh: (_run "pwsh" pwsh_raw pwsh_configured)

[doc('Regenerate the Linux performance baseline')]
update: (_pipeline "update")

[doc('Compare performance with the baseline')]
ci: (_pipeline "check")

[private]
[no-cd]
_run name raw configured prepare="" conclude="":
    {{ hyperfine }} {{ if show_output == "1" { "--show-output" } else { "" } }} {{ if json == "" { "" } else { "--export-json " + json } }} {{ if markdown == "" { "" } else { "--export-markdown " + markdown } }} {{ if prepare == "" { "" } else { "--prepare \"" + prepare + "\"" } }} {{ if conclude == "" { "" } else { "--conclude \"" + conclude + "\"" } }} \
        --command-name {{ name }}.raw "{{ raw }}" \
        --command-name {{ name }}.configured "{{ configured }}"

[private]
[no-cd]
_pipeline mode:
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "$(uname -s)" == "Linux" ]] || { echo "error: performance baselines require Linux" >&2; exit 2; }

    results_dir="$(mktemp -d)"
    report="${PERFORMANCE_REPORT:-performance-report.md}"
    baseline_tmp="$(mktemp)"
    trap 'rm -rf -- "$results_dir"; rm -f -- "$baseline_tmp"' EXIT
    printf '## Performance report\n\n**Failed:** benchmark collection did not complete.\n' > "$report"

    export HOME="$PWD/dotfiles"
    export XDG_CONFIG_HOME="$HOME/.config"
    export BENCH_TMUX_CONFIG="$XDG_CONFIG_HOME/tmux/tmux.conf"
    export BENCH_SHOW_OUTPUT=1
    vendir sync --locked

    for target in bash zsh nu tmux; do
        BENCH_JSON="$results_dir/$target.json" BENCH_MARKDOWN="$results_dir/$target.md" just bench "$target"
    done

    jq -s '{results: [.[].results[]]}' "$results_dir"/*.json > "$results_dir/results.json"
    {
        for target in bash zsh nu tmux; do
            printf '### %s\n\n' "$target"
            cat "$results_dir/$target.md"
            printf '\n'
        done
    } > "$results_dir/tables.md"

    output="$(jq -n --arg mode "{{ mode }}" --slurpfile benchmark "$results_dir/results.json" \
        --slurpfile baseline misc/baseline.json --rawfile tables "$results_dir/tables.md" -f misc/bench.jq)"

    if [[ "{{ mode }}" == "update" ]]; then
        jq '.baseline' <<< "$output" > "$baseline_tmp"
        mv -- "$baseline_tmp" misc/baseline.json
        echo "Updated misc/baseline.json"
    else
        jq -r '.report' <<< "$output" > "$report"
        cat "$report"
        jq -e '.passed' <<< "$output" >/dev/null
    fi
