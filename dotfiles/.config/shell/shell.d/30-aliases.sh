# Navigation and project shortcuts shared by Bash and Zsh.

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

alias m='mise'
alias j='just'
alias n='nvim'

alias cb='cargo build'
alias cbr='cargo build --release'
alias cr='cargo run'
alias crr='cargo run --release'
alias ct='cargo test'
alias cf='cargo fmt'
alias ca='cargo add'
alias caa='cargo add --dev'
alias cdoc='cargo doc --open'

alias nb='npm run build'
alias ns='npm start'
alias nt='npm test'
alias ni='npm install'

alias pi='pip install'
alias pu='pip uninstall'
alias pl='pip list'
alias pf='pip install -e .'

# Keep standard command semantics except for the explicitly chosen ls replacement, and only when eza exists.
command -v eza >/dev/null 2>&1 && alias ls='eza --icons'
