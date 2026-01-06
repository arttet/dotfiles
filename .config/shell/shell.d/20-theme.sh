# ~/.config/shell/20-theme.sh
# ==========================================================
# System color scheme detection & theme propagation
#
# Optimized for Speed:
#   - NEVER calls external processes (PowerShell/etc) during shell init.
#   - Reads preference from a static file.
#   - "sync_theme" command can be run manually to pull from OS.
# ==========================================================

THEME_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/shell_theme"

# Get current system color scheme (Slow, calls OS APIs)
# Output: light | dark
_detect_os_theme() {
    local detected="light"

    # macOS
    if [ "$(uname -s)" = "Darwin" ] && command -v defaults >/dev/null 2>&1; then
        if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
            detected="dark"
        fi
    # GNOME
    elif command -v gsettings >/dev/null 2>&1; then
        local gnome_scheme
        gnome_scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
        case "$gnome_scheme" in
            *dark*)  detected="dark" ;;
            *light*) detected="light" ;;
        esac
    # Windows (PowerShell) - SLOW!
    elif [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
        if command -v powershell.exe >/dev/null 2>&1; then
            local ps_result
            ps_result=$(powershell.exe -NoProfile -Command "(Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme" 2>/dev/null | tr -d '\r\n ')
            [ "$ps_result" = "0" ] && detected="dark" || detected="light"
        fi
    fi

    echo "$detected"
}

# Set system color scheme (Write to OS and local cache)
set_theme() {
    local mode="$1"

    case "$mode" in
        light|dark) ;;
        *)
            echo "Usage: set_theme [light|dark] | sync_theme" >&2
            return 1
            ;;
    esac

    # Update local cache immediately for speed
    mkdir -p "$(dirname "$THEME_FILE")"
    echo "$mode" > "$THEME_FILE"

    # Apply to current session
    apply_theme "$mode"

    # Propagate to OS (Optional, can be slow, run in background if possible)
    # We do this strictly sequentially here to ensure consistency, but usually
    # users care about the shell changing instantly.

    # macOS
    if [ "$(uname -s)" = "Darwin" ] && command -v osascript >/dev/null 2>&1; then
        osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to $( [ "$mode" = "dark" ] && echo "true" || echo "false" )" 2>/dev/null
    fi

    # GNOME
    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode" 2>/dev/null
        gsettings set org.gnome.desktop.interface gtk-theme "$( [ "$mode" = "dark" ] && echo "Adwaita-dark" || echo "Adwaita" )" 2>/dev/null
    fi

    # Windows
    if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
        if command -v powershell.exe >/dev/null 2>&1; then
            local val=1
            [ "$mode" = "dark" ] && val=0
            # Run in background to return control to user faster? No, let's keep it synchronous for set_theme.
            powershell.exe -NoProfile -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -Value $val; Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name SystemUsesLightTheme -Value $val" >/dev/null 2>&1
        fi
    fi

    echo "Theme set to: $mode"
}

# Sync with OS (Run this manually if you changed OS theme outside shell)
sync_theme() {
    echo "Detecting OS theme..."
    local os_theme
    os_theme=$(_detect_os_theme)
    set_theme "$os_theme"
}

# Apply theme to shell tools (Env vars, config files)
apply_theme() {
    local mode="$1"
    # Fallback if empty
    [ -z "$mode" ] && mode="dark"

    # Alacritty
    if command -v alacritty >/dev/null 2>&1; then
        local ALACRITTY_THEME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/themes"
        local ALACRITTY_THEME_FILE="$ALACRITTY_THEME_DIR/theme.toml"
        local ALACRITTY_THEME

        if [ "$mode" = "dark" ]; then
            ALACRITTY_THEME="catppuccin_mocha.toml"
        else
            ALACRITTY_THEME="catppuccin_latte.toml"
        fi

        # Convert path to Unix-style for TOML (works on all platforms)
        local ALACRITTY_THEME_PATH="$ALACRITTY_THEME_DIR/themes/$ALACRITTY_THEME"
        local ALACRITTY_THEME_PATH_UNIX
        ALACRITTY_THEME_PATH_UNIX=$(echo "$ALACRITTY_THEME_PATH" | sed 's|\\|/|g')

        # Generate theme.toml only if needed (saves IO)
        if [ ! -f "$ALACRITTY_THEME_FILE" ] || ! grep -q "$ALACRITTY_THEME" "$ALACRITTY_THEME_FILE"; then
            mkdir -p "$ALACRITTY_THEME_DIR"
            printf "[general]\nimport = [\"%s\"]\n" "$ALACRITTY_THEME_PATH_UNIX" > "$ALACRITTY_THEME_FILE"
        fi
    fi

    # bat
    if command -v bat >/dev/null 2>&1; then
        export BAT_THEME=$( [ "$mode" = "dark" ] && echo "Catppuccin Mocha" || echo "Catppuccin Latte" )
    fi

    # Vim/Neovim
    export VIM_BACKGROUND="$mode"
}

# Toggle between light and dark themes
toggle_theme() {
    local current
    if [ -f "$THEME_FILE" ]; then
        current=$(cat "$THEME_FILE")
    else
        current="dark"
    fi

    if [ "$current" = "dark" ]; then
        set_theme light
    else
        set_theme dark
    fi
}

# === FAST INIT ===
# Just read the file. No logic.
if [ -f "$THEME_FILE" ]; then
    apply_theme "$(cat "$THEME_FILE")"
else
    # First run: default to dark, don't auto-detect to save time.
    # User can run 'sync_theme' if they want.
    apply_theme "dark"
fi
