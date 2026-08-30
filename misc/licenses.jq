# License inventory of one release set.
#
# Answers a question the SBOM cannot: what code is in this archive, where did it come from, and under
# what terms. It reports rather than blocks -- several vendored components carry GPL-3.0 or AGPL-3.0
# and are used deliberately, so the useful output is visibility, not a red build. A component with no
# license file is a finding too, and is recorded as such instead of being silently dropped.
#
# Inputs: $scan (trivy --scanners license --license-full --format json), $components ([{path, origin}]),
#         $files (file list, one path per line), $root (scan root), $allowed (comma-separated SPDX ids).

def allowed_set:
  $allowed | split(",") | map(ascii_downcase | ltrimstr(" ") | rtrimstr(" "));

def acceptable($names):
  ($names | length) > 0 and all($names[]; ascii_downcase | IN(allowed_set[]));

# Trivy reports paths relative to the scan root, while component paths are repository-relative, so
# every finding is re-rooted before anything is matched against it.
def findings:
  ($scan[0].Results // [])
  | map(.Licenses // [])
  | add // []
  | map(select(.FilePath != null))
  | map({path: ($root + "/" + .FilePath), name: (.Name // "unknown")});

def file_lines:
  $files | split("\n") | map(select(length > 0));

# A finding is attributed to the longest component path that prefixes it, so nested vendored trees
# land on the right owner rather than on their parent.
def owner($path; $paths):
  $paths
  # The element has to be bound before `startswith`, because inside its argument `.` is the string
  # being tested, not the array element -- comparing a path against itself would never match.
  | map(. as $candidate | select($path | startswith($candidate + "/")))
  | sort_by(length)
  | last;

def file_count($component; $lines):
  $lines | map(select(startswith($component + "/"))) | length;

($components[0] // []) as $declared
| ($declared | map(.path)) as $paths
| file_lines as $lines
| ($lines | INDEX(.)) as $in_set
# A license only matters if its file is actually in this archive. Without this the dotfiles scan
# would also report the wallpaper collections, which sit on disk but ship in the other set.
| (findings | map(select($in_set[.path]))) as $all
# Findings that belong to no vendored component are repository-owned; they are grouped by the
# directory holding the license file so they appear in the inventory instead of vanishing.
| ($all
    | map(select(owner(.path; $paths) == null))
    | map(. + {dir: (.path | sub("/[^/]*$"; ""))})
    | group_by(.dir)
    | map({
        path: .[0].dir,
        origin: null,
        licenses: (map(.name) | unique),
        files: file_count(.[0].dir; $lines),
      })
  ) as $repository_owned
| ([
    $declared[]
    | .path as $path
    | {
        path: $path,
        origin: .origin,
        licenses: ($all | map(select(owner(.path; $paths) == $path)) | map(.name) | unique),
        files: file_count($path; $lines),
      }
  ] + $repository_owned | sort_by(.path)) as $components_report
| {
    schemaVersion: 1,
    allowed: allowed_set,
    components: $components_report,
    warnings: [
      $components_report[]
      | if (.licenses | length) == 0 then
          "\(.path): no license file found\(if .origin then " (\(.origin))" else "" end)"
        elif (acceptable(.licenses) | not) then
          "\(.path): \(.licenses | join(", ")) is outside \($allowed)\(if .origin then " (\(.origin))" else "" end)"
        else
          empty
        end
    ],
  }
