use std/assert

def main [setup_home: path] {
  let bash_init = ($setup_home | path join ".cache" "bash" "init")

  for file in (ls $bash_init | where type == file | get name) {
    let result = (bash -n $file | complete)
    assert equal $result.exit_code 0 $"invalid Bash cache ($file): ($result.stderr)"
  }

  print "generated shell contracts passed"
}
