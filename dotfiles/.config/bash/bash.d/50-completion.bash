# Readline behavior; generated FZF and Carapace completion is loaded by 90-tools.

if [[ $- == *i* ]]; then
  bind 'set completion-ignore-case on'
  bind 'set show-all-if-ambiguous on'
  bind 'set colored-stats on'
  bind 'set visible-stats on'
  bind 'set mark-symlinked-directories on'
  bind 'set colored-completion-prefix on'
  bind 'set menu-complete-display-prefix on'
fi
