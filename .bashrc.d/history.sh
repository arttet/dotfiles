###
# History file configuration
###

# Set how many history commands will be stored in memory.
export HISTSIZE=50000
# Set how many history commands will be stored on disk.
export SAVEHIST=100000
export HISTTIMEFORMAT='%F %T - '
export HISTFILE="${HOME}/.bash_history"
# ignorespace — ignore commands that start with a space
# ignoredups — ignore duplicate commands
# ignoreboth — both of the ab
export HISTCONTROL=ignoreboth
export HISTIGNORE="clear:history:exit:date:* --help"
# Append commands to history file immediately (not at end of session).
export PROMPT_COMMAND='history -a'

###
# History command configuration
###

# Append (rather than overwrite) history.
shopt -s histappend
