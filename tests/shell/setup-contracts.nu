use std/assert

# Resolve the same directories as setup-shell.nu so the contract checks what setup:shell wrote.
def main [] {
  let cache = ($env.XDG_CACHE_HOME? | default ($nu.home-dir | path join ".cache") | path expand)
  let data = ($env.XDG_DATA_HOME? | default ($nu.home-dir | path join ".local" "share") | path expand)

  for file in (ls ($cache | path join "bash" "init") | where type == file | get name) {
    let result = (bash -n $file | complete)
    assert equal $result.exit_code 0 $"invalid Bash cache ($file): ($result.stderr)"
  }

  let zsh_init = ($cache | path join "zsh" "init")
  if (which zsh | is-not-empty) and ($zsh_init | path exists) {
    # Skip the .zwc files zcompile writes next to each script.
    for file in (ls $zsh_init | where type == file and name ends-with ".zsh" | get name) {
      let result = (zsh -n $file | complete)
      assert equal $result.exit_code 0 $"invalid Zsh cache ($file): ($result.stderr)"
    }
  }

  for file in (ls ($data | path join "nushell" "vendor" "autoload") | where type == file | get name) {
    assert (nu-check $file) $"invalid Nushell autoload ($file)"
  }

  print "generated shell contracts passed"
}
