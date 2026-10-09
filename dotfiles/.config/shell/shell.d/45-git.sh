# Git shortcuts and interactive selectors.

gcm() {
  [ "$#" -eq 1 ] || {
    printf 'usage: gcm message\n' >&2
    return 2
  }
  git add -A && git commit -m "$1"
}

gcp() {
  [ "$#" -eq 1 ] || {
    printf 'usage: gcp message\n' >&2
    return 2
  }
  git add -A && git commit -m "$1" && git push
}

gundo() {
  _dotfiles_confirm "${1:-}" 'Move HEAD back one commit and keep the changes staged?' || return 1
  git reset --soft HEAD~1
}

gst() {
  git status --short --branch
}

gadd() {
  git ls-files --modified --others --exclude-standard -z |
    fzf --read0 --print0 --multi --header 'Select files to stage' |
    while IFS= read -r -d '' _dotfiles_file; do
      git add -- "$_dotfiles_file" || exit
    done
}

grest() {
  _dotfiles_confirm "${1:-}" 'Discard selected unstaged changes?' || return 1
  git diff --name-only -z |
    fzf --read0 --print0 --multi --header 'Select files to restore' |
    while IFS= read -r -d '' _dotfiles_file; do
      git restore -- "$_dotfiles_file" || exit
    done
}

gbdel() {
  _dotfiles_force=""
  _dotfiles_yes=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
    --force) _dotfiles_force=-D ;;
    --yes) _dotfiles_yes=--yes ;;
    *)
      printf 'usage: gbdel [--force] [--yes]\n' >&2
      return 2
      ;;
    esac
    shift
  done
  _dotfiles_confirm "$_dotfiles_yes" 'Delete selected local branches?' || return 1
  _dotfiles_current=$(git branch --show-current)
  git for-each-ref --format='%(refname:short)' refs/heads |
    while IFS= read -r _dotfiles_branch; do
      case "$_dotfiles_branch" in
      main | master | dev | "$_dotfiles_current") ;;
      *) printf '%s\n' "$_dotfiles_branch" ;;
      esac
    done |
    fzf --multi --header 'Select branches to delete' |
    while IFS= read -r _dotfiles_branch; do
      if [ -n "$_dotfiles_force" ]; then
        git branch -D -- "$_dotfiles_branch" || exit
      else
        git branch -d -- "$_dotfiles_branch" || exit
      fi
    done
  unset _dotfiles_force _dotfiles_yes _dotfiles_current
}

gcob() {
  _dotfiles_branch=$(git branch --all --format='%(refname:short)' |
    grep -v '^origin/HEAD$' |
    fzf --preview 'git log --oneline --graph --color=always --max-count=20 {}')
  [ -n "$_dotfiles_branch" ] || return 1
  git switch "${_dotfiles_branch#origin/}"
  unset _dotfiles_branch
}

gdf() {
  git diff --name-only -z |
    fzf --read0 --print0 --header 'Select a diff to edit' |
    while IFS= read -r -d '' _dotfiles_file; do
      "${EDITOR:-hx}" -- "$_dotfiles_file"
    done
}

gll() {
  git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset' "$@" |
    fzf --ansi --no-sort --reverse --preview 'git show --color=always {2}' --bind 'ctrl-s:toggle-sort'
}
