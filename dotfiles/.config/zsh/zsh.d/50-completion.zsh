# Use the completion dump prepared by `mise run setup:shell`.

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZCOMP_DUMP="$ZSH_CACHE_DIR/zcompdump"
ZCOMP_CACHE="$ZSH_CACHE_DIR/zcompcache"

autoload -Uz compinit
if [[ -r "$ZCOMP_DUMP" ]]; then
  compinit -C -d "$ZCOMP_DUMP"
else
  # Without compinit, compdef is undefined and the generated Carapace and FZF scripts fail. Run the slow full scan
  # once; it writes the dump, so later sessions take the fast path.
  print -u2 -- 'zsh completion cache missing; building it now (or run: mise run setup:shell)'
  mkdir -p "$ZSH_CACHE_DIR"
  compinit -d "$ZCOMP_DUMP"
fi

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZCOMP_CACHE"
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS:-}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format '%F{yellow} %d %f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'
