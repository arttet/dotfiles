# ~/.config/nushell/modules/ai.nu

# =============================================================================
# AI CLI Launchers
# =============================================================================
#
# Short wrappers around AI coding assistants. Each checks that the binary is
# installed before running, with a friendly message otherwise.
#
# =============================================================================

# Claude Code
export def --wrapped cl [...args] {
    if (which claude | is-not-empty) {
        claude ...$args
    } else {
        print "claude not found. Install: https://docs.claude.com/en/docs/claude-code"
    }
}

# Claude Code: resume a previous session
export def --wrapped clr [...args] {
    if (which claude | is-not-empty) {
        claude --resume ...$args
    } else {
        print "claude not found. Install: https://docs.claude.com/en/docs/claude-code"
    }
}

# Claude Code: continue the most recent session
export def --wrapped clc [...args] {
    if (which claude | is-not-empty) {
        claude --continue ...$args
    } else {
        print "claude not found. Install: https://docs.claude.com/en/docs/claude-code"
    }
}

# OpenAI Codex CLI
export def --wrapped cdx [...args] {
    if (which codex | is-not-empty) {
        codex ...$args
    } else {
        print "codex not found. Install: npm install -g @openai/codex"
    }
}

# Google Gemini CLI
export def --wrapped gmn [...args] {
    if (which gemini | is-not-empty) {
        gemini ...$args
    } else {
        print "gemini not found. Install: npm install -g @google/gemini-cli"
    }
}

# OpenCode
export def --wrapped oc [...args] {
    if (which opencode | is-not-empty) {
        opencode ...$args
    } else {
        print "opencode not found. Install: https://opencode.ai"
    }
}
