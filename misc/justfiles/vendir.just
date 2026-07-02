VENDIR_LOCK_FILE := if os_family() == "windows" { "vendir.lock.windows.yml" } else { "vendir.lock.yml" }

[doc('Synchronize external plugins and dependencies')]
[no-cd]
sync:
    vendir sync --locked --lock-file {{ VENDIR_LOCK_FILE }}

[doc('Re-resolve refs and rewrite the vendir lock file')]
[no-cd]
update:
    vendir sync --lock-file {{ VENDIR_LOCK_FILE }}

[doc('List outdated vendir dependencies')]
[no-cd]
outdated:
    @just vendir _status | jq '.rows' | nu --stdin -c '$in | from json | table'

[doc('Write vendir dependency status as a Markdown summary')]
[no-cd]
outdated-summary:
    @just vendir _status | jq -r '.markdown'

[private]
[no-cd]
_status:
    #!/usr/bin/env bash
    set -euo pipefail
    lock_file="{{ VENDIR_LOCK_FILE }}"
    before="$(mktemp)"
    before_json="$(mktemp)"
    after_json="$(mktemp)"
    trap 'mv -- "$before" "$lock_file"; rm -f -- "$before_json" "$after_json"' EXIT

    cp -- "$lock_file" "$before"
    vendir sync --lock-file "$lock_file" >/dev/null

    yq -o=json "$before" > "$before_json"
    yq -o=json "$lock_file" > "$after_json"

    jq -n \
        --slurpfile spec <(yq -o=json vendir.yml) \
        --slurpfile before "$before_json" \
        --slurpfile after "$after_json" \
        -f misc/vendir-status.jq
