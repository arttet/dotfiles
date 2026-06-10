#!/bin/sh
# Wallpaper switcher for hyprpaper

WALLPAPER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/wallpapers"

# Find all image files in wallpaper directories
list_wallpapers() {
    (cd "$WALLPAPER_DIR" 2>/dev/null && fd -a -t f -e png -e jpg -e jpeg -e webp -e jxl | sort)
}

# Verify wallpaper path exists
resolve_path() {
    local fullpath="$1"
    if [ ! -f "$fullpath" ]; then
        echo "Wallpaper not found: ${fullpath}" >&2
        return 1
    fi
    echo "$fullpath"
}

# Get current monitor name (dynamically detect, fallback to eDP-1)
get_monitor() {
    hyprctl monitors | awk '/Monitor/ {print $2; exit}' || echo "eDP-1"
}

# Set wallpaper via hyprctl IPC
set_wallpaper() {
    local relpath="$1"
    local abspath
    abspath=$(resolve_path "$relpath") || return 1
    local monitor
    monitor=$(get_monitor)

    # Update active symlink for persistence across restarts
    ln -sf "$abspath" "${WALLPAPER_DIR}/active"

    # Apply via IPC
    hyprctl hyprpaper wallpaper "${monitor}, ${abspath}, cover" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "IPC failed, wallpaper symlink updated but not applied live." >&2
        echo "Restart hyprpaper to see the change." >&2
        return 1
    fi
    echo "Wallpaper set: ${relpath}"
}

# Cycle to next wallpaper
cycle_next() {
    local current target
    current=$(readlink -f "${WALLPAPER_DIR}/active" 2>/dev/null)

    target=$(list_wallpapers | awk -v current="$current" '
        found { print; exit }
        $0 == current { found = 1 }
    ')

    if [ -z "$target" ]; then
        target=$(list_wallpapers | head -n 1)
    fi

    if [ -n "$target" ]; then
        set_wallpaper "$target"
    else
        echo "No wallpapers found." >&2
        return 1
    fi
}

# Random wallpaper
random_wallpaper() {
    local target
    target=$(list_wallpapers | awk 'BEGIN{srand()} {a[NR]=$0} END{if(NR>0) print a[int(rand()*NR)+1]}')
    if [ -n "$target" ]; then
        set_wallpaper "$target"
    else
        echo "No wallpapers found." >&2
        return 1
    fi
}

case "${1:-}" in
    list)
        list_wallpapers
        ;;
    set)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 set <collection>/<file>" >&2
            exit 1
        fi
        set_wallpaper "$2"
        ;;
    next)
        cycle_next
        ;;
    random)
        random_wallpaper
        ;;
    pick)
        local selected
        selected=$(list_wallpapers | walker -d -p "Wallpaper: " 2>/dev/null)
        if [ -n "$selected" ]; then
            set_wallpaper "$selected"
        else
            echo "No wallpaper selected." >&2
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {list|set <path>|next|random|pick}" >&2
        exit 1
        ;;
esac
