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

The repository supports three deployment strategies, each with different trade-offs.

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
just check    # dry-run preview
just deploy   # dotter deploy --verbose --force
just undeploy # dotter undeploy
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

### GNU Stow (Alternative)

On Unix systems, Stow provides a simple symlink tree without profiles.

```bash
just install    # stow -v --target=$HOME dotfiles
just uninstall  # stow -v --delete --target=$HOME dotfiles
```

Stow links the entire `dotfiles/` directory, so it is less granular than dotter but requires no extra tooling beyond Stow itself.

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

### Windows vs Linux Differences

| Concern      | Linux / macOS                            | Windows                                  |
| :----------- | :--------------------------------------- | :--------------------------------------- |
| Deployer     | dotter or stow                           | dotter only                              |
| Config path  | `~/.config`                              | `~/AppData/Roaming` for many GUI apps    |
| Shell        | Nushell, Bash, Zsh                       | Nushell, PowerShell, Bash (Git Bash)     |
| WM           | Hyprland                                 | Windows window manager                   |
| Just recipes | All except Windows-only `benchmark-pwsh` | All except Unix-only `install/uninstall` |

## XDG Base Directory Hierarchy

The configuration enforces [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) compliance to keep `$HOME` clean.

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
| Data          | `~/.local/share` | Tool data, plugin state, vendored assets      |
| Cache         | `~/.cache`       | Generated completions, download caches        |
| State         | `~/.local/state` | History, persistent sessions                  |
| User binaries | `~/.local/bin`   | Personal scripts and manually installed tools |

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

| Job         | Purpose                                                          |
| :---------- | :--------------------------------------------------------------- |
| `fmt`       | Check dprint, stylua, shfmt, and Justfile formatting             |
| `lint`      | Run yamllint, actionlint, shellcheck, selene, markdownlint, etc. |
| `security`  | TruffleHog secret scan + Trivy filesystem scan                   |
| `antivirus` | ClamAV malware scan                                              |
| `docs`      | Bun install/audit, VitePress build, Lychee link check            |

### Stage 2: Per-Tool Validation

The `verify` matrix runs only after Stage 1 succeeds. Each entry installs the tool via Nix and runs `just verify <app>`.

Examples:

- Hyprland: `hyprland --verify-config`
- Neovim: syntax check + headless `Lazy! sync`
- Helix: `hx --health all`
- Ghostty: `ghostty +validate-config`
- Nushell: `nu --config ... --env-config ... -c "exit 0"`
- Zellij: `zellij --config ... setup --dump-config`
- Bash / Zsh: `bash -n` / `zsh -n`

### Stage 3: Deploy

On pushes to `main` (not scheduled), the built docs artifact is published to GitHub Pages.

## Adding New Tools

When adding a new tool config, follow this checklist to keep deployment, validation, and documentation in sync:

1. **Create the config file** under `dotfiles/.config/<tool>/`.
2. **Map it for deployment** in `.dotter/global.toml`.
3. **Add a NixOS link** in `nixos/home.nix` if the tool is Linux/Wayland relevant.
4. **Add a validation recipe** in `misc/justfiles/verify.just` if needed.
5. **Add a CI job** in `.github/workflows/ci.yml` under the `verify` matrix.
6. **Document hotkeys** in `docs/src/<section>/<tool>.md` and add the entry to `docs/src/cheatsheet.md`.
7. **Update the docs navigation** in `docs/.vitepress/config.mts`.
8. **Run `just fmt` and `just lint`** before committing.

This keeps the repository self-describing: every deployed file has a documented path, a validation step, and a place in the architecture.
