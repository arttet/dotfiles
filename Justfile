################################################################################
# Requires just >= 1.58.0+
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
# Deploy
# ==============================================================================

[doc('Synchronize external dependencies and wallpapers')]
[group('Deploy')]
sync:
    mise run deploy:sync

[doc('Deploy dotfiles using dotter')]
[group('Deploy')]
apply:
    mise run deploy:apply

[doc('Undeploy dotfiles using dotter')]
[group('Deploy')]
undeploy:
    mise run deploy:undeploy

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
# Documentation
# ==============================================================================

[group('Documentation')]
mod docs 'misc/justfiles/docs.just'
