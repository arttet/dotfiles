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

# The loops read from process substitution so they run in the current shell under both Bash and Zsh. In a Zsh
# pipeline the last command runs in the current shell, so an `exit` there would close the terminal.
gadd() {
  _dotfiles_status=0
  while IFS= read -r -d '' _dotfiles_file; do
    git add -- "$_dotfiles_file" || {
      _dotfiles_status=$?
      break
    }
  done < <(git ls-files --modified --others --exclude-standard -z |
    fzf --read0 --print0 --multi --header 'Select files to stage')
  unset _dotfiles_file
  return "$_dotfiles_status"
}

grest() {
  _dotfiles_confirm "${1:-}" 'Discard selected unstaged changes?' || return 1
  _dotfiles_status=0
  while IFS= read -r -d '' _dotfiles_file; do
    git restore -- "$_dotfiles_file" || {
      _dotfiles_status=$?
      break
    }
  done < <(git diff --name-only -z |
    fzf --read0 --print0 --multi --header 'Select files to restore')
  unset _dotfiles_file
  return "$_dotfiles_status"
}

gbdel() {
  _dotfiles_delete=-d
  _dotfiles_yes=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
    --force) _dotfiles_delete=-D ;;
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
  _dotfiles_status=0
  while IFS= read -r _dotfiles_branch; do
    git branch "$_dotfiles_delete" -- "$_dotfiles_branch" || {
      _dotfiles_status=$?
      break
    }
  done < <(git for-each-ref --format='%(refname:short)' refs/heads |
    while IFS= read -r _dotfiles_candidate; do
      case "$_dotfiles_candidate" in
      main | master | dev | "$_dotfiles_current") ;;
      *) printf '%s\n' "$_dotfiles_candidate" ;;
      esac
    done |
    fzf --multi --header 'Select branches to delete')
  unset _dotfiles_delete _dotfiles_yes _dotfiles_current _dotfiles_branch
  return "$_dotfiles_status"
}

gcob() {
  _dotfiles_branch=$(git branch --all --format='%(refname:short)' |
    grep -v '^origin/HEAD$' |
    fzf --preview 'git log --oneline --graph --color=always --max-count=20 {}')
  [ -n "$_dotfiles_branch" ] || return 1
  git switch "${_dotfiles_branch#origin/}"
  unset _dotfiles_branch
}

# Select first, then start the editor on the terminal: inside a `while read` loop its stdin would be the pipe.
gdf() {
  _dotfiles_file=$(git diff --name-only | fzf --header 'Select a diff to edit') || return 1
  "${EDITOR:-hx}" -- "$_dotfiles_file" </dev/tty
  unset _dotfiles_file
}

gll() {
  git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr%Creset' "$@" |
    fzf --ansi --no-sort --reverse --preview 'git show --color=always {2}' --bind 'ctrl-s:toggle-sort'
}
