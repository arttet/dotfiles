# Shared login environment for Bash and Zsh.

export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en_US.UTF-8}"

_dotfiles_prepend_path() {
  case ":${PATH:-}:" in
  *":$1:"*) ;;
  *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

_dotfiles_prepend_path "$HOME/.local/bin"
_dotfiles_prepend_path "$HOME/.local/share/mise/shims"
export PATH
unset -f _dotfiles_prepend_path

export EDITOR="${EDITOR:-hx}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R -M -i -j.5 --shift 5}"

export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml}"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=60% --layout=reverse --border --cycle --inline-info --color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa --color=fg+:#cdd6f4,bg+:#313244,hl+:#89dceb --color=info:#cba6f7,prompt:#89b4fa,pointer:#f5c2e7 --color=marker:#a6e3a1,spinner:#cba6f7,header:#6c7086 --bind=ctrl-/:toggle-preview --bind=ctrl-u:preview-half-page-up --bind=ctrl-d:preview-half-page-down}"
export FZF_CTRL_T_COMMAND="${FZF_CTRL_T_COMMAND:-fd --type f --hidden --follow --exclude .git}"
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:---preview='bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:50%:wrap}"
export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS:---exact}"
export FZF_ALT_C_COMMAND="${FZF_ALT_C_COMMAND:-fd --type d --hidden --follow --exclude .git}"
export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:---preview='eza --tree --level=2 --icons --color=always {}'}"

export BAT_CONFIG_PATH="${BAT_CONFIG_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/bat/config}"
export GH_CONFIG_DIR="${GH_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/gh}"
export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/config}"
export YAZI_CONFIG_HOME="${YAZI_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/yazi}"
export WAKATIME_HOME="${WAKATIME_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/wakatime}"
export CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/claude}"
export CODEX_HOME="${CODEX_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/codex}"
export KIMI_CODE_HOME="${KIMI_CODE_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/kimi-code}"
