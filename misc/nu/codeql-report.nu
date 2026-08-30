# Render a CodeQL CSV result set as a Markdown table.
#
# `codeql database interpret-results --format=csv` emits headerless rows; the column names below are
# that format's fixed order. Kept as a script so the same command reproduces the CI output locally:
#
#   nu misc/nu/codeql-report.nu .tools/codeql/actions.csv actions

def main [csv: path, label: string] {
  let rows = (open --raw $csv | from csv --noheaders)

  if ($rows | is-empty) {
    print $"CodeQL ($label): no findings."
  } else {
    $rows
    | rename rule description severity message file line col end_line end_col
    | select severity rule file line message
    | to md --pretty
  }
}
