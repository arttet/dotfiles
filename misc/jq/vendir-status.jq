def repo_name($url):
  ($url | sub("^https://github.com/"; "") | sub("\\.git$"; ""));

# Keyed by the spec's path spelling: vendir writes backslashes into the Windows lock file, so without
# normalizing here every row joins against nothing and reports a null sha as "up to date".
def sha_by_path($lock):
  reduce $lock.directories[] as $dir ({}; .[$dir.path | gsub("\\\\"; "/")] = $dir.contents[0].git.sha);

def short($sha):
  $sha[0:7];

(sha_by_path($before[0])) as $before_shas
| (sha_by_path($after[0])) as $after_shas
| [
    $spec[0].directories[]
    | .path as $path
    | .contents[0].git.url as $url
    | {
        path: $path,
        repo: repo_name($url),
        before: $before_shas[$path],
        after: $after_shas[$path],
        upToDate: ($before_shas[$path] == $after_shas[$path])
      }
  ] as $rows
| {
    rows: $rows,
    markdown: (
      [
        "## Vendir dependency status",
        "",
        "| Path | Repository | Locked (before) | Origin (now) | Status |",
        "|---|---|---|---|---|",
        ($rows[]
          | "| `\(.path)` | \(.repo) | `\(short(.before))` | `\(short(.after))` | \(if .upToDate then "up to date" else "**updated**" end) |")
      ] | join("\n")
    )
  }
