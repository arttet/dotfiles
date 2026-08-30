################################################################################
# Requires just >= 1.52.0+
################################################################################

# ==============================================================================
# Help
# ==============================================================================

[doc('Show help')]
default: help

[doc('List all commands')]
help:
    @just --list --unsorted --list-submodules

# ==============================================================================
# Development
# ==============================================================================

[doc('Install tools')]
[group('Development')]
install:
    mise install
    mise run setup

[doc('Shows outdated tool versions')]
[group('Development')]
outdated:
    mise outdated --bump --local
    mise run deps:renovate

[doc('Upgrades outdated tools')]
[group('Development')]
upgrade:
    mise upgrade --bump --local

[doc('Format code')]
[group('Development')]
fmt:
    mise run fmt:write

[doc('Run linters')]
[group('Development')]
lint:
    mise run lint:all

[doc('Run CI checks')]
[group('Development')]
check:
    mise run check

[doc('Run CI locally')]
[group('Development')]
ci:
    mise run ci

[doc('Remove vendir dependencies')]
[group('Development')]
clean:
    @echo "🧹 Removing vendir dependencies..."
    rm -rf .tools
    rm -rf dotfiles/.config/alacritty/themes
    rm -rf dotfiles/.config/tmux/plugins
    rm -rf dotfiles/.local/share/backgrounds
    rm -rf dotfiles/.config/yazi/flavors
    rm -rf dotfiles/.config/yazi/plugins
    @just docs clean
    @echo "✅ Cleanup complete!"

# ==============================================================================
# Deploy
# ==============================================================================

[group('Deploy')]
mod deploy 'misc/justfiles/deploy.just'

# ==============================================================================
# Vendir
# ==============================================================================

[group('Vendir')]
mod vendir 'misc/justfiles/vendir.just'

# ==============================================================================
# Documentation
# ==============================================================================

[group('Documentation')]
mod docs 'misc/justfiles/docs.just'

# ==============================================================================
# Performance
# ==============================================================================

[doc('Run benchmarks [target: all, nu, bash, zsh, tmux, pwsh, ci, update]')]
[group('Performance')]
bench target="all":
    mise run bench:{{ target }}

# ==============================================================================
# Artifact
# ==============================================================================

[doc('Build the release set [target: all, dotfiles, sbom, licenses, manifest, scan, verify]')]
[group('Artifact')]
artifact target="all":
    mise run artifact:{{ target }}

# ==============================================================================
# Neovim
# ==============================================================================

[group('Neovim')]
mod nvim 'misc/justfiles/nvim.just'
