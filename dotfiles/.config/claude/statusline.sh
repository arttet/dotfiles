#!/usr/bin/env bash
# Claude Code / agent statusline with configurable segment pipeline.
#
# Runtime state lives inside main().
# Segment functions read main-local variables through Bash dynamic scoping.
#
# Segment naming convention:
#   "model-with-reasoning" -> seg_model_with_reasoning
#   "context-remaining"    -> seg_context_remaining
#
# Available segment names:
#
# Identity / model:
#   "model"                -> seg_model
#   "model-id"             -> seg_model_id
#   "model-with-reasoning" -> seg_model_with_reasoning
#   "reasoning"            -> seg_reasoning
#   "effort"               -> seg_effort
#   "thinking"             -> seg_thinking
#   "agent"                -> seg_agent
#   "style"                -> seg_style
#   "version"              -> seg_version
#
# Project / workspace:
#   "project-name"         -> seg_project_name
#   "cwd"                  -> seg_cwd
#   "project-dir"          -> seg_project_dir
#   "worktree"             -> seg_worktree
#   "worktree-branch"      -> seg_worktree_branch
#   "original-branch"      -> seg_original_branch
#
# Git / PR:
#   "git-branch"           -> seg_git_branch
#   "branch-changes"       -> seg_branch_changes
#   "diff-lines"           -> seg_diff_lines
#   "lines-added"          -> seg_lines_added
#   "lines-removed"        -> seg_lines_removed
#   "pr"                   -> seg_pr
#   "pr-number"            -> seg_pr_number
#   "pr-state"             -> seg_pr_state
#   "pr-url"               -> seg_pr_url
#
# Context / tokens:
#   "context-remaining"    -> seg_context_remaining
#   "context-used"         -> seg_context_used
#   "context-window"       -> seg_context_window
#   "context-window-raw"   -> seg_context_window_raw
#   "tokens-used"          -> seg_tokens_used
#   "input-tokens"         -> seg_input_tokens
#   "output-tokens"        -> seg_output_tokens
#   "current-input-tokens" -> seg_current_input_tokens
#   "cache-tokens"         -> seg_cache_tokens
#   "cache-read-tokens"    -> seg_cache_read_tokens
#   "cache-write-tokens"   -> seg_cache_write_tokens
#
# Limits:
#   "five-hour-limit"      -> seg_five_hour_limit
#   "weekly-limit"         -> seg_weekly_limit
#   "five-hour-used"       -> seg_five_hour_used
#   "weekly-used"          -> seg_weekly_used
#
# Cost / timing:
#   "cost"                 -> seg_cost
#   "duration"             -> seg_duration
#   "api-duration"         -> seg_api_duration
#
# Task:
#   "task-progress"        -> seg_task_progress
#   "available-segments"   -> seg_available_segments
#
# Config override:
#   ~/.config/agent-statusline/config.bash
#
# Example config:
#   status_line=(
#     "model-with-reasoning"
#     "context-remaining"
#     "project-name"
#     "context-used"
#     "five-hour-limit"
#     "weekly-limit"
#     "version"
#     "context-window"
#     "tokens-used"
#     "input-tokens"
#     "output-tokens"
#   )

# =============================================================================
# JSON parser
# =============================================================================

json_parser_bin() {
  local requested=${1:-}

  if [[ -n "$requested" ]]; then
    printf '%s' "$requested"
  elif command -v jaq >/dev/null 2>&1; then
    printf '%s' jaq
  elif command -v jq >/dev/null 2>&1; then
    printf '%s' jq
  else
    return 1
  fi
}

read_status_json() {
  local parser=$1
  local input=$2

  "$parser" -r '
    def sh($name; $v): "\($name)=\($v | tostring | @sh)";

    [
      sh("model"; .model.display_name // "Claude"),
      sh("model_id"; .model.id // ""),
      sh("version"; .version // ""),

      sh("dir"; .workspace.current_dir // .cwd // "~"),
      sh("project_dir"; .workspace.project_dir // ""),

      sh("agent"; .agent.name // ""),
      sh("effort"; .effort.level // ""),
      sh("thinking"; .thinking.enabled // false),
      sh("style"; .output_style.name // "default"),

      sh("ctx_used_pct"; ((.context_window.used_percentage // 0) | floor)),
      sh("ctx_left_pct"; (100 - ((.context_window.used_percentage // 0) | floor))),
      sh("ctx_size"; .context_window.context_window_size // 0),

      sh("input_tokens"; .context_window.total_input_tokens // 0),
      sh("output_tokens"; .context_window.total_output_tokens // 0),
      sh("current_input_tokens"; .context_window.current_usage.input_tokens // 0),
      sh("cache_read_tokens"; .context_window.current_usage.cache_read_input_tokens // 0),
      sh("cache_write_tokens"; .context_window.current_usage.cache_creation_input_tokens // 0),

      sh("five_hour_left_pct";
        if .rate_limits.five_hour.used_percentage == null
        then ""
        else (100 - (.rate_limits.five_hour.used_percentage | floor))
        end
      ),
      sh("weekly_left_pct";
        if .rate_limits.seven_day.used_percentage == null
        then ""
        else (100 - (.rate_limits.seven_day.used_percentage | floor))
        end
      ),
      sh("five_hour_used_pct";
        if .rate_limits.five_hour.used_percentage == null
        then ""
        else (.rate_limits.five_hour.used_percentage | floor)
        end
      ),
      sh("weekly_used_pct";
        if .rate_limits.seven_day.used_percentage == null
        then ""
        else (.rate_limits.seven_day.used_percentage | floor)
        end
      ),

      sh("cost_usd"; .cost.total_cost_usd // 0),
      sh("duration_ms"; .cost.total_duration_ms // 0),
      sh("api_ms"; .cost.total_api_duration_ms // 0),
      sh("lines_added"; .cost.total_lines_added // 0),
      sh("lines_removed"; .cost.total_lines_removed // 0),

      sh("pr_number"; .pr.number // ""),
      sh("pr_state"; .pr.review_state // ""),
      sh("pr_url"; .pr.url // ""),

      sh("worktree"; .worktree.name // .workspace.git_worktree // ""),
      sh("worktree_branch"; .worktree.branch // ""),
      sh("original_branch"; .worktree.original_branch // ""),

      sh("task_done"; .task_progress.done // .task_progress.completed // .todos.completed // ""),
      sh("task_total"; .task_progress.total // .todos.total // ""),
      sh("task_label"; .task_progress.label // .task_progress.name // "")
    ] | .[]
  ' <<<"$input"
}

# =============================================================================
# Helpers
# =============================================================================

available_segments() {
  cat <<'EOF'
model
model-id
model-with-reasoning
reasoning
effort
thinking
agent
style
version
project-name
cwd
project-dir
worktree
worktree-branch
original-branch
git-branch
branch-changes
diff-lines
lines-added
lines-removed
pr
pr-number
pr-state
pr-url
context-remaining
context-used
context-window
context-window-raw
tokens-used
input-tokens
output-tokens
current-input-tokens
cache-tokens
cache-read-tokens
cache-write-tokens
five-hour-limit
weekly-limit
five-hour-used
weekly-used
cost
duration
api-duration
task-progress
available-segments
EOF
}

basename_clean() {
  local p=${1:-~}

  p=${p//\\//}
  p=${p%/}

  if [[ -z "$p" ]]; then
    printf '/'
    return
  fi

  local b=${p##*/}

  [[ -z "$b" ]] && b='/'

  printf '%s' "$b"
}

fmt_count() {
  local n=${1:-0}

  [[ "$n" =~ ^[0-9]+$ ]] || n=0

  if ((n >= 1000000)); then
    local whole=$((n / 1000000))
    local frac=$(((n % 1000000) / 10000))

    if ((frac == 0)); then
      printf '%dM' "$whole"
    elif ((frac % 10 == 0)); then
      printf '%d.%dM' "$whole" "$((frac / 10))"
    else
      printf '%d.%02dM' "$whole" "$frac"
    fi
  elif ((n >= 100000)); then
    printf '%dK' "$((n / 1000))"
  elif ((n >= 1000)); then
    printf '%d.%dK' "$((n / 1000))" "$(((n % 1000) / 100))"
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

fmt_model() {
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

is_nonzero() {
  local n=${1:-0}

  [[ "$n" =~ ^[0-9]+$ ]] || n=0

  ((n > 0))
}

trim() {
  local s=$1

  s=${s#"${s%%[![:space:]]*}"}
  s=${s%"${s##*[![:space:]]}"}

  printf '%s' "$s"
}

# =============================================================================
# Git cache
# =============================================================================
# These functions intentionally assign git_* variables from main().
# Bash dynamic scoping makes main-local variables visible and mutable here.

load_git() {
  ((git_loaded == 1)) && return 0

  git_loaded=1

  local out first line xy x y

  out=$(git -C "$dir" status --porcelain=v1 -b --untracked-files=normal 2>/dev/null) || return 0
  [[ -n "$out" ]] || return 0

  git_inside=1

  first=${out%%$'\n'*}

  git_branch=${first#'## '}
  git_branch=${git_branch%%...*}
  git_branch=${git_branch%% \[*}
  git_branch=${git_branch#No commits yet on }

  [[ -z "$git_branch" || "$git_branch" == "$first" ]] && git_branch='git'

  [[ "$first" =~ ahead[[:space:]]+([0-9]+) ]] && git_ahead=${BASH_REMATCH[1]}
  [[ "$first" =~ behind[[:space:]]+([0-9]+) ]] && git_behind=${BASH_REMATCH[1]}

  while IFS= read -r line; do
    [[ -z "$line" || "$line" == '## '* ]] && continue

    xy=${line:0:2}
    x=${line:0:1}
    y=${line:1:1}

    case "$xy" in
    UU | AA | DD | AU | UA | DU | UD) ((git_conflicts++)) ;;
    esac

    if [[ "$xy" == '??' ]]; then
      ((git_untracked++))
      continue
    fi

    [[ "$x" != ' ' ]] && ((git_staged++))
    [[ "$y" != ' ' ]] && ((git_modified++))
  done <<<"$out"
}

# =============================================================================
# Segment functions
# =============================================================================

seg_model() {
  fmt_model "$model"
}

seg_model_id() {
  [[ -n "$model_id" ]] || return 0

  printf '%s' "$model_id"
}

seg_model_with_reasoning() {
  local s

  s="$(fmt_model "$model")"

  if [[ -n "$effort" && "$effort" != "null" ]]; then
    s+=" $effort"
  elif [[ "$thinking" == "true" ]]; then
    s+=" thinking"
  fi

  printf '%s' "$s"
}

seg_reasoning() {
  if [[ -n "$effort" && "$effort" != "null" ]]; then
    printf '%s' "$effort"
  elif [[ "$thinking" == "true" ]]; then
    printf 'thinking'
  fi
}

seg_effort() {
  [[ -n "$effort" && "$effort" != "null" ]] || return 0

  printf '%s' "$effort"
}

seg_thinking() {
  [[ "$thinking" == "true" ]] || return 0

  printf 'thinking'
}

seg_agent() {
  [[ -n "$agent" ]] || return 0

  printf '@%s' "$agent"
}

seg_style() {
  [[ -n "$style" && "$style" != "default" && "$style" != "null" ]] || return 0

  printf '%s' "$style"
}

seg_version() {
  [[ -n "$version" ]] || return 0

  printf '%s' "$version"
}

seg_project_name() {
  basename_clean "$dir"
}

seg_cwd() {
  [[ -n "$dir" ]] || return 0

  printf '%s' "$dir"
}

seg_project_dir() {
  [[ -n "$project_dir" ]] || return 0

  printf '%s' "$project_dir"
}

seg_worktree() {
  [[ -n "$worktree" ]] || return 0

  if [[ -n "$original_branch" ]]; then
    printf 'wt:%s←%s' "$worktree" "$original_branch"
  else
    printf 'wt:%s' "$worktree"
  fi
}

seg_worktree_branch() {
  [[ -n "$worktree_branch" ]] || return 0

  printf '%s' "$worktree_branch"
}

seg_original_branch() {
  [[ -n "$original_branch" ]] || return 0

  printf '%s' "$original_branch"
}

seg_git_branch() {
  load_git

  ((git_inside == 1)) || return 0

  printf '%s' "$git_branch"
}

seg_branch_changes() {
  load_git

  ((git_inside == 1)) || return 0

  local parts=()

  ((git_ahead > 0)) && parts+=("↑$git_ahead")
  ((git_behind > 0)) && parts+=("↓$git_behind")
  ((git_staged > 0)) && parts+=("+$git_staged")
  ((git_modified > 0)) && parts+=("~$git_modified")
  ((git_untracked > 0)) && parts+=("?$git_untracked")
  ((git_conflicts > 0)) && parts+=("!$git_conflicts")

  if ((${#parts[@]} == 0)); then
    [[ "$CLAUDE_STATUSLINE_SHOW_CLEAN" == "1" ]] && printf 'clean'
    return 0
  fi

  local IFS=' '

  printf '%s' "${parts[*]}"
}

seg_diff_lines() {
  [[ "$lines_added" == "0" && "$lines_removed" == "0" ]] && return 0

  printf '+%s/-%s' "$lines_added" "$lines_removed"
}

seg_lines_added() {
  is_nonzero "$lines_added" || return 0

  printf '+%s' "$lines_added"
}

seg_lines_removed() {
  is_nonzero "$lines_removed" || return 0

  printf -- '-%s' "$lines_removed"
}

seg_pr() {
  [[ -n "$pr_number" ]] || return 0

  if [[ -n "$pr_state" && "$pr_state" != "null" ]]; then
    printf 'PR#%s:%s' "$pr_number" "$pr_state"
  else
    printf 'PR#%s' "$pr_number"
  fi
}

seg_pr_number() {
  [[ -n "$pr_number" ]] || return 0

  printf 'PR#%s' "$pr_number"
}

seg_pr_state() {
  [[ -n "$pr_state" && "$pr_state" != "null" ]] || return 0

  printf '%s' "$pr_state"
}

seg_pr_url() {
  [[ -n "$pr_url" ]] || return 0

  printf '%s' "$pr_url"
}

seg_context_remaining() {
  [[ "$ctx_left_pct" =~ ^[0-9]+$ ]] || return 0

  printf 'Context %s%% left' "$ctx_left_pct"
}

seg_context_used() {
  [[ "$ctx_used_pct" =~ ^[0-9]+$ ]] || return 0

  printf 'Context %s%% used' "$ctx_used_pct"
}

seg_context_window() {
  is_nonzero "$ctx_size" || return 0

  printf '%s window' "$(fmt_count "$ctx_size")"
}

seg_context_window_raw() {
  is_nonzero "$ctx_size" || return 0

  printf '%s' "$ctx_size"
}

seg_tokens_used() {
  local total=$((input_tokens + output_tokens))

  is_nonzero "$total" || return 0

  printf '%s used' "$(fmt_count "$total")"
}

seg_input_tokens() {
  is_nonzero "$input_tokens" || return 0

  printf '%s in' "$(fmt_count "$input_tokens")"
}

seg_output_tokens() {
  is_nonzero "$output_tokens" || return 0

  printf '%s out' "$(fmt_count "$output_tokens")"
}

seg_current_input_tokens() {
  is_nonzero "$current_input_tokens" || return 0

  printf '%s current in' "$(fmt_count "$current_input_tokens")"
}

seg_cache_tokens() {
  local total=$((cache_read_tokens + cache_write_tokens))

  is_nonzero "$total" || return 0

  printf '%s cache' "$(fmt_count "$total")"
}

seg_cache_read_tokens() {
  is_nonzero "$cache_read_tokens" || return 0

  printf '%s cache read' "$(fmt_count "$cache_read_tokens")"
}

seg_cache_write_tokens() {
  is_nonzero "$cache_write_tokens" || return 0

  printf '%s cache write' "$(fmt_count "$cache_write_tokens")"
}

seg_five_hour_limit() {
  [[ -n "$five_hour_left_pct" ]] || return 0

  printf '5h %s%% left' "$five_hour_left_pct"
}

seg_weekly_limit() {
  [[ -n "$weekly_left_pct" ]] || return 0

  printf 'weekly %s%% left' "$weekly_left_pct"
}

seg_five_hour_used() {
  [[ -n "$five_hour_used_pct" ]] || return 0

  printf '5h %s%% used' "$five_hour_used_pct"
}

seg_weekly_used() {
  [[ -n "$weekly_used_pct" ]] || return 0

  printf 'weekly %s%% used' "$weekly_used_pct"
}

seg_cost() {
  [[ "$cost_usd" == "0" || "$cost_usd" == "0.0" || "$cost_usd" == "0.00" ]] && return 0

  printf '$%.2f' "$cost_usd" 2>/dev/null || printf '$%s' "$cost_usd"
}

seg_duration() {
  is_nonzero "$duration_ms" || return 0

  fmt_duration_ms "$duration_ms"
}

seg_api_duration() {
  is_nonzero "$api_ms" || return 0

  printf 'api %s' "$(fmt_duration_ms "$api_ms")"
}

seg_task_progress() {
  if [[ -n "${CLAUDE_TASK_PROGRESS:-}" ]]; then
    printf '%s' "$CLAUDE_TASK_PROGRESS"
    return 0
  fi

  [[ -n "$task_done" && -n "$task_total" ]] || return 0

  if [[ -n "$task_label" ]]; then
    printf '%s %s/%s' "$task_label" "$task_done" "$task_total"
  else
    printf 'tasks %s/%s' "$task_done" "$task_total"
  fi
}

seg_available_segments() {
  local segment
  local separator=''

  while IFS= read -r segment; do
    printf '%s%s' "$separator" "$segment"
    separator=', '
  done < <(available_segments)
}

# =============================================================================
# Renderer
# =============================================================================

render_segment() {
  local name=$1
  local fn

  name=$(trim "$name")

  [[ -n "$name" ]] || return 0

  fn="seg_${name//-/_}"

  if declare -F "$fn" >/dev/null 2>&1; then
    "$fn"
  fi
}

render_statusline() {
  local parts=()
  local segment value
  local i

  for segment in "${status_line[@]}"; do
    value=$(render_segment "$segment")
    [[ -n "$value" ]] && parts+=("$value")
  done

  if ((${#parts[@]} == 0)); then
    fmt_model "$model"
    return 0
  fi

  printf '%s' "${parts[0]}"

  for ((i = 1; i < ${#parts[@]}; i++)); do
    printf '%s%s' "$CLAUDE_STATUSLINE_SEPARATOR" "${parts[$i]}"
  done
}

# =============================================================================
# Main
# =============================================================================

main() {
  case "${1:-}" in
  --list-segments)
    available_segments
    return 0
    ;;
  esac

  # Do not use `set -e`: statusline should degrade gracefully.
  set -o pipefail

  local input
  input=$(cat)

  local CLAUDE_STATUSLINE_JSON_PARSER=${CLAUDE_STATUSLINE_JSON_PARSER:-}
  local CLAUDE_STATUSLINE_SEPARATOR=${CLAUDE_STATUSLINE_SEPARATOR:-'  '}
  local CLAUDE_STATUSLINE_CONFIG=${CLAUDE_STATUSLINE_CONFIG:-"${XDG_CONFIG_HOME:-$HOME/.config}/agent-statusline/config.bash"}
  local CLAUDE_STATUSLINE_FULL_MODEL=${CLAUDE_STATUSLINE_FULL_MODEL:-1}
  local CLAUDE_STATUSLINE_SHOW_CLEAN=${CLAUDE_STATUSLINE_SHOW_CLEAN:-1}

  local -a status_line=(
    "model-with-reasoning"
    "context-remaining"
    "git-branch"
    "project-name"
    "branch-changes"
    "five-hour-limit"
    "weekly-limit"
    "task-progress"
  )

  # Runtime JSON fields. Declared local before eval so assignments remain local.
  local model='Claude'
  local model_id=''
  local version=''

  local dir='~'
  local project_dir=''

  local agent=''
  local effort=''
  local thinking='false'
  local style='default'

  local ctx_used_pct=0
  local ctx_left_pct=100
  local ctx_size=0

  local input_tokens=0
  local output_tokens=0
  local current_input_tokens=0
  local cache_read_tokens=0
  local cache_write_tokens=0

  local five_hour_left_pct=''
  local weekly_left_pct=''
  local five_hour_used_pct=''
  local weekly_used_pct=''

  local cost_usd=0
  local duration_ms=0
  local api_ms=0
  local lines_added=0
  local lines_removed=0

  local pr_number=''
  local pr_state=''
  local pr_url=''

  local worktree=''
  local worktree_branch=''
  local original_branch=''

  local task_done=''
  local task_total=''
  local task_label=''

  # Git cache. These are main-local and mutated by load_git().
  local git_loaded=0
  local git_inside=0
  local git_branch=''
  local git_ahead=0
  local git_behind=0
  local git_staged=0
  local git_modified=0
  local git_untracked=0
  local git_conflicts=0

  local parser assignments

  if ! parser=$(json_parser_bin "$CLAUDE_STATUSLINE_JSON_PARSER"); then
    printf 'install jq or jaq'
    return 0
  fi

  if ! assignments=$(read_status_json "$parser" "$input" 2>/dev/null); then
    printf 'invalid statusline json'
    return 0
  fi

  eval "$assignments"

  # Optional user config. Sourced inside main, so it can override main-local config.
  if [[ -f "$CLAUDE_STATUSLINE_CONFIG" ]]; then
    # shellcheck source=/dev/null
    source "$CLAUDE_STATUSLINE_CONFIG"
  fi

  # Optional env override:
  #   CLAUDE_STATUSLINE_SEGMENTS="model-with-reasoning,context-remaining,project-name"
  if [[ -n "${CLAUDE_STATUSLINE_SEGMENTS:-}" ]]; then
    IFS=',' read -r -a status_line <<<"$CLAUDE_STATUSLINE_SEGMENTS"
  fi

  render_statusline
}

main "$@"
