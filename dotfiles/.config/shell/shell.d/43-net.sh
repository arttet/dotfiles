# ~/.config/shell/shell.d/43-net.sh
# ==============================================
# Network Operations Functions (POSIX-compliant)
# Dependencies: curl, wget, bat
# ==============================================

# cht
# Description: Queries cht.sh for programming cheat sheets.
# Usage: cht <language/command> [query]
cht() {
    query=$(echo "$@" | tr ' ' '+')
    curl -fsSL "https://cht.sh/$query" | bat --style=plain --paging=never
}

# weather
# Description: Fetches weather information from wttr.in.
# Usage: weather <city>
weather() {
    if [ -z "$1" ]; then
        printf "\033[0;31m❌ Error: City name is required.\033[0m\n"
        printf "Usage: weather <city>\n"
        return 1
    fi
    local city="$1"
    # City names should only contain alphanumeric, space, hyphen
    if ! [[ "$city" =~ ^[a-zA-Z\ \-]+$ ]]; then
        printf "\033[0;31m❌ Invalid city name\033[0m\n"
        return 1
    fi
    printf "\033[0;36m🌤️  Fetching weather for: \033[1;36m$city\033[0m\n"
    curl -fsSL "https://wttr.in/$(printf '%s\n' "$city" | sed 's/ /+/g')"
}

# download
# Description: Downloads a file/archive, verifies checksum (if provided),
#              extracts it (if archive), and attempts to install the binary to ~/.local/bin.
# Usage: download <url> [name] [checksum]
# Security: Always provide a checksum for external binaries.
download() {
    [ $# -eq 0 ] && { echo "Usage: download <url> [name] [checksum]"; return 1; }

    local url="$1"
    local wanted_name=""
    local expected_sha256=""

    # Argument parsing logic
    if [ $# -eq 2 ]; then
        # If 2 args, check if the second is a checksum (SHA256: 64 hex chars)
        if [ ${#2} -eq 64 ] && echo "$2" | tr -d '[:xdigit:]' | grep -q '^$'; then
            expected_sha256="$2"
        else
            wanted_name="$2"
        fi
    elif [ $# -ge 3 ]; then
        # If 3 or more args, follow the order: [name] [checksum]
        wanted_name="$2"
        expected_sha256="$3"
    fi

    local target_dir="${HOME}/.local/bin"
    local tmp_dir
    tmp_dir=$(mktemp -d) || return 1

    # Robust cleanup
    trap 'rm -rf "$tmp_dir"' EXIT

    local filename=$(basename "$url")

    printf "\033[0;34m⬇️  Downloading \033[1;34m$filename\033[0m...\n"
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$url" -o "$tmp_dir/$filename"; then
            printf "\033[0;31m❌ Download failed.\033[0m\n"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q "$url" -O "$tmp_dir/$filename"; then
            printf "\033[0;31m❌ Download failed.\033[0m\n"
            return 1
        fi
    else
        printf "\033[0;31m❌ Error: curl or wget not found.\033[0m\n"
        return 1
    fi

    pushd "$tmp_dir" > /dev/null 2>&1 || return 1

    # Security Verification
    if [ -n "$expected_sha256" ]; then
        printf "🔒 Verifying checksum... "
        local actual_sha256=""
        if command -v sha256sum >/dev/null 2>&1; then
            actual_sha256=$(sha256sum "$filename" | awk '{print $1}')
        elif command -v shasum >/dev/null 2>&1; then
            actual_sha256=$(shasum -a 256 "$filename" | awk '{print $1}')
        fi

        if [ "$actual_sha256" = "$expected_sha256" ]; then
            printf "\033[0;32m✅ Verified\033[0m\n"
        else
            printf "\033[0;31m❌ Checksum Mismatch!\033[0m\n"
            printf "   Expected: %s\n" "$expected_sha256"
            printf "   Actual:   %s\n" "$actual_sha256"
            return 1
        fi
    else
        printf "\033[0;33m⚠️  Security Warning: No checksum provided. Verification skipped.\033[0m\n"
    fi

    # Extract if archive using existing 'extract' function
    local is_archive=0
    case "$filename" in
        *.tar.bz2|*.tar.gz|*.bz2|*.rar|*.gz|*.tar|*.tbz2|*.tgz|*.zip|*.Z|*.7z)
            printf "\033[0;33m📦 Extracting archive...\033[0m\n"
            extract "$filename" >/dev/null 2>&1
            rm -f "$filename"
            is_archive=1
            # Debug: show what was extracted
            printf "\033[0;36m   Contents:\033[0m\n"
            if command -v fd >/dev/null 2>&1; then
                fd --type f . | head -10 | sed 's/^/     /'
            else
                ls -la 2>/dev/null | grep -v '^d' | head -10 | tail -5 | awk '{print "     " $NF}'
            fi
            ;;
    esac

    printf "\033[0;35m🔍 Looking for executable...\033[0m\n"

    local found_path=""

    # Use fd if available (Windows-friendly), fallback to glob patterns
    if command -v fd >/dev/null 2>&1; then
        printf "\033[0;36m   Using fd for search...\033[0m\n"

        # Look for explicit filename
        if [ -n "$wanted_name" ]; then
            found_path=$(fd --type f "^$(basename "$wanted_name")$" 2>/dev/null | head -n 1)
            [ -n "$found_path" ] && printf "\033[0;36m   ✓ Found exact match: $found_path\033[0m\n"
        fi

        # Search for .exe files
        if [ -z "$found_path" ]; then
            found_path=$(fd --type f '\.exe$' 2>/dev/null | head -n 1)
            [ -n "$found_path" ] && printf "\033[0;36m   ✓ Found .exe: $found_path\033[0m\n"
        fi

        # Search by base name
        if [ -z "$found_path" ] && [ -n "$wanted_name" ]; then
            base_name=$(echo "$wanted_name" | sed 's/\..*//')
            found_path=$(fd --type f "$base_name" 2>/dev/null | head -n 1)
            [ -n "$found_path" ] && printf "\033[0;36m   ✓ Found by name: $found_path\033[0m\n"
        fi

        # Any file
        if [ -z "$found_path" ]; then
            found_path=$(fd --type f . 2>/dev/null | head -n 1)
            [ -n "$found_path" ] && printf "\033[0;36m   ✓ Found fallback: $found_path\033[0m\n"
        fi
    else
        printf "\033[0;36m   Using glob patterns for search...\033[0m\n"

        # Look for explicit file in current dir first
        if [ -f "$wanted_name" ] && [ -n "$wanted_name" ]; then
            found_path="$wanted_name"
            printf "\033[0;36m   ✓ Found: $found_path\033[0m\n"
        fi

        # Search for .exe files in current directory
        if [ -z "$found_path" ]; then
            for file in *.exe; do
                if [ -f "$file" ]; then
                    found_path="$file"
                    printf "\033[0;36m   ✓ Found .exe: $found_path\033[0m\n"
                    break
                fi
            done
        fi

        # Search subdirectories for .exe files
        if [ -z "$found_path" ]; then
            for subdir in */; do
                [ -d "$subdir" ] || continue
                for file in "$subdir"*.exe; do
                    if [ -f "$file" ]; then
                        found_path="$file"
                        printf "\033[0;36m   ✓ Found .exe in subdir: $found_path\033[0m\n"
                        break 2
                    fi
                done
            done
        fi

        # Match wanted_name in current dir
        if [ -z "$found_path" ] && [ -n "$wanted_name" ]; then
            base_name=$(echo "$wanted_name" | sed 's/\..*//')
            for file in *"$base_name"*; do
                if [ -f "$file" ]; then
                    found_path="$file"
                    printf "\033[0;36m   ✓ Found matching: $found_path\033[0m\n"
                    break
                fi
            done
        fi

        # Try subdirectories for matching name
        if [ -z "$found_path" ] && [ -n "$wanted_name" ]; then
            base_name=$(echo "$wanted_name" | sed 's/\..*//')
            for subdir in */; do
                [ -d "$subdir" ] || continue
                for file in "$subdir"*"$base_name"*; do
                    if [ -f "$file" ]; then
                        found_path="$file"
                        printf "\033[0;36m   ✓ Found in subdir: $found_path\033[0m\n"
                        break 2
                    fi
                done
            done
        fi

        # Any file in current dir (fallback)
        if [ -z "$found_path" ]; then
            for file in *; do
                if [ -f "$file" ]; then
                    found_path="$file"
                    printf "\033[0;36m   ✓ Found fallback: $found_path\033[0m\n"
                    break
                fi
            done
        fi
    fi

    # Fallback to original filename if not archived
    if [ -z "$found_path" ] && [ "$is_archive" -eq 0 ]; then
        found_path="$filename"
    fi

    if [ -n "$found_path" ]; then
        mkdir -p "$target_dir"
        local final_name=""

        if [ -n "$wanted_name" ]; then
            final_name="$wanted_name"
        else
            final_name=$(basename "$found_path")
        fi

        # Check if .exe and add extension if needed
        case "$found_path" in
            *.exe)
                if ! echo "$final_name" | grep -q '\.exe$'; then
                    final_name="${final_name}.exe"
                fi
                ;;
        esac

        mv "$found_path" "$target_dir/$final_name"
        chmod +x "$target_dir/$final_name"
        printf "\033[0;32m✅ Installed to: \033[1;32m$target_dir/$final_name\033[0m\n"
    else
        printf "\033[0;31m❌ Could not find executable.\033[0m\n"
    fi

    popd > /dev/null
}
