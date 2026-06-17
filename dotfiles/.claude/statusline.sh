#!/usr/bin/env bash
# Claude Code statusline: model, cwd, agent, git, PR, context pressure, tokens, rate limits, cost.
#
# Design:
# - One JSON parser process per render: jq/jaq + @sh + eval
# - No tput: Claude Code provides COLUMNS/LINES to statusline scripts
# - Git hot path uses one `git status --porcelain=v1 -b` call
# - Expensive git stash segment is opt-in
# - Works as both statusLine and subagentStatusLine
#
# shellcheck shell=bash
# Suppressions (all intentional):
#   SC2154 — locals are populated by `eval "$assignments"` from the JSON parser.
#   SC2016 — the jq/jaq program is single-quoted on purpose (no shell expansion).
#   SC1003 — the OSC-8 hyperlink terminator (\033\\) is a literal backslash.
# shellcheck disable=SC2154,SC2016,SC1003

# Do not use `set -e`: a statusline must degrade gracefully instead of disappearing.
set -o pipefail

input=$(cat)

# =============================================================================
# Configuration knobs
# =============================================================================

: "${CLAUDE_STATUSLINE_JSON_PARSER:=}" # jq | jaq | empty for auto
: "${CLAUDE_STATUSLINE_GIT:=1}"
: "${CLAUDE_STATUSLINE_SHOW_STASH:=0}" # extra git call; off by default
: "${CLAUDE_STATUSLINE_SHOW_CACHE:=0}" # noisy; enable when debugging cache
: "${CLAUDE_STATUSLINE_SHOW_COST:=1}"
: "${CLAUDE_STATUSLINE_SHOW_RATE:=1}"
: "${CLAUDE_STATUSLINE_SHOW_VIM:=1}"
: "${CLAUDE_STATUSLINE_SHOW_STYLE:=1}"
: "${CLAUDE_STATUSLINE_SHOW_SESSION:=1}"
: "${CLAUDE_STATUSLINE_FULL_MODEL:=1}"
: "${CLAUDE_STATUSLINE_PR_LINK:=1}"   # OSC-8 clickable PR link
: "${CLAUDE_STATUSLINE_MULTILINE:=0}" # 1 = two-line statusline
: "${CLAUDE_STATUSLINE_BAR_WIDTH:=10}"

cols=${COLUMNS:-120}

verbose=1
wide=0
compact=0

((cols < 100)) && verbose=0
((cols >= 140)) && wide=1
((cols < 80)) && compact=1

# =============================================================================
# Colors: Nord palette
# =============================================================================

if [[ -n "${NO_COLOR:-}" ]]; then
  BLUE=''
  GREEN=''
  YELLOW=''
  RED=''
  SUBTLE=''
  RESET=''
else
  BLUE='\033[38;2;136;192;208m'   # nord8
  GREEN='\033[38;2;163;190;140m'  # nord14
  YELLOW='\033[38;2;235;203;139m' # nord13
  RED='\033[38;2;191;97;106m'     # nord11
  SUBTLE='\033[38;2;76;86;106m'   # nord3
  RESET='\033[0m'
fi

SEP=" ${SUBTLE}│${RESET} "

# =============================================================================
# JSON parsing: one process only
# =============================================================================

json_parser_bin() {
  if [[ -n "$CLAUDE_STATUSLINE_JSON_PARSER" ]]; then
    printf '%s' "$CLAUDE_STATUSLINE_JSON_PARSER"
  elif command -v jaq >/dev/null 2>&1; then
    printf '%s' 'jaq'
  elif command -v jq >/dev/null 2>&1; then
    printf '%s' 'jq'
  else
    return 1
  fi
}

read_status_json() {
  local parser assignments

  if ! parser=$(json_parser_bin); then
    printf '%b' "${RED}Claude statusline: install jq or jaq${RESET}"
    exit 0
  fi

  # Values are shell-escaped by @sh. Variable names are hardcoded by this script.
  if ! assignments=$("$parser" -r '
    def sh($name; $v): "\($name)=\($v | tostring | @sh)";

    [
      sh("model"; .model.display_name // "Claude"),
      sh("model_id"; .model.id // ""),
      sh("dir"; .workspace.current_dir // .cwd // "~"),
      sh("project_dir"; .workspace.project_dir // ""),
      sh("transcript"; .transcript_path // ""),
      sh("version"; .version // ""),
      sh("session_id"; .session_id // ""),
      sh("session_name"; .session_name // ""),

      sh("added"; .cost.total_lines_added // 0),
      sh("removed"; .cost.total_lines_removed // 0),
      sh("cost"; .cost.total_cost_usd // 0),
      sh("duration_ms"; .cost.total_duration_ms // 0),
      sh("api_ms"; .cost.total_api_duration_ms // 0),

      sh("style"; .output_style.name // "default"),
      sh("exceeds_200k"; .exceeds_200k_tokens // false),

      sh("agent"; .agent.name // ""),
      sh("effort"; .effort.level // ""),
      sh("thinking"; .thinking.enabled // false),
      sh("vim_mode"; .vim.mode // ""),

      sh("ctx_pct"; ((.context_window.used_percentage // 0) | floor)),
      sh("ctx_size"; .context_window.context_window_size // 0),
      sh("in_tokens"; .context_window.total_input_tokens // 0),
      sh("out_tokens"; .context_window.total_output_tokens // 0),
      sh("cur_input"; .context_window.current_usage.input_tokens // 0),
      sh("cache_read"; .context_window.current_usage.cache_read_input_tokens // 0),
      sh("cache_write"; .context_window.current_usage.cache_creation_input_tokens // 0),

      sh("limit_5h_pct"; .rate_limits.five_hour.used_percentage // ""),
      sh("limit_5h_reset"; .rate_limits.five_hour.resets_at // ""),
      sh("limit_7d_pct"; .rate_limits.seven_day.used_percentage // ""),
      sh("limit_7d_reset"; .rate_limits.seven_day.resets_at // ""),

      sh("pr_number"; .pr.number // ""),
      sh("pr_url"; .pr.url // ""),
      sh("pr_state"; .pr.review_state // ""),

      sh("worktree"; .worktree.name // .workspace.git_worktree // ""),
      sh("worktree_branch"; .worktree.branch // ""),
      sh("original_branch"; .worktree.original_branch // ""),

      sh("repo_host"; .workspace.repo.host // ""),
      sh("repo_owner"; .workspace.repo.owner // ""),
      sh("repo_name"; .workspace.repo.name // "")
    ] | .[]
  ' <<<"$input" 2>/dev/null); then
    printf '%b' "${RED}Claude statusline: invalid JSON${RESET}"
    exit 0
  fi

  eval "$assignments"
}

# =============================================================================
# Formatting helpers
# =============================================================================

fmt_tokens() {
  local n=${1:-0}
  [[ "$n" =~ ^[0-9]+$ ]] || n=0

  if ((n >= 1000000)); then
    printf '%d.%01dM' "$((n / 1000000))" "$(((n % 1000000) / 100000))"
  elif ((n >= 1000)); then
    printf '%d.%01dk' "$((n / 1000))" "$(((n % 1000) / 100))"
  else
    printf '%d' "$n"
  fi
}

fmt_duration_ms() {
  local ms=${1:-0}
  [[ "$ms" =~ ^[0-9]+$ ]] || ms=0

  local s=$((ms / 1000))

  if ((s >= 3600)); then
    printf '%dh%02dm' "$((s / 3600))" "$(((s % 3600) / 60))"
  elif ((s >= 60)); then
    printf '%dm%02ds' "$((s / 60))" "$((s % 60))"
  else
    printf '%ss' "$s"
  fi
}

base_name() {
  local p=${1:-~}

  p=${p//\\//} # normalize Windows backslashes to forward slashes
  p=${p%/}

  if [[ -z "$p" ]]; then
    printf '/'
    return
  fi

  local b=${p##*/}

  [[ -z "$b" ]] && b='/'

  printf '%s' "$b"
}

short_model() {
  local m=${1:-Claude}

  if [[ "$CLAUDE_STATUSLINE_FULL_MODEL" == "1" ]]; then
    printf '%s' "$m"
    return
  fi

  case "$m" in
  *Opus*) printf 'Opus' ;;
  *Sonnet*) printf 'Sonnet' ;;
  *Haiku*) printf 'Haiku' ;;
  *) printf '%s' "$m" ;;
  esac
}

ctx_bar() {
  local pct=${1:-0}
  local width=${CLAUDE_STATUSLINE_BAR_WIDTH:-10}

  [[ "$pct" =~ ^[0-9]+$ ]] || pct=0
  ((pct < 0)) && pct=0
  ((pct > 100)) && pct=100

  [[ "$width" =~ ^[0-9]+$ ]] || width=10
  ((width < 3)) && width=3
  ((width > 30)) && width=30

  local filled=$((pct * width / 100))
  local empty=$((width - filled))

  local f=''
  local e=''

  printf -v f '%*s' "$filled" ''
  printf -v e '%*s' "$empty" ''

  printf '%s%s' "${f// /█}" "${e// /░}"
}

ctx_color() {
  local pct=${1:-0}

  [[ "$pct" =~ ^[0-9]+$ ]] || pct=0

  if ((pct >= 90)); then
    printf '%b' "$RED"
  elif ((pct >= 70)); then
    printf '%b' "$YELLOW"
  else
    printf '%b' "$GREEN"
  fi
}

cost_is_nonzero() {
  local c=${1:-0}

  c=${c//0/}
  c=${c//./}
  c=${c//,/}

  [[ -n "$c" ]]
}

osc8_link() {
  local url=${1:-}
  local text=${2:-}

  if [[ -n "$url" && "$CLAUDE_STATUSLINE_PR_LINK" == "1" && -z "${NO_COLOR:-}" ]]; then
    printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$url" "$text"
  else
    printf '%s' "$text"
  fi
}

append_segment() {
  local text=$1

  [[ -n "$text" ]] || return 0

  if [[ -z "$line" ]]; then
    line=$text
  else
    line+="${SEP}${text}"
  fi
}

# =============================================================================
# Git segment: one git-status call by default
# =============================================================================

git_segment() {
  [[ "$CLAUDE_STATUSLINE_GIT" == "1" ]] || return 0
  [[ -n "$dir" ]] || return 0

  local git_out

  git_out=$(git -C "$dir" status --porcelain=v1 -b --untracked-files=normal 2>/dev/null) || return 0

  [[ -n "$git_out" ]] || return 0

  local first branch ahead=0 behind=0 staged=0 modified=0 untracked=0 conflicts=0 stash_count=0

  first=${git_out%%$'\n'*}
  branch=${first#'## '}
  branch=${branch%%...*}
  branch=${branch%% \[*}
  branch=${branch#No commits yet on }

  [[ -z "$branch" || "$branch" == "$first" ]] && branch='git'

  [[ "$first" =~ ahead[[:space:]]+([0-9]+) ]] && ahead=${BASH_REMATCH[1]}
  [[ "$first" =~ behind[[:space:]]+([0-9]+) ]] && behind=${BASH_REMATCH[1]}

  local l xy x y

  while IFS= read -r l; do
    [[ -z "$l" || "$l" == '## '* ]] && continue

    xy=${l:0:2}
    x=${l:0:1}
    y=${l:1:1}

    case "$xy" in
    UU | AA | DD | AU | UA | DU | UD) ((conflicts++)) ;;
    esac

    if [[ "$xy" == '??' ]]; then
      ((untracked++))
      continue
    fi

    [[ "$x" != ' ' ]] && ((staged++))
    [[ "$y" != ' ' ]] && ((modified++))
  done <<<"$git_out"

  if [[ "$CLAUDE_STATUSLINE_SHOW_STASH" == "1" && "$verbose" == "1" ]]; then
    stash_count=$(git -C "$dir" stash list 2>/dev/null | wc -l | tr -d ' ')
    [[ "$stash_count" =~ ^[0-9]+$ ]] || stash_count=0
  fi

  local part color

  part="$branch"

  ((ahead > 0)) && part+=" ↑$ahead"
  ((behind > 0)) && part+=" ↓$behind"
  ((staged > 0)) && part+=" +$staged"
  ((modified > 0)) && part+=" ~$modified"
  ((untracked > 0)) && part+=" ?$untracked"
  ((conflicts > 0)) && part+=" !$conflicts"
  ((stash_count > 0)) && part+=" stash:$stash_count"

  color=$YELLOW
  ((conflicts > 0)) && color=$RED

  printf '%b %s%b' "$color" "$part" "$RESET"
}

# =============================================================================
# Main render
# =============================================================================

read_status_json

dir_name=$(base_name "$dir")
model_name=$(short_model "$model")
ctx_c=$(ctx_color "$ctx_pct")

line=''
line2=''

# Identity first: model, then its parameters (effort, thinking, style, vim).
append_segment "$(printf '%b %s%b' "$BLUE" "$model_name" "$RESET")"

if [[ "$compact" != "1" ]]; then
  if [[ -n "$effort" && "$effort" != "null" ]]; then
    append_segment "$(printf '%b%s%b' "$YELLOW" "$effort" "$RESET")"
  fi

  if [[ "$thinking" == "true" ]]; then
    append_segment "$(printf '%bthink%b' "$BLUE" "$RESET")"
  fi

  if [[ "$CLAUDE_STATUSLINE_SHOW_STYLE" == "1" && "$verbose" == "1" && -n "$style" && "$style" != "default" && "$style" != "null" ]]; then
    append_segment "$(printf '%b%s%b' "$SUBTLE" "$style" "$RESET")"
  fi

  if [[ "$CLAUDE_STATUSLINE_SHOW_VIM" == "1" && -n "$vim_mode" && "$vim_mode" != "null" ]]; then
    append_segment "$(printf '%b%s%b' "$SUBTLE" "$vim_mode" "$RESET")"
  fi
fi

# Then location: directory (basename), agent, session.
append_segment "$(printf '%s' "$dir_name")"

if [[ "$compact" != "1" ]]; then
  if [[ -n "$agent" ]]; then
    append_segment "$(printf '%b@%s%b' "$GREEN" "$agent" "$RESET")"
  fi

  if [[ "$CLAUDE_STATUSLINE_SHOW_SESSION" == "1" && "$verbose" == "1" && -n "$session_name" ]]; then
    append_segment "$(printf '%b%s%b' "$SUBTLE" "$session_name" "$RESET")"
  fi
fi

if
  git_part=$(git_segment)
  [[ -n "$git_part" ]]
then
  append_segment "$git_part"
fi

if [[ -n "$worktree" && "$verbose" == "1" ]]; then
  wt="wt:$worktree"
  [[ -n "$original_branch" ]] && wt+="←$original_branch"
  append_segment "$(printf '%b%s%b' "$BLUE" "$wt" "$RESET")"
fi

if [[ -n "$pr_number" && "$verbose" == "1" ]]; then
  pr_text="PR#$pr_number"

  [[ -n "$pr_state" && "$pr_state" != "null" ]] && pr_text+=":$pr_state"

  pr_text=$(osc8_link "$pr_url" "$pr_text")

  append_segment "$(printf '%b%s%b' "$GREEN" "$pr_text" "$RESET")"
fi

if [[ "$added" != "0" || "$removed" != "0" ]]; then
  append_segment "$(printf '%b+%s%b/%b-%s%b' "$GREEN" "$added" "$RESET" "$RED" "$removed" "$RESET")"
fi

if [[ "$in_tokens" != "0" || "$out_tokens" != "0" ]]; then
  if [[ "$compact" == "1" ]]; then
    append_segment "$(printf '%bctx:%s%%%b' "$ctx_c" "$ctx_pct" "$RESET")"
  else
    append_segment "$(printf '%b%s %s%%%b' "$ctx_c" "$(ctx_bar "$ctx_pct")" "$ctx_pct" "$RESET")"
  fi

  append_segment "$(printf '%b↓%s%b %b↑%s%b' "$BLUE" "$(fmt_tokens "$in_tokens")" "$RESET" "$GREEN" "$(fmt_tokens "$out_tokens")" "$RESET")"
fi

if [[ "$CLAUDE_STATUSLINE_SHOW_CACHE" == "1" && "$verbose" == "1" ]]; then
  if [[ "$cache_read" != "0" || "$cache_write" != "0" ]]; then
    append_segment "$(printf '%bcache r:%s w:%s%b' "$SUBTLE" "$(fmt_tokens "$cache_read")" "$(fmt_tokens "$cache_write")" "$RESET")"
  fi
fi

if [[ "$CLAUDE_STATUSLINE_SHOW_RATE" == "1" && "$verbose" == "1" ]]; then
  rate=''

  if [[ -n "$limit_5h_pct" && "$limit_5h_pct" != "null" ]]; then
    rate+="5h:${limit_5h_pct%.*}%"
  fi

  if [[ -n "$limit_7d_pct" && "$limit_7d_pct" != "null" ]]; then
    [[ -n "$rate" ]] && rate+=' '
    rate+="7d:${limit_7d_pct%.*}%"
  fi

  [[ -n "$rate" ]] && append_segment "$(printf '%b%s%b' "$YELLOW" "$rate" "$RESET")"
fi

if [[ "$CLAUDE_STATUSLINE_SHOW_COST" == "1" && "$verbose" == "1" ]]; then
  cost_part=''

  if cost_is_nonzero "$cost"; then
    cost_part="$(LC_ALL=C printf '$%.2f' "$cost" 2>/dev/null || printf '$%s' "$cost")"
  fi

  if [[ "$duration_ms" != "0" ]]; then
    [[ -n "$cost_part" ]] && cost_part+=' '
    cost_part+="$(fmt_duration_ms "$duration_ms")"
  fi

  if [[ "$api_ms" != "0" && "$wide" == "1" ]]; then
    [[ -n "$cost_part" ]] && cost_part+=' '
    cost_part+="api:$(fmt_duration_ms "$api_ms")"
  fi

  [[ -n "$cost_part" ]] && append_segment "$(printf '%b%s%b' "$SUBTLE" "$cost_part" "$RESET")"
fi

if [[ "$exceeds_200k" == "true" ]]; then
  append_segment "$(printf '%b>200k%b' "$RED" "$RESET")"
fi

# Optional multi-line mode: keep line 1 identity/git; line 2 pressure/cost/rate.
# Default is single-line because it fits better in most terminals.
if [[ "$CLAUDE_STATUSLINE_MULTILINE" == "1" && "$compact" != "1" ]]; then
  line2="$(printf '%bcontext %s %s%% ↓%s ↑%s%b' \
    "$ctx_c" "$(ctx_bar "$ctx_pct")" "$ctx_pct" "$(fmt_tokens "$in_tokens")" "$(fmt_tokens "$out_tokens")" "$RESET")"

  if [[ "$CLAUDE_STATUSLINE_SHOW_COST" == "1" && "$duration_ms" != "0" ]]; then
    line2+="${SEP}$(printf '%btime:%s api:%s%b' "$SUBTLE" "$(fmt_duration_ms "$duration_ms")" "$(fmt_duration_ms "$api_ms")" "$RESET")"
  fi

  printf '%b\n%b' "$line" "$line2"
else
  printf '%b' "$line"
fi
