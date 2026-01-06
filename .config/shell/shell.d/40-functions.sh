# ~/.config/shell/shell.d/40-functions.sh
# ==============================================
# Functions (POSIX-compliant)
# ==============================================

# ==============================================
# Core Utilities & Archive Management Functions (POSIX-compliant)
# Dependencies: tar, unzip, 7z, unrar, bunzip2
# ==============================================

# -------------------------------------------------------------------
# Shell Management
# -------------------------------------------------------------------

# reload
# Description: Reloads the current shell configuration by exec-ing the shell again.
# Usage: reload
reload() {
    echo "Reloading shell ($SHELL)..."
    exec "$SHELL"
}

# -------------------------------------------------------------------
# Directory Operations
# -------------------------------------------------------------------

# take
# Description: Creates a directory and immediately changes into it.
# Usage: take <directory>
# Note: Handled natively by Zsh (plugin), this is for Bash/others.
if ! command -v take >/dev/null 2>&1; then
    take() {
        [ $# -eq 0 ] && { echo "Usage: take <dir> [<dir> ...]"; return 1; }
        for dir in "$@"; do
            case "$OSTYPE" in
                msys*|cygwin*) dir=$(printf '%s\n' "$dir" | sed -E 's|^([A-Za-z]):\\|/\L\1/|; s|\\|/|g') ;;
            esac
            mkdir -p "$dir" && cd "$dir" || return 1
        done
        printf "\033[0;32m📂 Entered: \033[1;32m$PWD\033[0m\n"
    }
fi

# scratch
# Description: Creates a temporary directory in /tmp and cd's into it.
# Usage: scratch
scratch() {
    dir=$(mktemp -d)
    cd "$dir" || return 1
    echo "⚡ Temporary workspace: $dir"
    echo "   (Use 'rm -rf .' when done)"
}

# -------------------------------------------------------------------
# File Operations
# -------------------------------------------------------------------

# bak
# Description: Creates a backup of the specified file(s) with a timestamp.
# Usage: bak <filename>
bak() {
    for file in "$@"; do
        [ ! -e "$file" ] && continue
        cp -r "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)" && echo "📦 Backup created for $file"
    done
}

# unbak
# Description: Restores the most recent backup of the specified file.
# Usage: unbak <filename>
unbak() {
    [ -z "$1" ] && return 1
    latest=$(ls -t "${1}.bak."* 2>/dev/null | head -1)
    [ -n "$latest" ] && cp -r "$latest" "$1" && echo "♻️  Restored from: $latest"
}

# extract
# Description: Universal extractor for various archive formats.
# Usage: extract <archive_file>
extract() {
    [ -f "$1" ] || return 1
    case "$1" in
        *.tar.bz2)   tar xvjf "$1" ;;
        *.tar.gz)    tar xvzf "$1" ;;
        *.bz2)       bunzip2 "$1" ;;
        *.rar)       unrar x "$1" ;;
        *.gz)        gunzip "$1" ;;
        *.tar)       tar xvf "$1" ;;
        *.tbz2)      tar xvjf "$1" ;;
        *.tgz)       tar xvzf "$1" ;;
        *.zip)       unzip "$1" ;;
        *.Z)         uncompress "$1" ;;
        *.7z)        7z x "$1" ;;
        *)           echo "Unknown format" ;;
    esac
}

# -------------------------------------------------------------------
# Path Utilities
# -------------------------------------------------------------------

# paths
# Description: Pretty-prints the PATH environment variable, one entry per line.
# Usage: paths
paths() {
    echo "$PATH" | tr -s ':;' '\n'
}

# pconv
# Description: Converts paths between Windows and POSIX formats.
# Usage: pconv <path>
pconv() {
    [ -z "$1" ] && { echo "Usage: pconv <path>"; return 1; }
    if command -v cygpath >/dev/null 2>&1; then
        [[ "$1" == [A-Za-z]:* ]] || [[ "$1" == *\\* ]] && cygpath -u "$1" || cygpath -w "$1"
    else
        case "$1" in
            [A-Za-z]:*) echo "$1" | sed -E 's|^([A-Za-z]):|/\L\1|; s|\\|/|g' ;;
            *)          echo "$1" | sed -E 's|^/([a-z])|\1:|; s|/|\\|g' ;;
        esac
    fi
}

# cpw
# Description: Copies the current or specified path to the clipboard in Windows format.
# Usage: cpw [path]
cpw() {
    path="${1:-$PWD}"
    if command -v cygpath >/dev/null 2>&1; then
        winpath=$(cygpath -w "$path")
    else
        winpath=$(echo "$path" | sed -E 's|^/([a-z])|\1:|; s|/|\\|g')
    fi
    if command -v clip.exe >/dev/null 2>&1; then
        echo -n "$winpath" | clip.exe
        echo "📋 Copied Windows path: $winpath"
    else
        echo "$winpath"
    fi
}

# cpl
# Description: Copies the current or specified path to the clipboard in POSIX format.
# Usage: cpl [path]
cpl() {
    path="${1:-$PWD}"
    if command -v cygpath >/dev/null 2>&1; then
        posixpath=$(cygpath -u "$path")
    else
        posixpath=$(echo "$path" | sed -E 's|^([A-Za-z]):|/\L\1|; s|\\|/|g')
    fi
    if command -v clip.exe >/dev/null 2>&1; then
        echo -n "$posixpath" | clip.exe
        echo "📋 Copied POSIX path: $posixpath"
    else
        echo "$posixpath"
    fi
}

# -------------------------------------------------------------------
# Notes
# -------------------------------------------------------------------

# note
# Description: Appends a note to a daily markdown file in XDG_DATA_HOME/notes.
# Usage: note "This is a note"
note() {
    local note_dir="${XDG_DATA_HOME:-$HOME/.local/share}/notes"
    local note_file="$note_dir/$(date +%Y-%m-%d).md"

    mkdir -p "$note_dir"

    if [ ! -f "$note_file" ]; then
        echo "# Notes for $(date +%Y-%m-%d)" > "$note_file"
        echo "" >> "$note_file"
    fi

    echo "### $(date '+%H:%M:%S')" >> "$note_file"
    echo "$*" >> "$note_file"
    echo "" >> "$note_file"

    printf "\033[0;32m📝 Note added to: \033[1;32m$note_file\033[0m\n"
}

# ==============================================
# Navigation & File Operation Functions (POSIX-compliant)
# Dependencies: yazi
# ==============================================

# Yazi Wrapper
# Changes directory after Yazi quits
y() {
    tmp="${TMPDIR:-/tmp}/yazi-cwd.$$"
    yazi "$@" --cwd-file="$tmp"
    if [ -f "$tmp" ]; then
        cwd=$(cat "$tmp" 2>/dev/null)
        rm -f "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd "$cwd"
    fi
}
