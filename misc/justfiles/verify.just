# Validate dotfiles application configs. Each recipe runs the application's own
# config check against the repo config. The required tools must be on PATH;
# CI installs them per app via `nix profile install "$NIXPKGS#<tool>"`.
#
# `[no-cd]` keeps the working directory at the invocation root (repo root) so
# `$PWD`, relative paths, and `vendir sync` resolve correctly from a submodule.

[no-cd]
[doc('Verify Hyprland config')]
hyprland:
    hyprland --verify-config -c "$PWD/dotfiles/.config/hypr/hyprland.lua"

[no-cd]
[doc('Validate Neovim config')]
neovim:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp_home="$(mktemp -d)"
    trap 'rm -rf -- "$tmp_home"' EXIT
    mkdir -p "$tmp_home/.config"
    ln -s "$PWD/dotfiles/.config/nvim" "$tmp_home/.config/nvim"

    HOME="$tmp_home" luac -p "$tmp_home/.config/nvim/init.lua"

    export HOME="$tmp_home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_STATE_HOME="$HOME/.local/state"
    export XDG_CACHE_HOME="$HOME/.cache"

    nvim --headless "+Lazy! sync" +qa
    nvim_output="$tmp_home/nvim-output"
    if ! nvim --headless +qa >"$nvim_output" 2>&1; then
        cat "$nvim_output"
        exit 1
    fi

[no-cd]
[doc('Validate Helix config')]
helix:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp_home="$(mktemp -d)"
    trap 'rm -rf -- "$tmp_home"' EXIT
    mkdir -p "$tmp_home/.config"
    ln -s "$PWD/dotfiles/.config/helix" "$tmp_home/.config/helix"
    HOME="$tmp_home" XDG_CONFIG_HOME="$tmp_home/.config" hx --health all

[no-cd]
[doc('Validate Ghostty config')]
ghostty:
    ghostty +validate-config --config-file="$PWD/dotfiles/.config/ghostty/config"

[no-cd]
[doc('Validate WezTerm config')]
wezterm:
    wezterm --config-file "$PWD/dotfiles/.config/wezterm/wezterm.lua" show-keys >/dev/null

[no-cd]
[doc('Validate Alacritty config')]
alacritty:
    #!/usr/bin/env bash
    set -euo pipefail
    vendir sync --locked
    tmp_home="$(mktemp -d)"
    trap 'rm -rf -- "$tmp_home"' EXIT
    mkdir -p "$tmp_home/.config"
    ln -s "$PWD/dotfiles/.config/alacritty" "$tmp_home/.config/alacritty"
    HOME="$tmp_home" alacritty migrate --dry-run --config-file "$tmp_home/.config/alacritty/alacritty.toml" >/dev/null

[no-cd]
[doc('Validate Nushell config')]
nushell:
    nu --config dotfiles/.config/nushell/config.nu --env-config dotfiles/.config/nushell/env.nu -c "exit 0"

[no-cd]
[doc('Validate Yazi config')]
yazi:
    vendir sync --locked
    YAZI_CONFIG_HOME="$PWD/dotfiles/.config/yazi" yazi --debug

[no-cd]
[doc('Validate Starship configs')]
starship:
    STARSHIP_CONFIG="$PWD/dotfiles/.config/starship/starship.toml" starship print-config >/dev/null
    STARSHIP_CONFIG="$PWD/dotfiles/.config/starship/starship.tmux.toml" starship print-config >/dev/null
    STARSHIP_CONFIG="$PWD/dotfiles/.config/starship/starship.zellij.toml" starship print-config >/dev/null

[no-cd]
[doc('Validate Zellij config')]
zellij:
    zellij --config "$PWD/dotfiles/.config/zellij/config.kdl" setup --dump-config >/dev/null

[no-cd]
[doc('Validate Bash config')]
bash:
    bash -n dotfiles/.bashrc dotfiles/.bash_profile
    bash -n dotfiles/.config/bash/bashrc dotfiles/.config/bash/bash_profile
    bash -n dotfiles/.config/bash/bash.d/*.bash
    bash -n dotfiles/.config/shell/shell.d/*.sh dotfiles/.config/shell/profile.d/*.sh

[no-cd]
[doc('Validate Zsh config')]
zsh:
    zsh -n dotfiles/.config/zsh/.zshrc
    zsh -n dotfiles/.config/zsh/.zprofile
    zsh -n dotfiles/.config/zsh/zsh.d/*.zsh

[no-cd]
[doc('Validate Stow links')]
stow:
    #!/usr/bin/env bash
    set -euo pipefail
    vendir sync --locked
    tmp_home="$(mktemp -d)"
    trap 'rm -rf -- "$tmp_home"' EXIT
    mkdir -p "$tmp_home/.config"
    stow -v --target="$tmp_home" dotfiles
    test -L "$tmp_home/.bashrc"
    test -L "$tmp_home/.bash_profile"
    test -L "$tmp_home/.config/nvim"
    test -L "$tmp_home/.config/helix"
    test -L "$tmp_home/.config/nushell"
    test -L "$tmp_home/.config/starship"
    test -L "$tmp_home/.config/zellij"
    test -L "$tmp_home/.config/yazi"
    test -L "$tmp_home/.config/ghostty"
    test -L "$tmp_home/.config/zsh"

[no-cd]
[doc('Validate Git config')]
git:
    git config --file "$PWD/dotfiles/.config/git/config" --list >/dev/null

[no-cd]
[doc('Validate PowerShell config')]
powershell:
    pwsh -NoProfile -NonInteractive -Command "Get-ChildItem '$PWD/dotfiles/.config/powershell/*.ps1' | ForEach-Object { \$t = \$null; \$e = \$null; [System.Management.Automation.Language.Parser]::ParseFile(\$_.FullName, [ref]\$t, [ref]\$e); if (\$e) { throw \$e } }"

[no-cd]
[doc('Validate Claude config')]
claude:
    CLAUDE_CONFIG_DIR="$PWD/dotfiles/.config/claude" claude doctor

[no-cd]
[doc('Validate Codex config')]
codex:
    CODEX_HOME="$PWD/dotfiles/.config/codex" codex doctor

[no-cd]
[doc('Validate OpenCode config')]
opencode:
    OPENCODE_CONFIG_DIR="$PWD/dotfiles/.config/opencode" opencode debug config --pure >/dev/null

[no-cd]
[doc('Validate Kimi config')]
kimi:
    KIMI_CODE_HOME="$PWD/dotfiles/.config/kimi-code" kimi doctor
