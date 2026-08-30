# Architecture

This document explains how the dotfiles repository is organized, how configuration reaches your home directory, how shells start up, and how the project stays secure and consistent through CI/CD.

## Table of Contents

- [Deployment Models](#deployment-models)
- [XDG Base Directory Hierarchy](#xdg-base-directory-hierarchy)
- [Shell Startup Flow](#shell-startup-flow)
- [AI Tool Permission Model](#ai-tool-permission-model)
- [CI/CD Pipeline](#cicd-pipeline)
- [Adding New Tools](#adding-new-tools)

## Deployment Models

The repository supports two deployment strategies, each with different trade-offs.

### Dotter (Primary)

[dotter](https://github.com/SuperCuber/dotter) is the recommended deployer. It supports profiles, conditional Windows paths, and templating.

```toml
# .dotter/global.toml (excerpt)
[default]
depends = ["agent", "editor", "shell", "terminal"]

[agent]
depends = ["claude", "codex", "kimi", "opencode"]

[editor]
depends = ["helix", "zed"]

[shell]
depends = ["bash", "powershell", "zsh"]

[terminal]
depends = ["alacritty", "windows-terminal"]
```

Typical workflow:

```bash
just deploy check    # dry-run preview      (mise run deploy:check)
just deploy apply    # dotter deploy --force (mise run deploy:apply)
just deploy undeploy # dotter undeploy      (mise run deploy:undeploy)
```

Activate an optional profile at any time:

```bash
dotter deploy -p bash
```

Windows-only paths use `if = "dotter.windows"`:

```toml
[alacritty.files]
"dotfiles/.config/alacritty/alacritty.toml" = {
  target = "~\\AppData\\Roaming\\alacritty\\alacritty.toml",
  type = "symbolic",
  if = "dotter.windows"
}
```

### NixOS / Home Manager

For NixOS, `nixos/home.nix` creates a fixed list of out-of-store symlinks using `config.lib.file.mkOutOfStoreSymlink`. Every configured path is asserted to exist at evaluation time:

```nix
home.file = builtins.listToAttrs (
  map (target: {
    name = target;
    value = { source = link "${dotfilesRoot}/${target}"; };
  }) dotfileLinks
);
```

This path is useful when the Nix flake is the source of truth for the machine, but it covers only the Linux/Wayland subset of the dotfiles.

### Partial sync

`vendir` fetches two very different kinds of thing: a couple of megabytes of plugins and themes, and
about 1.1 GB of wallpaper images. Nothing in CI needs the second kind, so they live in separate configs.

| Command                  | Config                  | Lock files                                                          |
| :----------------------- | :---------------------- | :------------------------------------------------------------------ |
| `just deploy sync`       | both                    | both pairs                                                          |
| `just deploy config`     | `vendir.yml`            | `vendir.lock.yml` / `vendir.lock.windows.yml`                       |
| `just deploy wallpapers` | `vendir.wallpapers.yml` | `vendir.lock.wallpapers.yml` / `vendir.lock.wallpapers.windows.yml` |

Splitting by file rather than by `vendir sync --directory` is deliberate. `--directory` matches
`directories[].path` joined with `contents[].path` **exactly** — no prefix, no globs — so it would take
one flag per component, maintained by hand alongside `vendir.yml`. And a parent such as
`dotfiles/.config` cannot simply be declared as a `directories[].path`, because vendir owns that path
outright: it deletes everything under it that the config does not declare.

Deployment splits the same way. `dotfiles/.local/share/backgrounds` belongs to the `wallpapers` dotter
package, deliberately outside `default`; a desktop that wants them runs `just deploy wallpapers` and
adds `"wallpapers"` to `packages` in `.dotter/local.toml`.

### Windows vs Linux Differences

| Concern     | Linux / macOS                                    | Windows                               |
| :---------- | :----------------------------------------------- | :------------------------------------ |
| Deployer    | dotter                                           | dotter                                |
| Config path | `~/.config`                                      | `~/AppData/Roaming` for many GUI apps |
| Shell       | Nushell, Bash, Zsh                               | Nushell, PowerShell, Bash (Git Bash)  |
| WM          | Hyprland                                         | Windows window manager                |
| Benchmarks  | `just bench` skips shells that are not installed | same                                  |

## XDG Base Directory Hierarchy

The configuration enforces [XDG Base Directory](https://specifications.freedesktop.org/basedir/) compliance to keep `$HOME` clean.

```nu
# dotfiles/.config/nushell/env.nu (excerpt)
$env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($nu.home-dir | path join ".config"))
$env.XDG_CACHE_HOME  = ($env.XDG_CACHE_HOME?  | default ($nu.home-dir | path join ".cache"))
$env.XDG_DATA_HOME   = ($env.XDG_DATA_HOME?   | default ($nu.home-dir | path join ".local" "share"))
$env.XDG_STATE_HOME  = ($env.XDG_STATE_HOME?  | default ($nu.home-dir | path join ".local" "state"))
```

| Purpose       | Default path     | Example contents                              |
| :------------ | :--------------- | :-------------------------------------------- |
| Config        | `~/.config`      | Editor, shell, terminal, AI tool configs      |
| Data          | `~/.local/share` | Tool data, plugin state, wallpapers           |
| Cache         | `~/.cache`       | Generated completions, download caches        |
| State         | `~/.local/state` | History, persistent sessions                  |
| User binaries | `~/.local/bin`   | Personal scripts and manually installed tools |

Wallpapers follow that split: they are data, not configuration, so `vendir` fetches them into
`dotfiles/.local/share/backgrounds/` and `hyprpaper.conf` reads `~/.local/share/backgrounds/active`.
Keeping them out of `~/.config` is also what lets CI skip a 1.1 GB download — see
[Partial sync](#partial-sync).

Sensitive files such as SSH keys and OAuth tokens are stored outside the repository and referenced by path, never embedded in config files.

## Shell Startup Flow

Each shell has its own startup chain. Keeping the chains short and modular makes startup fast and debugging easy.

### Bash

```text
~/.bash_profile
  → dotfiles/.config/bash/bash_profile
      → loads profile.d/*.sh (XDG, PATH, environment)
      → ~/.bashrc
          → dotfiles/.config/bash/bashrc
              → loads shell/shell.d/*.sh
              → loads bash/bash.d/*.bash
```

### Zsh

```text
~/.zshenv
  → sets ZDOTDIR and XDG variables
~/.config/zsh/.zprofile
  → loads shell/profile.d/*.sh
~/.config/zsh/.zshrc
  → loads shell/shell.d/*.sh
  → loads zsh/zsh.d/*.zsh
```

### Nushell

```text
~/.config/nushell/env.nu
  → XDG, PATH, tool-specific environment
~/.config/nushell/config.nu
  → core settings
  → use modules/*.nu
  → generate autoload configs for Starship, Zoxide, Carapace on first run
```

### PowerShell

```text
~/.config/powershell/profile.ps1
  → ~/.config/powershell/config.ps1
      → XDG setup
      → cached tool inits
      → aliases and functions
```

Shared POSIX logic lives in `dotfiles/.config/shell/`, while shell-specific logic lives in `dotfiles/.config/bash/`, `dotfiles/.config/zsh/`, and `dotfiles/.config/nushell/`.

## AI Tool Permission Model

Four AI agents are configured: **Claude Code**, **Codex**, **Kimi Code**, and **OpenCode**. All four use a default-deny permission model.

### Permission Categories

| Category    | Typical Default | Description                                        |
| :---------- | :-------------- | :------------------------------------------------- |
| Read        | Allow / Deny    | Read source files; deny secrets and private keys   |
| Write       | Ask             | Create or modify files                             |
| Execute     | Ask             | Run shell commands, build scripts, tests           |
| Network     | Ask             | Fetch URLs, install packages, call APIs            |
| Destructive | Deny            | `rm -rf`, `git push`, `kubectl delete`, publishing |

### Examples from Configs

OpenCode denies dangerous bash patterns and asks for edits:

```jsonc
// dotfiles/.config/opencode/opencode.jsonc
"permission": {
  "*": "ask",
  "bash": {
    "*": "ask",
    "rm -rf *": "deny",
    "git push*": "deny",
    "git status*": "allow"
  }
}
```

Claude Code lists allowed read-only commands and denies secret paths:

```json
// dotfiles/.config/claude/settings.json (excerpt)
"permissions": {
  "allow": ["Bash(git status:*)", "Bash(git diff:*)", "Bash(just fmt:*)", ...],
  "deny": ["Read(**/.env)", "Read(**/*.pem)", "Bash(rm -rf:*)", "Bash(git push*:*)"]
}
```

Kimi Code uses ordered rules so sensitive-file denies are evaluated before the broad Read allow:

```toml
# dotfiles/.config/kimi-code/config.toml (excerpt)
[[permission.rules]]
decision = "deny"
pattern = "Read(*.env)"
reason = "Block reading local env files."

[[permission.rules]]
decision = "allow"
pattern = "Read"
reason = "Safe read-only file access."
```

Codex uses workspace sandboxing with explicit filesystem globs:

```toml
# dotfiles/.config/codex/config.toml (excerpt)
[permissions.workspace.filesystem]
":workspace_roots" = { "." = "write", "**/.env" = "deny", "**/*.key" = "deny" }
```

### Why Ask vs Deny?

- **Ask** is used for state-mutating operations (writes, shell execution, network). This keeps the agent helpful while preventing silent changes.
- **Deny** is reserved for irreversible or high-risk actions (deleting files, force pushes, privilege escalation) and for reading sensitive material (keys, credentials, history).
- **Allow** is limited to read-only inspection commands that are safe to run repeatedly, such as `git status`, `git diff`, and `just fmt`.

## CI/CD Pipeline

GitHub Actions (`.github/workflows/ci.yml`) runs in three stages.

### Stage 1: Quality Gates

All jobs run in parallel and must pass before Stage 2.

| Job                 | Purpose                                                                       |
| :------------------ | :---------------------------------------------------------------------------- |
| `guard`             | Classify the run as trusted or fork; every other job depends on it            |
| `fmt`               | Check dprint, stylua, shfmt, and Justfile formatting                          |
| `lint`              | Run yamllint, actionlint, shellcheck, selene, markdownlint, etc.              |
| `security`          | Secrets, SAST, HTML/SVG rules, Trivy, OSV, Grype, Grant, OPA policies, zizmor |
| `codeql`            | Semantic analysis of GitHub Actions workflows and TypeScript sources          |
| `dependency-review` | Block dependency changes with known high-severity advisories (pull requests)  |
| `antivirus`         | ClamAV malware scan                                                           |
| `docs`              | aube install/audit, VitePress build, Lychee link check, site hardening checks |

`guard` publishes a `trusted` output that gates every privileged step. A fork runs all of the above and
none of the steps that write to the repository — no SARIF upload, no pull-request comment, no deploy.

### Vulnerabilities, licenses and exploitability

Three questions, three tools, one document that says when an answer does not apply here:

| Question                  | Tool                                | Configuration                    |
| :------------------------ | :---------------------------------- | :------------------------------- |
| What is in it?            | Syft (from the artifact pipeline)   | —                                |
| Is it vulnerable?         | Trivy, OSV and Grype                | `.grype.yaml`                    |
| Which licenses are in it? | Grant, plus Trivy's license scanner | `.grant.yaml`                    |
| Does it apply to us?      | OpenVEX                             | `misc/vex/dotfiles.openvex.json` |

Findings are never silenced with an ignore file. A suppression is a VEX statement with an author, a
timestamp, the affected package and an OpenVEX justification, and `misc/policy/vex.rego` fails the build if
one of those is missing.

The license question is answered for the deployed tree, not just the committed one. `vendir` pulls in
tmux plugins and yazi flavors that are gitignored but end up in `$HOME`, so the security job runs
`mise run deploy:sync:config` first and then asks `mise run security:trivy:license` and
`mise run security:grant` about the result. Wallpapers are not part of that sync (see
[Partial sync](#partial-sync)); their licenses are covered when the wallpaper set is released.

The documentation site is covered too: `docs/src/public/_headers` ships a Content-Security-Policy and
the usual hardening headers, `misc/semgrep/web.yaml` rejects executable markup in SVG and Markdown,
and `mise run docs:security` proves the headers reached `docs/dist` and that no bundled JavaScript
carries a known advisory.

### Stage 2: Validation, Performance and Release

All three jobs run only after Stage 1 succeeds and use tools pinned by mise — no Nix, no stow.

| Job           | Purpose                                                                                                                     |
| :------------ | :-------------------------------------------------------------------------------------------------------------------------- |
| `validate`    | `mise run deploy:apply` (dotter), install the global toolchain, then `mise run validate:all`                                |
| `performance` | `mise run deploy:sync:config`, then `retry --times=3 -- mise run bench:ci`; compares shell startup ratios with the baseline |
| `artifact`    | `mise run artifact:all`; packs, describes, scans and verifies the release set                                               |

#### Release artifact

`dotfiles/` is published as something you can check rather than trust:

| File               | Answers                                             |
| :----------------- | :-------------------------------------------------- |
| `dotfiles.tar.gz`  | the bytes themselves                                |
| `sbom.spdx.json`   | what is inside                                      |
| `licenses.json`    | where each component came from and under what terms |
| `vex.openvex.json` | which findings do not apply here, and why           |
| `manifest.json`    | which commit and which vendir state produced this   |
| `checksums.sha256` | that nothing changed in transit                     |

The archive also carries `.dotter/` and `INSTALL.md`, which is what makes an unpacked release
deployable without the repository. It is packed in two halves — `git archive` over an explicit pathspec
for the tracked files, a second `tar` for the vendored plugins that git cannot see — and concatenated.
Both halves are deterministic, ownership is zeroed, timestamps come from the commit, and `gzip -n` runs
as its own step because `tar --gzip` would stamp the current time.

Wallpapers are a separate set, built only on pushes to `main` — ~1.1 GB of images that no pull request
needs, and they stay out of releases.

Tagged commits publish the set as a GitHub Release with build provenance
(`.github/workflows/release.yml`), but only when the tag sits on a `main` commit whose CI went green.
To check a release before you trust it:

```sh
gh release download --repo arttet/dotfiles
sha256sum --check checksums.sha256
gh attestation verify dotfiles.tar.gz --repo arttet/dotfiles
jq -r '.source.commit, .build.vendir.lock.sha256' manifest.json
jq -r '.warnings[]' licenses.json
grype sbom:sbom.spdx.json --vex vex.openvex.json
tar -xzf dotfiles.tar.gz
```

Untagged builds still land as CI artifacts (`gh run download --name dotfiles-artifacts`), but those
expire after 30 days and carry no provenance.

The license inventory reports rather than blocks. Some vendored components are GPL-3.0 or AGPL-3.0
while this repository is MIT; they are used deliberately, so the point is that you can see them.

`validate:all` covers AI agents, MCP servers, editors, shells, multiplexers, and CLI tools; for example
`hx --health all` for Helix, `zellij setup --check` for Zellij, and `yazi --debug` for Yazi.

### Stage 3: Deploy

Pull requests get a Cloudflare Pages preview (`mise run deploy:cloudflare:preview`). On pushes to `main`
(not scheduled), the docs go to Cloudflare Pages production and to GitHub Pages.

The site travels as a packed archive with a `checksums.sha256` beside it, not as a raw directory, so the
deploy job can check what it is about to publish: `docs:verify:hash` runs before `docs:unpack`, and a
corrupted archive stops the deploy instead of reaching the internet. GitHub Pages uses its own verified
channel and is unaffected.

## Adding New Tools

When adding a new tool config, follow this checklist to keep deployment, validation, and documentation in sync:

1. **Create the config file** under `dotfiles/.config/<tool>/`.
2. **Map it for deployment** in `.dotter/global.toml`.
3. **Add a NixOS link** in `nixos/home.nix` if the tool is Linux/Wayland relevant.
4. **Add a validation task** (`validate:<group>:<tool>`) in `mise.toml` and list it in `validate:all`.
5. **Document hotkeys** in `docs/src/<section>/<tool>.md` and add the entry to `docs/src/cheatsheet.md`.
6. **Update the docs navigation** in `docs/.vitepress/config.mts`.
7. **Run `just fmt` and `just lint`** before committing.

This keeps the repository self-describing: every deployed file has a documented path, a validation step, and a place in the architecture.
