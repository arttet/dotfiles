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

[doc('Install CI/dev tools via mise')]
[group('Development')]
install:
    mise install

[doc('Show available dependency updates')]
[group('Development')]
outdated:
    mise run deps:outdated

[doc('Format code (mise fmt gate, write mode)')]
[group('Development')]
fmt:
    mise run fmt:write

[doc('Run linters (mise lint gate)')]
[group('Development')]
lint:
    mise run lint:all

[doc('Run all mise checks (fmt, lint, security, antivirus, docs)')]
[group('Development')]
check:
    mise run check

[doc('Run CI locally via act')]
[group('Development')]
ci:
    mise run ci

[doc('Remove vendir dependencies and local tool caches')]
[group('Development')]
clean:
    @echo "🧹 Removing vendir dependencies and local caches..."
    rm -rf .tools
    rm -rf dotfiles/.config/alacritty/themes
    rm -rf dotfiles/.config/tmux/plugins
    rm -rf dotfiles/.config/hypr/wallpapers
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
# Validators
# ==============================================================================

[group('Validators')]
mod validate 'misc/justfiles/validate.just'

# ==============================================================================
# Documentation
# ==============================================================================

[group('Documentation')]
mod docs 'misc/justfiles/docs.just'

# ==============================================================================
# Performance
# ==============================================================================

[group('Performance')]
mod bench 'misc/justfiles/bench.just'

# ==============================================================================
# Neovim
# ==============================================================================

[group('Neovim')]
mod nvim 'misc/justfiles/nvim.just'
