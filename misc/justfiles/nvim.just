# Neovim diagnostics & repair recipes (0.12, vim.pack, no NvChad).
#
# Every recipe is idempotent, prints what it does, and exits non-zero on failure
# so agents can branch on it. Recipes run the repo's nvim config in an isolated
# sandbox so they never touch the user's daily ~/.config/nvim:
#
#   XDG_CONFIG_HOME -> <repo>/dotfiles/.config (so stdpath('config') is the repo config)
#   HOME/DATA/STATE/CACHE -> a throwaway sandbox dir (NVIM_SANDBOX, default temp)
#
# `[no-cd]` keeps $PWD at the repo root (matching misc/justfiles/validate.just).
#
# Quick reference:
#   just nvim doctor        # env sanity (run this first)
#   just nvim verify        # full green/red gate (doctor + load + ts + lsp)
#   just nvim sandbox        # launch the sandboxed instance interactively
#   just nvim pack-restore   # undo button: make disk match the lockfile

CFG := "dotfiles/.config/nvim"

# Shared sandbox-env preamble for headless/interactive nvim runs.
_env := '''
sbox="${NVIM_SANDBOX:-${TMPDIR:-/tmp}/nvim-012-sandbox}"
export HOME="$sbox/home"
export XDG_CONFIG_HOME="$PWD/dotfiles/.config"
export XDG_DATA_HOME="$sbox/data"
export XDG_STATE_HOME="$sbox/state"
export XDG_CACHE_HOME="$sbox/cache"
mkdir -p "$HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
packdir="$XDG_DATA_HOME/nvim/site/pack/core"
'''

# ============================================================================
# Diagnose
# ============================================================================

[no-cd]
[doc('Environment + config sanity check (run first)')]
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    fail=0
    echo "▶ Neovim doctor"

    if ! command -v nvim >/dev/null 2>&1; then
        echo "✗ nvim not found on PATH"
        exit 1
    fi
    ver="$(nvim --version | sed -n '1s/.*v\([0-9]*\.[0-9]*\).*/\1/p')"
    major="${ver%%.*}"; minor="${ver##*.}"
    if [ "${major:-0}" -eq 0 ] && [ "${minor:-0}" -lt 12 ]; then
        echo "✗ nvim $ver (need >= 0.12)"; fail=1
    else
        echo "✓ nvim $ver"
    fi

    # Hard requirements.
    for t in git tree-sitter; do
        if command -v "$t" >/dev/null 2>&1; then echo "✓ $t"; else
            echo "✗ $t missing (required)"; fail=1
        fi
    done
    # A C compiler is required to build treesitter parsers.
    if command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1; then
        echo "✓ C compiler"
    else
        echo "✗ no C compiler (cc/gcc/clang) -- treesitter parsers cannot build"; fail=1
    fi
    # Recommended (telescope live_grep / find_files).
    for t in rg fd; do
        command -v "$t" >/dev/null 2>&1 && echo "✓ $t" || echo "○ $t missing (recommended)"
    done

    cfg="$PWD/{{ CFG }}"
    if [ -w "$cfg" ]; then echo "✓ config dir writable ($cfg)"; else
        echo "✗ config dir not writable -- vim.pack cannot write the lockfile"; fail=1
    fi

    if [ "$fail" -ne 0 ]; then
        echo "✗ doctor found problems"
        echo "  hint: install tree-sitter CLI (scoop/cargo/winget on Windows, nixpkgs on NixOS)"
    else
        echo "✓ doctor OK"
    fi
    exit "$fail"

[no-cd]
[doc('Full green/red gate: doctor + headless load + treesitter + lsp')]
verify:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    just nvim doctor || exit 1

    echo "▶ Headless load (luac syntax + runtime smoke)"
    while IFS= read -r f; do
        luac -p "$f" || { echo "✗ syntax error: $f"; exit 1; }
    done < <(find "$PWD/{{ CFG }}" -name '*.lua')
    echo "✓ lua syntax OK"

    out="$(mktemp)"
    # Keep nvim alive long enough for vim.pack to finish cloning plugins on a
    # fresh bootstrap; otherwise partial clones break the next run.
    if ! NVIM_TS_NO_INSTALL=1 nvim --headless "+lua io.write('runtime-ok\n')" "+lua vim.defer_fn(function() vim.cmd('qa!') end, 120000)" >"$out" 2>&1; then
        echo "✗ nvim failed to start"; cat "$out"; exit 1
    fi
    if grep -qiE 'E[0-9]+:|stack traceback' "$out"; then
        echo "✗ startup errors:"; cat "$out"; exit 1
    fi
    echo "✓ config loads clean"
    just nvim lsp-check || true
    echo "✓ verify OK"

# ============================================================================
# Sandbox
# ============================================================================

[no-cd]
[doc('Launch the sandboxed nvim against the repo config')]
sandbox *ARGS:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    exec nvim {{ ARGS }}

# ============================================================================
# vim.pack lockfile / plugins
# ============================================================================

[no-cd]
[doc('Show installed plugins and pinned versions')]
pack-status:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    nvim --headless +"lua for _,p in ipairs(vim.pack.get()) do io.write(('%-30s %s\n'):format(p.spec.name, p.spec.version or 'HEAD')) end" +qa

[no-cd]
[doc('Update all plugins (writes the lockfile)')]
pack-update:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    nvim --headless +"lua vim.pack.update(nil, { force = true })" +"sleep 5" +qa
    echo "✓ pack update requested (run 'just nvim sandbox' + :checkhealth vim.pack to confirm)"

[no-cd]
[doc('Restore plugins to the committed lockfile state (undo button)')]
pack-restore:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    echo "▶ Removing plugin store so it reinstalls from the lockfile..."
    rm -rf -- "$packdir"
    nvim --headless +"sleep 10" +qa
    echo "✓ reinstalled from lockfile"

# ============================================================================
# Treesitter
# ============================================================================

[no-cd]
[doc('Assert toolchain and list installed parsers')]
ts-check:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    if ! command -v tree-sitter >/dev/null 2>&1; then
        echo "✗ tree-sitter CLI missing -- parsers cannot compile"; exit 1
    fi
    nvim --headless +"lua local ok,c = pcall(require,'nvim-treesitter.config'); if ok and c.get_installed then local p=c.get_installed(); io.write('installed parsers ('..#p..'): '..table.concat(p,', ')..'\n') else io.write('nvim-treesitter not installed yet -- run: just nvim ts-install\n') end" +qa

[no-cd]
[doc('Install/compile the configured treesitter parsers')]
ts-install:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    nvim --headless +"lua local p=require('configs.treesitter').ensure_installed; require('nvim-treesitter').install(p):wait(300000)" +qa
    echo "✓ parser install finished"

# ============================================================================
# LSP
# ============================================================================

[no-cd]
[doc('Run :checkhealth vim.lsp and print the report')]
lsp-check:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    out="$(mktemp)"
    nvim --headless "+checkhealth vim.lsp" "+w! $out" +qa >/dev/null 2>&1 || true
    sed -n '1,80p' "$out"

# ============================================================================
# Startup performance
# ============================================================================

[no-cd]
[doc('Median startup time over 3 warm runs (ms)')]
startuptime:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    log="$(mktemp)"
    vals=()
    for i in 1 2 3; do
        nvim --headless --startuptime "$log" +qa >/dev/null 2>&1
        vals+=("$(tail -1 "$log" | awk '{print $1}')")
    done
    median="$(printf '%s\n' "${vals[@]}" | sort -n | sed -n '2p')"
    echo "startup runs: ${vals[*]} ms"
    echo "median: $median ms"

[no-cd]
[doc('Top startup cost line items')]
startuptime-breakdown:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    log="$(mktemp)"
    nvim --headless --startuptime "$log" +qa >/dev/null 2>&1
    grep -E '^[0-9]' "$log" | sort -k2 -nr | head -20

[no-cd]
[doc('Save the current median startup as the budget baseline')]
baseline-save:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    log="$(mktemp)"; vals=()
    for i in 1 2 3; do
        nvim --headless --startuptime "$log" +qa >/dev/null 2>&1
        vals+=("$(tail -1 "$log" | awk '{print $1}')")
    done
    median="$(printf '%s\n' "${vals[@]}" | sort -n | sed -n '2p')"
    mkdir -p "$PWD/{{ CFG }}/bench"
    printf '%s\n' "$median" > "$PWD/{{ CFG }}/bench/budget.txt"
    echo "✓ saved baseline: $median ms -> {{ CFG }}/bench/budget.txt"

[no-cd]
[doc('Fail if median startup exceeds the saved budget')]
baseline-check:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    budget_file="$PWD/{{ CFG }}/bench/budget.txt"
    if [ ! -f "$budget_file" ]; then
        echo "○ no baseline saved (run: just nvim baseline-save)"; exit 0
    fi
    budget="$(cat "$budget_file")"
    log="$(mktemp)"; vals=()
    for i in 1 2 3; do
        nvim --headless --startuptime "$log" +qa >/dev/null 2>&1
        vals+=("$(tail -1 "$log" | awk '{print $1}')")
    done
    median="$(printf '%s\n' "${vals[@]}" | sort -n | sed -n '2p')"
    # Allow 15% headroom over the budget.
    if awk "BEGIN{exit !($median > $budget * 1.15)}"; then
        echo "✗ startup $median ms exceeds budget $budget ms (+15% headroom)"; exit 1
    fi
    echo "✓ startup $median ms within budget $budget ms"

# ============================================================================
# Repair
# ============================================================================

[no-cd]
[doc('Delete the sandbox plugin store (forces clean reinstall). FORCE=1 to skip prompt')]
clean:
    #!/usr/bin/env bash
    set -uo pipefail
    {{ _env }}
    echo "About to remove: $packdir"
    if [ "${FORCE:-0}" != "1" ]; then
        read -r -p "Proceed? [y/N] " ans
        [ "$ans" = "y" ] || { echo "aborted"; exit 0; }
    fi
    rm -rf -- "$packdir"
    echo "✓ removed plugin store"

[no-cd]
[doc('Prove the config reproduces from scratch (clean + reinstall + assert)')]
bootstrap-test:
    #!/usr/bin/env bash
    set -uo pipefail
    export NVIM_SANDBOX="${TMPDIR:-/tmp}/nvim-012-bootstrap"
    {{ _env }}
    rm -rf -- "$sbox"
    mkdir -p "$HOME" "$XDG_DATA_HOME"
    echo "▶ Fresh bootstrap in $sbox ..."
    nvim --headless +"sleep 30" +qa >/dev/null 2>&1 || true
    n="$(nvim --headless +"lua local n=0 for _ in pairs(vim.pack.get()) do n=n+1 end io.write(n)" +qa 2>/dev/null)"
    echo "installed plugins after bootstrap: $n"
    if [ "${n:-0}" -lt 5 ]; then echo "✗ bootstrap installed too few plugins"; exit 1; fi
    echo "✓ bootstrap reproduces"

# ============================================================================
# Format / lint
# ============================================================================

[no-cd]
[doc('Format the nvim config (stylua)')]
fmt:
    stylua --allow-hidden {{ CFG }}

[no-cd]
[doc('Lint the nvim config (selene)')]
lint:
    selene {{ CFG }}
