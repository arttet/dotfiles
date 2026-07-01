# Validate dotfiles application configs. Each recipe runs the application's own
# config check against the repo config. The required tools must be on PATH;
# CI installs them per app via `nix profile install "$NIXPKGS#<tool>"`.
#
# `[no-cd]` keeps the working directory at the invocation root (repo root) so
# `$PWD`, relative paths, and `vendir sync` resolve correctly from a submodule.

# Window manager

[no-cd]
[doc('Validate Hyprland config')]
hyprland:
    hyprland --verify-config -c "$PWD/dotfiles/.config/hypr/hyprland.lua"

# Editors

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
[doc('Validate Neovim config')]
neovim:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp_home="$(mktemp -d)"
    # Best-effort cleanup: the bootstrap can install tooling whose files are
    # read-only (Go marks its module cache under $HOME/go read-only), so make the
    # tree writable first and never let a failed `rm` of a throwaway temp dir flip
    # the recipe's exit status.
    trap 'chmod -R u+w "$tmp_home" 2>/dev/null || true; rm -rf -- "$tmp_home" 2>/dev/null || true' EXIT
    mkdir -p "$tmp_home/.config"
    ln -s "$PWD/dotfiles/.config/nvim" "$tmp_home/.config/nvim"

    export HOME="$tmp_home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_STATE_HOME="$HOME/.local/state"
    export XDG_CACHE_HOME="$HOME/.cache"
    # Skip the (network + compile) treesitter parser install in CI; plugin loading
    # is still exercised. The config is on vim.pack now, not lazy.nvim.
    export NVIM_TS_NO_INSTALL=1

    # 1. Syntax-check every Lua file (deterministic, no network).
    #    `-L` follows the symlinked config dir (find -P would not descend into a
    #    symlinked start dir); `xargs -r` avoids running luac with no input.
    find -L "$tmp_home/.config/nvim" -name '*.lua' -print0 | xargs -0 -r -n1 luac -p

    # 2. Bootstrap plugins via vim.pack, then load the config headless and fail on
    #    any Lua error (E5xx / stack traceback). The headless load is only a valid
    #    smoke test once vim.pack has cloned the plugins, which needs a git
    #    executable that nvim itself can see plus network access. Otherwise every
    #    `vim.pack.add` raises E919/E5113 -- an environment limitation, not a config
    #    error -- so fall back to the deterministic Lua syntax check above.
    #
    #    vim.pack needs git visible to the nvim binary. On Windows git frequently
    #    lives only on the MSYS/Git-Bash PATH and is invisible to native nvim.exe,
    #    so probe a clean instance before paying the bootstrap cost.
    if [ "$(nvim --clean --headless "+lua io.write(vim.fn.executable('git'))" +qa 2>/dev/null)" != "1" ]; then
        echo "nvim cannot find a git executable; ran the Lua syntax check only and" >&2
        echo "skipped the vim.pack bootstrap + headless load smoke test." >&2
        exit 0
    fi

    nvim_output="$tmp_home/nvim-output"
    # Keep nvim alive long enough for vim.pack to finish cloning plugins on a
    # fresh bootstrap; otherwise partial clones break the next run.
    nvim --headless "+lua vim.defer_fn(function() vim.cmd('qa!') end, 120000)" >"$nvim_output" 2>&1 || true

    # If nothing installed (offline / clone failed), the smoke test could not run;
    # the syntax check already passed, so do not report a false failure.
    shopt -s nullglob
    installed=("$XDG_DATA_HOME"/nvim/site/pack/*/opt/*/)
    shopt -u nullglob
    if [ ${#installed[@]} -eq 0 ]; then
        echo "vim.pack installed no plugins (offline or clone failed); ran the Lua" >&2
        echo "syntax check only, skipped the headless load smoke test." >&2
        exit 0
    fi

    if grep -qiE 'E[0-9]{2,}:|stack traceback' "$nvim_output"; then
        echo "Neovim config produced errors:" >&2
        cat "$nvim_output" >&2
        exit 1
    fi

# Terminals

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
[doc('Validate Ghostty config')]
ghostty:
    ghostty +validate-config --config-file="$PWD/dotfiles/.config/ghostty/config"

[no-cd]
[doc('Validate WezTerm config')]
wezterm:
    wezterm --config-file "$PWD/dotfiles/.config/wezterm/wezterm.lua" show-keys >/dev/null

# Shells

[no-cd]
[doc('Validate Bash config')]
bash:
    bash -n dotfiles/.bashrc dotfiles/.bash_profile
    bash -n dotfiles/.config/bash/bashrc dotfiles/.config/bash/bash_profile
    bash -n dotfiles/.config/bash/bash.d/*.bash
    bash -n dotfiles/.config/shell/shell.d/*.sh dotfiles/.config/shell/profile.d/*.sh

[no-cd]
[doc('Validate Nushell config')]
nushell:
    nu --config dotfiles/.config/nushell/config.nu --env-config dotfiles/.config/nushell/env.nu -c "exit 0"

[no-cd]
[doc('Validate PowerShell config')]
powershell:
    pwsh -NoProfile -NonInteractive -Command "Get-ChildItem '$PWD/dotfiles/.config/powershell/*.ps1' | ForEach-Object { \$t = \$null; \$e = \$null; [System.Management.Automation.Language.Parser]::ParseFile(\$_.FullName, [ref]\$t, [ref]\$e); if (\$e) { throw \$e } }"

[no-cd]
[doc('Validate Zsh config')]
zsh:
    zsh -n dotfiles/.zshenv
    zsh -n dotfiles/.config/zsh/.zshrc
    zsh -n dotfiles/.config/zsh/.zprofile
    zsh -n dotfiles/.config/zsh/zsh.d/*.zsh

# Shell tooling

[no-cd]
[doc('Validate Starship configs')]
starship:
    STARSHIP_CONFIG="$PWD/dotfiles/.config/starship/starship.toml" starship print-config >/dev/null
    STARSHIP_CONFIG="$PWD/dotfiles/.config/starship/starship.tmux.toml" starship print-config >/dev/null
    STARSHIP_CONFIG="$PWD/dotfiles/.config/starship/starship.zellij.toml" starship print-config >/dev/null

[no-cd]
[doc('Validate Yazi config')]
yazi:
    vendir sync --locked
    YAZI_CONFIG_HOME="$PWD/dotfiles/.config/yazi" yazi --debug

[no-cd]
[doc('Validate Zellij config')]
zellij:
    zellij --config "$PWD/dotfiles/.config/zellij/config.kdl" setup --dump-config >/dev/null

# Dotfiles management

[no-cd]
[doc('Validate Tmux config')]
tmux:
    #!/usr/bin/env bash
    set -euo pipefail
    socket="tmux-ci-verify-$$"
    output_file="$(mktemp)"
    trap 'tmux -L "$socket" kill-server 2>/dev/null || true; rm -f -- "$output_file"' EXIT

    if [ "${TMUX_VALIDATE_SKIP_SYNC:-0}" != 1 ]; then
        vendir sync --locked
    fi

    plugin_root="$PWD/dotfiles/.config/tmux/plugins"
    test -f "$plugin_root/tmux-yank/yank.tmux"
    test -f "$plugin_root/tmux-fzf/main.sh"
    test -f "$plugin_root/tmux2k/2k.tmux"
    test -f "$plugin_root/tmux-resurrect/resurrect.tmux"
    test -f "$plugin_root/tmux-continuum/continuum.tmux"
    test ! -e "$plugin_root/tmux-harpoon"

    if ! HOME="$PWD/dotfiles" tmux -L "$socket" -f "$PWD/dotfiles/.config/tmux/tmux.conf" \
        new-session -d -s tmux-ci >"$output_file" 2>&1; then
        echo "Failed to start tmux server:" >&2
        cat "$output_file" >&2
        exit 1
    fi
    if [ -s "$output_file" ]; then
        echo "Tmux configuration errors detected:" >&2
        cat "$output_file" >&2
        exit 1
    fi

    tmux_cmd() {
        HOME="$PWD/dotfiles" tmux -L "$socket" "$@"
    }

    tmux_cmd show-options -gsqv set-clipboard | grep -Fx on >/dev/null
    tmux_cmd show-options -gqv @yank_selection | grep -Fx clipboard >/dev/null
    tmux_cmd show-options -gqv @yank_selection_mouse | grep -Fx clipboard >/dev/null
    tmux_cmd show-options -gqv @yank_with_mouse | grep -Fx on >/dev/null
    tmux_cmd show-options -gqv @yank_action | grep -Fx copy-pipe-and-cancel >/dev/null
    tmux_cmd show-options -gqv @tmux2k-theme | grep -Fx gruvbox >/dev/null
    tmux_cmd show-options -gqv @tmux2k-icons-only | grep -Fx false >/dev/null
    tmux_cmd show-options -gqv @tmux2k-left-plugins | grep -Fx 'session git cwd' >/dev/null
    tmux_cmd show-options -gqv @tmux2k-right-plugins | grep -Fx 'battery time' >/dev/null
    tmux_cmd show-options -gqv @tmux2k-refresh-rate | grep -Fx 5 >/dev/null
    tmux_cmd show-options -gqv @resurrect-capture-pane-contents | grep -Fx on >/dev/null
    tmux_cmd show-options -gqv @continuum-restore | grep -Fx on >/dev/null
    tmux_cmd show-options -gqv @continuum-save-interval | grep -Fx 15 >/dev/null
    tmux_cmd show-options -gqv status | grep -Fx 2 >/dev/null
    test -z "$(tmux_cmd show-options -gqv 'status-format[0]')"
    test -n "$(tmux_cmd show-options -gqv 'status-format[1]')"

    tmux_cmd show-options -gsqv escape-time | grep -Fx 0 >/dev/null
    tmux_cmd show-options -gqv detach-on-destroy | grep -Fx off >/dev/null
    tmux_cmd show-options -sqv extended-keys | grep -Fx on >/dev/null
    tmux_cmd show-options -sqv terminal-features | grep -F 'extkeys' >/dev/null
    tmux_cmd list-keys -T copy-mode-vi y | grep -F copy-selection-and-cancel >/dev/null
    tmux_cmd list-keys -T copy-mode-vi Enter | grep -F copy-selection-and-cancel >/dev/null
    tmux_cmd list-keys -T copy-mode-vi MouseDragEnd1Pane | grep -F copy-pipe-and-cancel >/dev/null
    tmux_cmd list-keys -T root M-Left | grep -F 'select-pane -L' >/dev/null
    tmux_cmd list-keys -T root M-Down | grep -F 'select-pane -D' >/dev/null
    tmux_cmd list-keys -T root M-Up | grep -F 'select-pane -U' >/dev/null
    tmux_cmd list-keys -T root M-Right | grep -F 'select-pane -R' >/dev/null
    tmux_cmd list-keys -T root C-h | grep -F 'select-pane -L' >/dev/null
    tmux_cmd list-keys -T root C-j | grep -F 'select-pane -D' >/dev/null
    tmux_cmd list-keys -T root C-k | grep -F 'select-pane -U' >/dev/null
    tmux_cmd list-keys -T root C-l | grep -F 'select-pane -R' >/dev/null
    tmux_cmd list-keys -T root 'C-\' | grep -F 'select-pane -l' >/dev/null
    tmux_cmd list-keys -T copy-mode-vi C-h | grep -F 'select-pane -L' >/dev/null
    tmux_cmd list-keys -T copy-mode-vi C-j | grep -F 'select-pane -D' >/dev/null
    tmux_cmd list-keys -T copy-mode-vi C-k | grep -F 'select-pane -U' >/dev/null
    tmux_cmd list-keys -T copy-mode-vi C-l | grep -F 'select-pane -R' >/dev/null
    tmux_cmd list-keys -T copy-mode-vi 'C-\' | grep -F 'select-pane -l' >/dev/null
    tmux_cmd list-keys -T prefix v | grep -F 'copy-mode' >/dev/null
    tmux_cmd list-keys -T prefix P | grep -F 'paste-buffer' >/dev/null
    tmux_cmd list-keys -T prefix F | grep -F 'tmux-fzf/main.sh' >/dev/null
    tmux_cmd list-keys -T prefix C-y | grep -F 'display-popup -E -d "#{pane_current_path}" -h "90%" -w "90%" yazi' >/dev/null
    tmux_cmd list-keys -T prefix C-t | grep -F 'display-popup -E -d "#{pane_current_path}" -h "80%" -w "80%" "nu --login --interactive"' >/dev/null
    tmux_cmd list-keys -T prefix C-g | grep -F 'display-popup -E -d "#{pane_current_path}" -h "90%" -w "90%" lazygit' >/dev/null
    tmux_cmd list-keys -T prefix e | grep -F 'display-menu -T "#[align=centre]Config"' >/dev/null
    tmux_cmd list-keys -T prefix d | grep -F 'detach-client' >/dev/null
    tmux_cmd list-keys -T root M-y | grep -F 'display-popup -E -d "#{pane_current_path}" -h "90%" -w "90%" yazi' >/dev/null
    tmux_cmd list-keys -T root M-t | grep -F 'display-popup -E -d "#{pane_current_path}" -h "80%" -w "80%" "nu --login --interactive"' >/dev/null
    tmux_cmd list-keys -T root M-g | grep -F 'display-popup -E -d "#{pane_current_path}" -h "90%" -w "90%" lazygit' >/dev/null
    tmux_cmd list-keys -T root M-e | grep -F 'display-menu -T "#[align=centre]Config"' >/dev/null
    if tmux_cmd list-keys -T prefix H >/dev/null 2>&1 || tmux_cmd list-keys -T harpoon >/dev/null 2>&1; then
        echo "Harpoon bindings must not be present." >&2
        exit 1
    fi

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

# Version control

[no-cd]
[doc('Validate Git config')]
git:
    git config --file "$PWD/dotfiles/.config/git/config" --list >/dev/null

# Coding agents

[no-cd]
[doc('Validate Kimi config')]
kimi:
    KIMI_CODE_HOME="$PWD/dotfiles/.config/kimi-code" kimi doctor

[no-cd]
[doc('Validate OpenCode config')]
opencode:
    OPENCODE_CONFIG_DIR="$PWD/dotfiles/.config/opencode" opencode debug config --pure >/dev/null

[no-cd]
[doc('Validate Claude config')]
claude:
    CLAUDE_CONFIG_DIR="$PWD/dotfiles/.config/claude" claude doctor

[no-cd]
[doc('Validate Codex config')]
codex:
    CODEX_HOME="$PWD/dotfiles/.config/codex" codex doctor
