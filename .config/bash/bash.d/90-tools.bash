# ~/.config/bash/bash.d/90-tools.sh
# ==============================================
# Bash Tool Initializations:
# starship: https://github.com/starship/starship
# zoxide: https://github.com/ajeetdsouza/zoxide
# fzf: https://github.com/junegunn/fzf
# direnv: https://github.com/direnv/direnv
# carapace: https://github.com/rsteube/carapace
# ==============================================

# Cache directory for initialization scripts
# Speeds up shell startup by avoiding `cmd init bash` calls on every session
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash/init"
[ -d "$CACHE_DIR" ] || mkdir -p "$CACHE_DIR"

# _bash_eval_cache
# Description: Caches the output of initialization commands to speed up startup.
# Usage: _bash_eval_cache "command_name" "init_command"
_bash_eval_cache() {
    local cmd_name="$1"
    local cmd_exec="$2"
    local cache_file="$CACHE_DIR/${cmd_name}.bash"
    local bin_path

    bin_path=$(command -v "$cmd_name")
    # If binary is not installed, skip
    [ -z "$bin_path" ] && return

    # Regenerate cache if file is missing OR binary is newer than cache
    if [ ! -f "$cache_file" ] || [ "$bin_path" -nt "$cache_file" ]; then
        eval "$cmd_exec" > "$cache_file"
    fi
    source "$cache_file"
}

# Starship Prompt (Fast & Customizable)
command -v starship >/dev/null 2>&1 && _bash_eval_cache "starship" "starship init bash"

# Zoxide (Smart directory jumper, replaces cd)
command -v zoxide >/dev/null 2>&1 && _bash_eval_cache "zoxide" "zoxide init bash"

# fzf (A command-line fuzzy finder )
command -v fzf >/dev/null 2>&1 && _bash_eval_cache "fzf" "fzf --bash"

# Direnv (Environment switcher per directory)
command -v direnv >/dev/null 2>&1 && _bash_eval_cache "direnv" "direnv hook bash"

# Carapace (Shell Completion Engine)
if command -v carapace >/dev/null 2>&1; then
    export CARAPACE_ENV=0
    export CARAPACE_BRIDGES='bash'
    # Remove the first line that exports PATH because Carapace generates an incorrect Windows-style PATH
    _bash_eval_cache "carapace" "carapace _carapace | sed '1{/^export PATH=/d}'"
fi
