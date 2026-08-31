# Attribute shell startup cost to individual configuration fragments.
#
# hyperfine times whole processes, not functions, and bash and zsh share no profiler between them. The
# cost of a fragment is recovered by difference instead: time a shell that sources the first k
# fragments, then the first k+1, and subtract. One hyperfine run measures every prefix under the same
# conditions.
#
# The result ranks fragments, it does not budget them. Fragments are not independent — `90-tools` is
# cheaper once `50-completion` has run — so the deltas need not sum to the configured total. Use this
# to find the outlier, then measure that fragment on its own.
#
#   nu misc/nu/shell-profile.nu bash
#   nu misc/nu/shell-profile.nu zsh --format markdown

const CONFIG = "dotfiles/.config"

# glob returns absolute native paths, and on Windows those carry backslashes that bash reads as escapes
# once they land inside `source '...'`. Repository-relative forward slashes work in every shell here.
def relative []: list<string> -> list<string> {
  $in | each { |p| $p | path relative-to $env.PWD | str replace --all (char path_sep) "/" } | sort
}

# Mirrors how the shells load: profile.d on login, then shell.d, then the shell-specific directory.
def fragments [shell: string]: nothing -> list<string> {
  let common = [
    ...(glob $"($CONFIG)/shell/profile.d/*.sh" | relative)
    ...(glob $"($CONFIG)/shell/shell.d/*.sh" | relative)
  ]

  let own = match $shell {
    "bash" => (glob $"($CONFIG)/bash/bash.d/*.bash" | relative)
    "zsh" => (glob $"($CONFIG)/zsh/zsh.d/*.zsh" | relative)
    _ => { error make { msg: $"unsupported shell: ($shell); expected bash or zsh" } }
  }

  [...$common ...$own]
}

# `-i` because several fragments return early in a non-interactive shell, and the startup they cost a
# real session is the number worth having. The rc files themselves stay out: this measures fragments.
#
# `exit 0`, not a bare `exit`: fragments routinely end on a guard such as
# `command -v tldr >/dev/null && alias man=tldr`, which returns 1 wherever that tool is absent. A bare
# `exit` would inherit it and hyperfine would abort on a machine that merely lacks an optional tool.
# The real shells do not see this because the rc for-loop that sources them ends on 0.
def invocation [shell: string, files: list<string>]: nothing -> string {
  let sourced = ($files | each { |f| $"source '($f)'" } | append "exit 0" | str join "; ")

  match $shell {
    "bash" => $"bash --noprofile --norc -i -c \"($sourced)\""
    "zsh" => $"zsh -f -i -c \"($sourced)\""
  }
}

def main [
  shell: string # bash or zsh
  --hyperfine: string = "hyperfine --warmup 2 --runs 10 --shell=none" # kept in step with vars.hyperfine
  --format: string = "table" # table or markdown
] {
  let files = (fragments $shell)

  if ($files | is-empty) {
    error make { msg: $"no ($shell) fragments found under ($CONFIG); run this from the repository root" }
  }

  let export = (mktemp --tmpdir --suffix .json)

  # Prefix 0 is the bare shell, so the first fragment has something to be measured against.
  let commands = (
    0..($files | length)
    | each { |k|
        let prefix = ($files | first $k)
        let name = if $k == 0 { "(bare shell)" } else { $files | get ($k - 1) | path basename }
        [--command-name $name (invocation $shell $prefix)]
      }
    | flatten
  )

  let runner = ($hyperfine | split row " ")

  # Streamed rather than captured through `complete`: this takes minutes, and hyperfine's own progress
  # is the only sign it is alive. Its diagnostics reach the terminal directly on the way past.
  let failed = try {
    ^($runner | first) ...($runner | skip 1) --export-json $export ...$commands
    false
  } catch {
    true
  }

  if $failed {
    rm --force $export
    error make { msg: $"hyperfine could not measure ($shell); its output above says why" }
  }

  let results = (open $export | get results)
  rm --force $export

  # `noise_ms` is the two measurements' deviations added in quadrature. A cost smaller than it is not
  # distinguishable from the runner's own jitter, and a negative cost means exactly that — the method
  # reporting its own floor rather than a fragment that makes the shell faster.
  let rows = (
    $results
    | enumerate
    | skip 1
    | each { |it|
        let previous = ($results | get ($it.index - 1))
        let cost = (($it.item.median - $previous.median) * 1000)
        let noise = ((($it.item.stddev * $it.item.stddev) + ($previous.stddev * $previous.stddev)) | math sqrt) * 1000

        {
          fragment: $it.item.command,
          cost_ms: ($cost | math round --precision 1),
          noise_ms: ($noise | math round --precision 1),
          reliable: (($cost | math abs) > $noise),
          cumulative_ms: (($it.item.median * 1000) | math round --precision 1),
        }
      }
  )

  let total = (($results | last | get median) * 1000 | math round --precision 1)
  let bare = (($results | first | get median) * 1000 | math round --precision 1)

  if $format == "markdown" {
    print $"## ($shell) startup by fragment"
    print ""
    print $"Bare shell ($bare) ms, fully configured ($total) ms."
    print ""
    print ($rows | sort-by cost_ms --reverse | to md --pretty)
  } else {
    print $"bare shell: ($bare) ms    configured: ($total) ms"
    print ($rows | sort-by cost_ms --reverse | table)
  }
}
