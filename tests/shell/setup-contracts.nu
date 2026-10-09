use std/assert

def main [setup_home: path] {
  let bash_init = ($setup_home | path join ".cache" "bash" "init")
  let zsh_init = ($setup_home | path join ".cache" "zsh" "init")

  for file in (ls $bash_init | where type == file | get name) {
    let result = (bash -n $file | complete)
    assert equal $result.exit_code 0 $"invalid Bash cache ($file): ($result.stderr)"
  }
  for file in (ls $zsh_init | where type == file | get name) {
    let result = (zsh -n $file | complete)
    assert equal $result.exit_code 0 $"invalid Zsh cache ($file): ($result.stderr)"
  }

  print "generated shell contracts passed"
}
