# ~/.config/nushell/config.nu

# =============================================================================
# Core Configuration
# =============================================================================

$env.config.show_banner = false
$env.config.buffer_editor = (
    $env.EDITOR?
    | default ($env.VISUAL? | default "nvim")
)

# History
$env.config.history = {
    max_size: 100_000
    sync_on_enter: true
    file_format: "sqlite"
    isolation: false
}

# Completions
$env.config.completions = {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
        enable: true
        max_results: 100
    }
}

$env.config.shell_integration = {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: false
    osc133: true
    osc633: true
    reset_application_mode: true
}

# UI/UX
$env.config.table.mode = "rounded"
$env.config.ls.use_ls_colors = true
$env.config.rm.always_trash = true

# =============================================================================
# Modules
# =============================================================================

use modules/aliases.nu *
# use modules/theme.nu *

use modules/fzf.nu *
use modules/yazi.nu *
# use modules/git.nu *

# Tools Module
# Manage Starship, Zoxide, Carapace via 'tools init' and 'tools deinit'
use modules/tools.nu

# =============================================================================
# Initialization
# =============================================================================

# Apply Theme
# init_theme

# Detect Tmux
# init_tmux

# =============================================================================
# Keybindings
# =============================================================================

$env.config.keybindings = (
    $env.config.keybindings
    | append $FZF_EDIT_BINDING
    | append $FZF_CD_KEYBINDING
    | append $FZF_HISTORY_BINDING
)
