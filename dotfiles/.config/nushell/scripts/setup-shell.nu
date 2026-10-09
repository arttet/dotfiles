# Generate shell integrations outside the startup path.

def ensure-tool [name: string] {
  if (which $name | is-empty) {
    error make { msg: $"required tool not found: ($name)" }
  }
}

def generate-output [name: string, ...args: string] {
  let result = (run-external $name ...$args | complete)
  if $result.exit_code != 0 {
    error make { msg: $"($name) generator failed: ($result.stderr | str trim)" }
  }
  $result.stdout
}

def write-atomic [target: path, content: string] {
  if ($content | is-empty) {
    error make { msg: $"generator produced an empty file: ($target)" }
  }
  let parent = ($target | path dirname)
  mkdir $parent
  let temporary = ($parent | path join $".($target | path basename).($nu.pid).tmp")
  try {
    $content | save --force $temporary
    let extension = ($target | path parse | get extension)
    let validation = match $extension {
      "bash" => (bash -n $temporary | complete)
      "zsh" => (zsh -n $temporary | complete)
      _ => { exit_code: 0, stdout: "", stderr: "" }
    }
    if $validation.exit_code != 0 {
      error make { msg: $"invalid generated ($extension) file: ($validation.stderr)" }
    }
    mv --force $temporary $target
  } catch {|error|
    rm --force $temporary
    error make { msg: $error.msg }
  }
}

def generate [] {
  for tool in ["starship" "zoxide" "fzf" "carapace" "bash" "zsh"] {
    ensure-tool $tool
  }

  let cache = ($env.XDG_CACHE_HOME? | default ($nu.home-dir | path join ".cache") | path expand)
  let state = ($env.XDG_STATE_HOME? | default ($nu.home-dir | path join ".local" "state") | path expand)
  let data = ($env.XDG_DATA_HOME? | default ($nu.home-dir | path join ".local" "share") | path expand)
  let bash_init = ($cache | path join "bash" "init")
  let zsh_init = ($cache | path join "zsh" "init")
  let nu_init = ($data | path join "nushell" "vendor" "autoload")

  for directory in [
    ($nu.home-dir | path join ".local" "bin")
    ($state | path join "bash")
    ($state | path join "zsh")
    ($cache | path join "zsh" "zcompcache")
    $bash_init
    $zsh_init
    $nu_init
  ] {
    mkdir $directory
  }

  write-atomic ($bash_init | path join "fzf.bash") (generate-output fzf "--bash")
  write-atomic ($bash_init | path join "zoxide.bash") (generate-output zoxide init bash)
  let carapace_bash = with-env { CARAPACE_ENV: "0", CARAPACE_BRIDGES: "bash" } {
    generate-output carapace _carapace bash | str replace --regex '^export PATH=.*\r?\n' ''
  }
  write-atomic ($bash_init | path join "carapace.bash") $carapace_bash
  write-atomic ($bash_init | path join "starship.bash") (generate-output starship init bash "--print-full-init")

  write-atomic ($zsh_init | path join "fzf.zsh") (generate-output fzf "--zsh")
  write-atomic ($zsh_init | path join "zoxide.zsh") (generate-output zoxide init zsh)
  let carapace_zsh = with-env { CARAPACE_ENV: "0", CARAPACE_BRIDGES: "zsh" } {
    generate-output carapace _carapace zsh | str replace --regex '^export PATH=.*\r?\n' ''
  }
  write-atomic ($zsh_init | path join "carapace.zsh") $carapace_zsh
  write-atomic ($zsh_init | path join "starship.zsh") (generate-output starship init zsh)

  write-atomic ($nu_init | path join "starship.nu") (generate-output starship init nu)
  write-atomic ($nu_init | path join "zoxide.nu") (generate-output zoxide init nushell)
  let carapace_nu = with-env { CARAPACE_ENV: "0" } {
    generate-output carapace _carapace nushell
  }
  write-atomic ($nu_init | path join "carapace.nu") $carapace_nu
  if $nu.os-info.name != "windows" {
    ensure-tool mise
    write-atomic ($nu_init | path join "mise.nu") (generate-output mise activate nu)
  }

  let zcompdump = ($cache | path join "zsh" "zcompdump")
  let zcompdump_temporary = ($cache | path join "zsh" $".zcompdump.($nu.pid).tmp")
  let zcompdump_shell_path = if $nu.os-info.name == "windows" {
    cygpath -u $zcompdump_temporary | str trim
  } else {
    $zcompdump_temporary
  }
  try {
    with-env { DOTFILES_ZCOMPDUMP: $zcompdump_shell_path } {
      let result = (zsh -f -c 'autoload -Uz compinit; compinit -d "$DOTFILES_ZCOMPDUMP"' | complete)
      if $result.exit_code != 0 {
        error make { msg: $"failed to generate zcompdump: ($result.stderr)" }
      }
    }
    mv --force $zcompdump_temporary $zcompdump
  } catch {|error|
    rm --force $zcompdump_temporary
    error make { msg: $error.msg }
  }

  print "shell setup complete"
}

def status [] {
  let cache = ($env.XDG_CACHE_HOME? | default ($nu.home-dir | path join ".cache") | path expand)
  let data = ($env.XDG_DATA_HOME? | default ($nu.home-dir | path join ".local" "share") | path expand)
  let bash_init = ($cache | path join "bash" "init")
  let zsh_init = ($cache | path join "zsh" "init")
  let nu_init = ($data | path join "nushell" "vendor" "autoload")
  mut targets = [
    ...(["fzf" "zoxide" "carapace" "starship"] | each {|name| $bash_init | path join $"($name).bash" })
    ...(["fzf" "zoxide" "carapace" "starship"] | each {|name| $zsh_init | path join $"($name).zsh" })
    ...(["starship" "zoxide" "carapace"] | each {|name| $nu_init | path join $"($name).nu" })
    ($cache | path join "zsh" "zcompdump")
  ]
  if $nu.os-info.name != "windows" {
    $targets = ($targets | append ($nu_init | path join "mise.nu"))
  }
  let missing = ($targets | where {|target| not ($target | path exists) })
  if not ($missing | is-empty) {
    $missing | each {|target| print --stderr $"missing: ($target)" }
    error make { msg: "shell setup is incomplete" }
  }
  print "shell setup complete"
}

def main [action: string = "generate"] {
  match $action {
    "generate" => { generate }
    "status" => { status }
    _ => { error make { msg: "usage: setup-shell.nu generate|status" } }
  }
}
