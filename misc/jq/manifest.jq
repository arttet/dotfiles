# Identity of one release set.
#
# The commit SHA is deliberately not baked into file names: identity belongs in the manifest, where
# it can be checked, not in a name that is trivially renamed. The vendir block is here because the
# archive content depends on more than the commit -- the same tree with a different lock file yields
# different bytes -- and it is also what tells the two sets apart without any exclusion list.
#
# Everything but the hash list arrives through the environment, which is what keeps the calling task
# down to a single readable command instead of a dozen --arg flags.
#
# Environment: ARTIFACT_SET, GITHUB_REPOSITORY, COMMIT, TREE, REF, SOURCE_DATE_EPOCH,
#              VENDIR_CONFIG, VENDIR_CONFIG_SHA, VENDIR_LOCK, VENDIR_LOCK_SHA, FILE_COUNT.
# Input:       $hashes (raw `sha256sum` output).

def hex($length):
  test("^[0-9a-f]{" + ($length | tostring) + "}$");

def require_hex($value; $length; $label):
  if ($value | hex($length)) then $value
  else error($label + " is not a " + ($length | tostring) + "-character hex digest: " + $value)
  end;

def artifacts($raw):
  $raw
  | split("\n")
  | map(select(length > 0))
  # `sha256sum` separates the digest from the name with two spaces, or a space and `*` in binary
  # mode; matching both keeps names that contain a space intact.
  | map(capture("^(?<sha256>[0-9a-f]{64}) [ *](?<name>.+)$") | {name: .name, sha256: .sha256});

artifacts($hashes) as $artifacts
| if ($artifacts | length) == 0 then error("no artifact hashes were supplied") else . end
| {
    schemaVersion: 1,
    set: $ENV.ARTIFACT_SET,
    source: {
      repository: ($ENV.GITHUB_REPOSITORY // "arttet/dotfiles"),
      commit: require_hex($ENV.COMMIT; 40; "source.commit"),
      tree: require_hex($ENV.TREE; 40; "source.tree"),
      ref: ($ENV.REF // "refs/heads/main"),
    },
    build: {
      sourceDateEpoch: ($ENV.SOURCE_DATE_EPOCH | tonumber),
      vendir: {
        config: {
          file: $ENV.VENDIR_CONFIG,
          sha256: require_hex($ENV.VENDIR_CONFIG_SHA; 64; "build.vendir.config.sha256"),
        },
        lock: {
          file: $ENV.VENDIR_LOCK,
          sha256: require_hex($ENV.VENDIR_LOCK_SHA; 64; "build.vendir.lock.sha256"),
        },
      },
      fileCount: ($ENV.FILE_COUNT | tonumber),
    },
    artifacts: $artifacts,
  }
