# Report which pinned vendir revisions are behind their upstream refs.
#
# vendir has no "check for updates" mode: the only way to learn the current upstream revision is to
# re-resolve, and that rewrites the lock file. So the lock is copied aside first and put back
# afterwards -- including when the sync fails -- because a status report must never move a pin.
#
#   nu misc/nu/vendir-status.nu vendir.yml vendir.lock.yml
#   nu misc/nu/vendir-status.nu vendir.yml vendir.lock.yml --format markdown

def main [
  config: path # vendir configuration to re-resolve
  lock: path # lock file it owns; restored before this returns
  --format: string = "table" # table or markdown
] {
  let backup = (mktemp --tmpdir --suffix .yml)
  let spec_json = (mktemp --tmpdir --suffix .json)
  let before_json = (mktemp --tmpdir --suffix .json)
  let after_json = (mktemp --tmpdir --suffix .json)

  cp $lock $backup

  let sync = (^vendir sync --file $config --lock-file $lock | complete)

  if $sync.exit_code != 0 {
    cp $backup $lock
    rm --force $backup $spec_json $before_json $after_json
    error make { msg: $"vendir could not re-resolve ($config):(char newline)($sync.stderr)" }
  }

  let report = try {
    ^yq -o=json $config | save --force $spec_json
    ^yq -o=json $backup | save --force $before_json
    ^yq -o=json $lock | save --force $after_json

    ^jq -n --slurpfile spec $spec_json --slurpfile before $before_json --slurpfile after $after_json -f misc/jq/vendir-status.jq
  } catch { |err|
    cp $backup $lock
    rm --force $backup $spec_json $before_json $after_json
    error make { msg: $"vendir status failed for ($config): ($err.msg)" }
  }

  cp $backup $lock
  rm --force $backup $spec_json $before_json $after_json

  let parsed = ($report | from json)

  if $format == "markdown" {
    print $parsed.markdown
  } else {
    print ($parsed.rows | table)
  }
}
