# ~/.config/zsh/zsh.d/50-completion.zsh
# ==============================================
# Zsh Completion Configuration
# ==============================================

ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

ZCOMP_DUMP="$ZSH_CACHE_DIR/zcompdump"
ZCOMP_CACHE="$ZSH_CACHE_DIR/zcompcache"
[[ -d "$ZCOMP_CACHE" ]] || mkdir -p "$ZCOMP_CACHE"

autoload -Uz compinit

# Initialize completion once per day for performance
# Checks modification time of the dump file
if [[ -n "$ZCOMP_DUMP"(#qN.m-1) ]]; then
    compinit -C -d "$ZCOMP_DUMP"
else
    compinit -d "$ZCOMP_DUMP"
fi

# -------------------------------------------------------------------
# Styles & Formatting
# -------------------------------------------------------------------
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZCOMP_CACHE"

# Interactive menu selection
zstyle ':completion:*:*:*:*:*' menu select

# Matcher: Case insensitive, partial matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colors: Use LS_COLORS
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Verbose output
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format '%F{yellow} %d %f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'
