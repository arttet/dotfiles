# Bash history, navigation and interactive defaults.

export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTTIMEFORMAT='%F %T '
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE='ls:ll:la:cd:pwd:exit:clear:history:date:* --help'

shopt -s histappend cmdhist histverify checkwinsize expand_aliases
for _dotfiles_shopt in autocd cdspell dirspell globstar nocaseglob dotglob extglob nullglob; do
  shopt -s "$_dotfiles_shopt" 2>/dev/null || true
done
unset _dotfiles_shopt

_dotfiles_history_sync() {
  history -a
  history -n
}

case ";${PROMPT_COMMAND:-};" in
*';_dotfiles_history_sync;'*) ;;
*) PROMPT_COMMAND="_dotfiles_history_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
export PROMPT_COMMAND

set -o notify
set -o noclobber
set -o vi
