# Performance testing

Shell startup performance is measured with [Hyperfine](https://github.com/sharkdp/hyperfine) and compared with `jq`. The CI gate detects
regressions in the repository configuration before they reach the main branch.

## Commands

Run all benchmarks available on the current platform:

```sh
just bench
```

Run one shell benchmark:

```sh
just bench nu
just bench bash
just bench zsh
just bench tmux
just bench pwsh
```

PowerShell is available on Windows. The Linux CI gate covers Bash, Zsh, Nushell, and Tmux.

Compare the current checkout with the committed baseline:

```sh
just bench ci
```

The command exits with a non-zero status when a normalized startup ratio regresses by more than 5%.

## Measurement model

Each shell has two measurements:

- **Raw** starts the shell without user configuration.
- **Configured** starts the shell with the configuration from this repository.

For Tmux, raw mode uses no configuration while configured mode loads the repository config.

The tracked metric is the configured median divided by the raw median. Comparing this ratio instead of absolute time
reduces variance between GitHub-hosted runners. Hyperfine uses two warm-up runs and ten measured runs.

The committed baseline is stored in `misc/baseline.json`. It records the schema version, Linux platform, allowed
threshold, and one normalized ratio per monitored target.

## Updating the baseline

Baseline generation is Linux-only because the performance job runs on Ubuntu. Use the same Nix packages as CI, then
run:

```sh
just bench update
just bench ci
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
