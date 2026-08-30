# Identity of one release set.
#
# The commit SHA is deliberately not baked into file names: identity belongs in the manifest, where
# it can be checked, not in a name that is trivially renamed. The vendir block is here because the
# archive content depends on more than the commit -- the same tree with a different lock file yields
# different bytes -- and it is also what tells the two sets apart without any exclusion list.
#
# Inputs: $set, $repository, $commit, $tree, $ref, $sourceDateEpoch, $vendirConfig, $vendirConfigSha,
#         $vendirLock, $vendirLockSha, $fileCount, $hashes (raw `sha256sum` output).

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
  | map(
      # `sha256sum` separates the digest from the name with two spaces, or a space and `*` in binary
      # mode; splitting on the first run of spaces covers both without dropping names that contain one.
      capture("^(?<sha256>[0-9a-f]{64}) [ *](?<name>.+)$")
      | {name: .name, sha256: .sha256}
    );

artifacts($hashes) as $artifacts
| if ($artifacts | length) == 0 then error("no artifact hashes were supplied") else . end
| {
    schemaVersion: 1,
    set: $set,
    source: {
      repository: $repository,
      commit: require_hex($commit; 40; "source.commit"),
      tree: require_hex($tree; 40; "source.tree"),
      ref: $ref,
    },
    build: {
      sourceDateEpoch: ($sourceDateEpoch | tonumber),
      vendir: {
        config: {
          file: $vendirConfig,
          sha256: require_hex($vendirConfigSha; 64; "build.vendir.config.sha256"),
        },
        lock: {
          file: $vendirLock,
          sha256: require_hex($vendirLockSha; 64; "build.vendir.lock.sha256"),
        },
      },
      fileCount: ($fileCount | tonumber),
    },
    artifacts: $artifacts,
  }
