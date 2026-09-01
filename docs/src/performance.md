# Performance testing

Shell startup performance is measured with [Hyperfine](https://github.com/sharkdp/hyperfine) and compared with `jq`. The CI gate detects
regressions in the repository configuration before they reach the main branch.

## Commands

The benchmark is mise tasks all the way down: `[vars]` in `mise.toml` holds every raw and configured
command, each `bench:<shell>` task is a single Hyperfine call, and `misc/jq/bench.jq` turns the results
into the report.

Run all benchmarks available on the current platform:

```sh
mise run bench:all
```

Run one shell benchmark:

```sh
mise run bench:nu
mise run bench:bash
mise run bench:zsh
mise run bench:tmux
mise run bench:pwsh
```

Every target runs on every platform; a shell that is not installed is simply skipped. The Linux CI gate
covers Bash, Zsh, Nushell, and Tmux — the four targets tracked in `misc/baseline.json`.

Compare the current checkout with the committed baseline:

```sh
mise run bench:ci
```

The command exits with a non-zero status when a normalized startup ratio regresses by more than the threshold
stored in `misc/baseline.json` (currently 20%).

## Measurement model

Each shell has two measurements:

- **Raw** starts the shell without user configuration.
- **Configured** starts the shell with the configuration from this repository.

For Tmux, raw mode uses no configuration while configured mode loads the repository config.

The tracked metric is the configured median divided by the raw median. Comparing this ratio instead of absolute time
reduces variance between GitHub-hosted runners. Hyperfine uses two warm-up runs and ten measured runs.

The committed baseline is stored in `misc/baseline.json`. It records the schema version, Linux platform, allowed
threshold, and one normalized ratio per monitored target.

## Finding what is slow

The gate says startup got worse. It never says which part of the configuration to look at, and the
shells share no profiler between them. `bench:profile:*` answers that by difference:

```sh
mise run bench:profile:bash
mise run bench:profile:zsh
```

One Hyperfine run times a shell sourcing the first configuration fragment, then the first two, and so on
in the order the rc files load them — `shell/profile.d`, then `shell/shell.d`, then `bash/bash.d` or
`zsh/zsh.d`. Subtracting consecutive medians gives a per-fragment cost:

```text
bare shell: 115.1 ms    configured: 7649.0 ms

fragment             cost_ms   noise_ms   reliable   cumulative_ms
30-aliases.sh         3192.6      194.4   true              5717.2
00-profile.sh         2017.9       74.0   true              2133.0
90-tools.bash         1021.9      129.0   true              7649.0
45-git.sh              499.7      256.3   true              6407.4
20-theme.sh            391.6      113.8   true              2524.6
50-os.sh               363.7      481.6   false             6771.1
44-system.sh           152.1      265.2   false             5907.7
43-net.sh              141.8      222.0   false             5755.6
50-completion.bash      -3.1      148.4   false             6627.1
40-functions.sh       -103.4      271.6   false             5613.8
10-options.bash       -140.8      498.3   false             6630.3
```

That run is from Git Bash on Windows, where interactive startup is pathologically slow; the absolute
numbers mean nothing on Linux. The ranking is the point, and it is unambiguous: three fragments carry
about 6.2 s of the 7.5 s, and the six unreliable rows are unreliable exactly because their noise exceeds
their cost.

**This is a ranking, not a budget, and it is not part of the gate.** `bench:ci` does not call it and CI
never runs it. Two properties matter when reading the table:

- Fragments are not independent — `90-tools` is cheaper once `50-completion` has run — so the costs need
  not sum to the configured total.
- `noise_ms` is the two measurements' deviations added in quadrature, and `reliable` is false wherever
  the cost is smaller than it. A negative cost means the method hit its own floor, not a fragment that
  makes the shell faster. On a noisy machine most rows can come back unreliable; the answer is more runs,
  not a smaller conclusion.

Use it to find the outlier, then measure that fragment on its own.

## Updating the baseline

Baseline generation is Linux-only because the performance job runs on Ubuntu. Use the same tools as CI —
`hyperfine`, `nushell`, `powershell`, and `tmux` are pinned in `mise.toml`, while `bash` and `zsh` come from
Nix — then run:

```sh
mise install
mise run bench:update
mise run bench:ci
```

Review the resulting ratios before committing `misc/baseline.json`. A baseline change should be isolated in the PR
and explain why the new startup cost is expected. There is no CI override: intentional regressions require a reviewed
baseline update.

Do not generate the committed baseline on Windows or macOS. Shell implementations, process startup costs, and
configuration paths are not comparable across operating systems.

## CI reporting

Performance is a Stage 2 job and runs after all Stage 1 quality gates. A regression fails the job and blocks deployment.

For pull requests created from branches in this repository, the job creates one `Shell startup performance` comment.
Later runs update that comment instead of adding another one. The report embeds the Markdown tables exported by Hyperfine, plus baseline and current ratios,
percentage changes, and the final verdict.

Performance testing is skipped for fork pull requests because their workflow tokens cannot safely update PR comments.
Pushes, scheduled runs, and manual runs execute the gate without creating a comment.
