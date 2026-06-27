################################################################################
# Requires just >= 1.52.0+
################################################################################

SHELL_TARGETS := "dotfiles/.bashrc dotfiles/.bash_profile dotfiles/.config/bash dotfiles/.config/shell"
VENDIR_LOCK_FILE := if os_family() == "windows" { "vendir.lock.windows.yml" } else { "vendir.lock.yml" }

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
    vendir sync --locked --lock-file {{ VENDIR_LOCK_FILE }}

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

[doc('Remove vendir dependencies')]
[group('Development')]
clean:
    @echo "🧹 Removing vendir dependencies..."
    rm -rf dotfiles/.config/alacritty/themes
    rm -rf dotfiles/.config/tmux/plugins
    rm -rf dotfiles/.config/hypr/wallpapers
    rm -rf dotfiles/.config/yazi/flavors
    rm -rf dotfiles/.config/yazi/plugins
    @echo "✅ Cleanup complete!"

# ==============================================================================
# Validators
# ==============================================================================

[group: 'Validators']
mod validate 'misc/justfiles/validate.just'

# ==============================================================================
# Documentation
# ==============================================================================

[group: 'Documentation']
mod docs 'misc/justfiles/docs.just'

# ==============================================================================
# Performance
# ==============================================================================

[group: 'Performance']
mod bench 'misc/justfiles/bench.just'
