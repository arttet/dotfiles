################################################################################
# Requires just >= 1.52.0+
################################################################################

HYPERFINE := "hyperfine --warmup 2 --runs 10 --shell=none"
SHELL_TARGETS := "dotfiles/.bashrc dotfiles/.bash_profile dotfiles/.config/bash dotfiles/.config/shell"

# ==============================================================================
# Help
# ==============================================================================

[doc('Show help')]
default: help

[doc('List all commands')]
help:
    @just --list --unsorted --list-submodules

# ==============================================================================
# Usage
# ==============================================================================

[doc('Synchronize external plugins and dependencies')]
[group('Dotfiles')]
sync:
    vendir sync --locked

[doc('Update vendored dependencies to latest')]
[group('Dotfiles')]
update *args:
    vendir sync {{ args }}

[doc('Preview dotfiles deployment')]
[group('Dotfiles')]
check:
    dotter deploy --verbose --dry-run

[doc('Install dotfiles using dotter')]
[group('Dotfiles')]
deploy:
    dotter deploy --verbose --force

[doc('Uninstall dotfiles using dotter')]
[group('Dotfiles')]
undeploy:
    dotter undeploy --verbose --noconfirm --force

[doc('Install dotfiles using stow')]
[group('Dotfiles')]
[unix]
install:
    stow -v --target=${HOME} dotfiles

[doc('Uninstall dotfiles using stow')]
[group('Dotfiles')]
[unix]
uninstall:
    stow -v --delete --target=${HOME} dotfiles

# ==============================================================================
# Development
# ==============================================================================

[doc('Show how to enter the Nix dev shell')]
[group('Development')]
deps:
    @echo "🔧 All CI/dev tools are provided by the Nix flake."
    @echo "   Run: nix develop"

[doc('Format code')]
[group('Development')]
fmt:
    @echo "✨ Formatting code..."
    dprint fmt
    stylua --allow-hidden .
    shfmt --write {{ SHELL_TARGETS }}
    just --fmt
    @echo "✅ Code formatted!"

[doc('Run linters')]
[group('Development')]
lint:
    @echo "🔍 Running linters..."
    selene dotfiles/.config/nvim dotfiles/.config/wezterm
    selene --config dotfiles/.config/hypr/selene.toml dotfiles/.config/hypr/hyprland.lua
    shellcheck -s bash $(shfmt --find {{ SHELL_TARGETS }})
    yamllint .
    markdownlint-cli2
    actionlint
    stylelint --config .stylelintrc.json './dotfiles/.config/**/*.css'
    @echo "✅ Linting complete!"

[group: 'Development']
mod verify 'misc/justfiles/verify.just'

# ==============================================================================
# Documentation
# ==============================================================================

[group: 'Documentation']
mod docs 'misc/justfiles/docs.just'

# ==============================================================================
# Performance
# ==============================================================================

[doc('Run benchmarks for all supported shells')]
[group('Performance')]
bench:
    @just benchmark-bash
    @just benchmark-zsh
    @just benchmark-nu
    {{ if os_family() == "windows" { "@just benchmark-pwsh" } else { "" } }}

[doc('Benchmark Bash startup (raw vs configured)')]
[group('Performance')]
benchmark-bash:
    {{ HYPERFINE }} "bash --noprofile --norc -c 'exit 0'"
    {{ HYPERFINE }} "bash --login -i -c 'exit 0'"

[doc('Benchmark Zsh startup (raw vs configured)')]
[group('Performance')]
benchmark-zsh:
    {{ HYPERFINE }} "zsh -f -c 'exit 0'"
    {{ HYPERFINE }} "zsh --login --interactive -c 'exit 0'"

[doc('Benchmark Nushell startup (raw vs configured)')]
[group('Performance')]
benchmark-nu:
    {{ HYPERFINE }} "nu --no-config-file --no-std-lib -c 'exit 0'"
    {{ HYPERFINE }} "nu --login --interactive -c 'exit 0'"

[doc('Benchmark PowerShell 7.0 startup (raw vs configured)')]
[group('Performance')]
[windows]
benchmark-pwsh:
    {{ HYPERFINE }} "pwsh -NoLogo -NoProfile -Command 'exit 0'"
    {{ HYPERFINE }} "pwsh -NoLogo -Command 'exit 0'"
