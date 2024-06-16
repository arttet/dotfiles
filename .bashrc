# ~/.bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# User specific (bash & zsh) aliases, functions and etc.
for file in ~/.shell/{path,exports,functions,aliases,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;

unset file;

# User specific (only bash) aliases, functions and etc.
if [ -d ~/.bashrc.d ]; then
    for file in ~/.bashrc.d/*; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
    done
fi

unset file;

# Bash prompt: oh-my-posh (see https://ohmyposh.dev)
if [ -x "$(command -v oh-my-posh)" ]; then
    eval "$(oh-my-posh init bash)"
    eval "$(oh-my-posh init bash --config ${HOME}/.config/oh-my-posh/themes/jandedobbeleer.omp.json)"
fi
