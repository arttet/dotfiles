VENDIR_LOCK_FILE := if os_family() == "windows" { "vendir.lock.windows.yml" } else { "vendir.lock.yml" }
VENDIR_WALLPAPERS_LOCK_FILE := if os_family() == "windows" { "vendir.lock.wallpapers.windows.yml" } else { "vendir.lock.wallpapers.yml" }

[doc('Synchronize external dependencies and wallpapers')]
[no-cd]
sync:
    mise run deploy:sync

[doc('Synchronize external dependencies')]
[no-cd]
config:
    mise run deploy:sync:config

[doc('Synchronize the wallpaper collections only')]
[no-cd]
wallpapers:
    mise run deploy:sync:wallpapers

[doc('Re-resolve refs and rewrite the vendir lock files')]
[no-cd]
update:
    vendir sync --lock-file {{ VENDIR_LOCK_FILE }}
    vendir sync --file vendir.wallpapers.yml --lock-file {{ VENDIR_WALLPAPERS_LOCK_FILE }}

[doc('List outdated vendir dependencies')]
[no-cd]
outdated:
    @just vendir _status vendir.yml {{ VENDIR_LOCK_FILE }} | jq '.rows' | nu --stdin -c '$in | from json | table'
    @just vendir _status vendir.wallpapers.yml {{ VENDIR_WALLPAPERS_LOCK_FILE }} | jq '.rows' | nu --stdin -c '$in | from json | table'

[doc('Write vendir dependency status as a Markdown summary')]
[no-cd]
outdated-summary:
    @just vendir _status vendir.yml {{ VENDIR_LOCK_FILE }} | jq -r '.markdown'
    @just vendir _status vendir.wallpapers.yml {{ VENDIR_WALLPAPERS_LOCK_FILE }} | jq -r '.markdown'

[private]
[no-cd]
_status config lock:
    #!/usr/bin/env bash
    set -euo pipefail
    lock_file="{{ lock }}"
    before="$(mktemp)"
    before_json="$(mktemp)"
    after_json="$(mktemp)"
    trap 'mv -- "$before" "$lock_file"; rm -f -- "$before_json" "$after_json"' EXIT

    cp -- "$lock_file" "$before"
    vendir sync --file "{{ config }}" --lock-file "$lock_file" >/dev/null

    yq -o=json "$before" > "$before_json"
    yq -o=json "$lock_file" > "$after_json"

    jq -n \
        --slurpfile spec <(yq -o=json "{{ config }}") \
        --slurpfile before "$before_json" \
        --slurpfile after "$after_json" \
        -f misc/vendir-status.jq
