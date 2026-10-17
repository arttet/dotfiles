use std/assert

def main [repo_root: path] {
  let test_home = ($repo_root | path join ".tools" "tests" "nu-contracts" "home")
  let config_root = ($repo_root | path join "dotfiles" ".config" "nushell")
  let data_home = ($test_home | path join ".local" "share")
  let cache_home = ($test_home | path join ".cache")
  let state_home = ($test_home | path join ".local" "state")

  rm --recursive --force $test_home
  mkdir $test_home
  let env_config = ($config_root | path join "env.nu")
  let config = ($config_root | path join "config.nu")

  let result = with-env {
    HOME: $test_home
    USERPROFILE: $test_home
    XDG_CONFIG_HOME: ($repo_root | path join "dotfiles" ".config")
    XDG_CACHE_HOME: $cache_home
    XDG_DATA_HOME: $data_home
    XDG_STATE_HOME: $state_home
  } {
    ^$nu.current-exe --env-config $env_config --config $config --commands 'scope commands | get name | to json' | complete
  }

  assert equal $result.exit_code 0 $result.stderr
  let commands = ($result.stdout | from json)
  assert ($commands | any {|name| $name == "ls" }) "core aliases were not loaded"
  assert not ($commands | any {|name| $name | str starts-with "history-tools" }) "history maintenance was loaded"
  assert not ($commands | any {|name| $name | str starts-with "tools " }) "tool maintenance was loaded"
  assert not ($cache_home | path exists) "startup created the cache directory"
  assert not ($state_home | path exists) "startup created the state directory"

  print "nushell shell contracts passed"
}
