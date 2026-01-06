# ~/.config/shell/shell.d/44-system.sh
# ==============================================
# System Management & Maintenance Functions (POSIX-compliant)
# Dependencies: fzf, procs (optional), package managers
# ==============================================

# fkill
# Description: Interactively select and kill a process using fzf.
# Usage: fkill
fkill() {
    if command -v procs >/dev/null; then
        pid=$(procs | fzf --header-lines=1 --no-preview --header "🔥 SELECT PROCESS TO KILL" | awk '{print $1}')
    else
        pid=$(ps aux | fzf --header-lines=1 --no-preview --header "🔥 SELECT PROCESS TO KILL" | awk '{print $2}')
    fi
    [ -n "$pid" ] && kill -9 "$pid" && printf "\033[0;31m💀 Killed PID: \033[1;31m$pid\033[0m\n"
}

# cleanup
# Description: Performs system maintenance and cleanup for various package managers
#              and tools (apt, brew, cargo, go, docker) if they are installed.
# Usage: cleanup
cleanup() {
    printf "\033[0;33m🧹 Starting System Cleanup...\033[0m\n"

    if command -v apt >/dev/null; then
        printf "  📦 \033[0;34mAPT:\033[0m Autoremove & Clean... "
        sudo apt autoremove -y >/dev/null 2>&1 && sudo apt clean >/dev/null 2>&1 && echo "✅" || echo "❌"
    fi

    if command -v brew >/dev/null; then
        printf "  🍺 \033[0;34mHomebrew:\033[0m Cleanup... "
        brew cleanup >/dev/null 2>&1 && echo "✅" || echo "❌"
    fi

    if command -v cargo-cache >/dev/null; then
        printf "  🦀 \033[0;34mCargo:\033[0m Cache Clean... "
        cargo cache -a >/dev/null 2>&1 && echo "✅" || echo "❌"
    fi

    if command -v go >/dev/null; then
        printf "  🐹 \033[0;34mGo:\033[0m Cleaning Cache... "
        go clean -cache -testcache -fuzzcache >/dev/null 2>&1 && echo "✅" || echo "❌"
    fi

    if command -v docker >/dev/null; then
        printf "  🐳 \033[0;34mDocker:\033[0m System Prune... "
        docker system prune -af --volumes >/dev/null 2>&1 && echo "✅" || echo "❌"
    fi

    printf "\033[0;32m✨ Cleanup Completed!\033[0m\n"
}
