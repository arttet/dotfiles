# ~/.config/shell/profile.d/50-os.sh
# ==============================================
# OS-specific tweaks
# ==============================================

uname_s="$(uname -s)"

case "$uname_s" in
    Linux*)
        # --- Linux ---
        # Packet manager update alias
        if command -v apt >/dev/null 2>&1; then
            alias upgrade='sudo apt update && sudo apt upgrade -y'
        elif command -v pacman >/dev/null 2>&1; then
            alias upgrade='sudo pacman -Syu'
        fi

        # 'O' alias for opening current directory in GUI file manager
        if command -v nautilus >/dev/null 2>&1; then
            alias O='nautilus .'
        elif command -v xdg-open >/dev/null 2>&1; then
            alias O='xdg-open .'
        fi
        ;;
    Darwin*)
        # --- macOS ---
        if command -v brew >/dev/null 2>&1; then
            alias upgrade='brew update && brew upgrade'
        fi
        alias O='open .'
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # --- Windows (Git Bash / MSYS) ---
        if command -v winget.exe >/dev/null 2>&1; then
            alias upgrade='winget.exe upgrade --all'
        fi
        alias O='explorer.exe .'
        ;;
esac
