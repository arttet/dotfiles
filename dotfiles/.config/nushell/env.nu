# Nushell startup environment. Directory creation belongs to `mise run setup:shell`.

$env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($nu.home-dir | path join ".config"))
$env.XDG_CACHE_HOME = ($env.XDG_CACHE_HOME? | default ($nu.home-dir | path join ".cache"))
$env.XDG_DATA_HOME = ($env.XDG_DATA_HOME? | default ($nu.home-dir | path join ".local" "share"))
$env.XDG_STATE_HOME = ($env.XDG_STATE_HOME? | default ($nu.home-dir | path join ".local" "state"))

$env.LC_ALL = ($env.LC_ALL? | default "en_US.UTF-8")
$env.LANG = ($env.LANG? | default "en_US.UTF-8")
$env.LANGUAGE = ($env.LANGUAGE? | default "en_US.UTF-8")

let current_path = match ($env.PATH? | describe) {
  "string" => ($env.PATH | split row (char esep))
  $type if ($type =~ "list") => $env.PATH
  _ => []
}
let local_bin = ($nu.home-dir | path join ".local" "bin")
let mise_shims = ($nu.home-dir | path join ".local" "share" "mise" "shims")
let mise_windows_bin = (
  ($env.LOCALAPPDATA? | default ($nu.home-dir | path join "AppData" "Local"))
  | path join "Microsoft" "WinGet" "Packages" "jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe" "mise" "bin"
)
let preferred_path = if $nu.os-info.name == "windows" {
  [$mise_windows_bin $mise_shims $local_bin]
} else {
  [$mise_shims $local_bin]
}
$env.PATH = ($preferred_path | append $current_path | uniq)

$env.EDITOR = ($env.EDITOR? | default "hx")
$env.VISUAL = ($env.VISUAL? | default $env.EDITOR)
$env.PAGER = ($env.PAGER? | default "less")
$env.LESS = ($env.LESS? | default "-R -M -i -j.5 --shift 5")
$env.SHELL = "nu"

$env.STARSHIP_CONFIG = ($env.STARSHIP_CONFIG? | default (
  if ($env.TMUX? | is-not-empty) {
    $env.XDG_CONFIG_HOME | path join "starship" "starship.tmux.toml"
  } else {
    $env.XDG_CONFIG_HOME | path join "starship" "starship.toml"
  }
))
$env.FZF_DEFAULT_OPTS = ($env.FZF_DEFAULT_OPTS? | default (
  "--height=60% --layout=reverse --border --cycle --inline-info "
  + "--color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa "
  + "--color=fg+:#cdd6f4,bg+:#313244,hl+:#89dceb "
  + "--color=info:#cba6f7,prompt:#89b4fa,pointer:#f5c2e7 "
  + "--color=marker:#a6e3a1,spinner:#cba6f7,header:#6c7086 "
  + "--bind=ctrl-/:toggle-preview --bind=ctrl-u:preview-half-page-up --bind=ctrl-d:preview-half-page-down"
))
$env.BAT_THEME = ($env.BAT_THEME? | default "Catppuccin Mocha")
$env.BAT_CONFIG_PATH = ($env.BAT_CONFIG_PATH? | default ($env.XDG_CONFIG_HOME | path join "bat" "config"))
$env.GH_CONFIG_DIR = ($env.GH_CONFIG_DIR? | default ($env.XDG_CONFIG_HOME | path join "gh"))
$env.RIPGREP_CONFIG_PATH = ($env.RIPGREP_CONFIG_PATH? | default ($env.XDG_CONFIG_HOME | path join "ripgrep" "config"))
$env.YAZI_CONFIG_HOME = ($env.YAZI_CONFIG_HOME? | default ($env.XDG_CONFIG_HOME | path join "yazi"))
$env.WAKATIME_HOME = ($env.WAKATIME_HOME? | default ($env.XDG_CONFIG_HOME | path join "wakatime"))
$env.CLAUDE_CONFIG_DIR = ($env.CLAUDE_CONFIG_DIR? | default ($env.XDG_CONFIG_HOME | path join "claude"))
$env.CODEX_HOME = ($env.CODEX_HOME? | default ($env.XDG_CONFIG_HOME | path join "codex"))
$env.KIMI_CODE_HOME = ($env.KIMI_CODE_HOME? | default ($env.XDG_CONFIG_HOME | path join "kimi-code"))
$env.EZA_COLORS = ($env.EZA_COLORS? | default "da=36:di=34:ln=35:so=32:pi=33:ex=31:bd=34:cd=34:su=31:sg=31:tw=34:ow=34")

if $nu.os-info.name == "windows" {
  $env.ZELLIJ_CONFIG_DIR = ($env.ZELLIJ_CONFIG_DIR? | default ($env.XDG_CONFIG_HOME | path join "zellij"))
}
