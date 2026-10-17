$env.config.show_banner = false
$env.config.buffer_editor = ($env.EDITOR? | default ($env.VISUAL? | default "hx"))
$env.config.history = {
  max_size: 100_000
  sync_on_enter: true
  file_format: "sqlite"
  isolation: false
}
$env.config.completions = {
  case_sensitive: false
  quick: true
  partial: true
  algorithm: "fuzzy"
  external: { enable: true, max_results: 100 }
}
$env.config.shell_integration = {
  osc2: true
  osc7: true
  osc8: true
  osc9_9: false
  osc133: false
  osc633: false
  reset_application_mode: true
}
$env.config.table.mode = "rounded"
$env.config.ls.use_ls_colors = true
$env.config.rm.always_trash = true

use modules/aliases.nu *
use modules/fzf.nu *
use modules/yazi.nu *
use modules/git.nu *

$env.config.keybindings = (
  $env.config.keybindings
  | append $FZF_EDIT_BINDING
  | append $FZF_CD_KEYBINDING
  | append $FZF_HISTORY_BINDING
)

let autoload_dir = ($nu.data-dir | path join "vendor" "autoload")
let required = ["starship.nu" "zoxide.nu" "carapace.nu"]
let missing = ($required | where {|name| not (($autoload_dir | path join $name) | path exists) })
if not ($missing | is-empty) {
  print --stderr $"shell setup missing (($missing | str join ', ')); run: mise run setup:shell"
}
