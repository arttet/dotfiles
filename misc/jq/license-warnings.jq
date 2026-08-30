# Print one line per license warning, as a GitHub annotation when running in Actions and plainly
# otherwise. Reading GITHUB_ACTIONS through $ENV keeps the shell out of it: no prefix variable, no
# conditional, nothing to quote.
($ENV.GITHUB_ACTIONS | if . == null or . == "" then "" else "::warning title=License::" end) as $prefix
| .warnings[]
| $prefix + .
