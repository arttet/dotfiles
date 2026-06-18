# Gemini CLI Instructions

Read and follow [AGENTS.md](./AGENTS.md) before working in this repository. It is the canonical source of truth for the
project architecture, commands, coding standards, verification requirements, security policy, and GitHub workflow.

## Precedence

- Repository-wide rules come from [AGENTS.md](./AGENTS.md).
- A nested `AGENTS.md` adds instructions for its subtree; the nearest applicable file takes precedence for local details.
- This file is only a Gemini CLI entry point. Do not copy repository rules here.
- If this file conflicts with `AGENTS.md`, follow `AGENTS.md`.

## Gemini-Specific Notes

- Use Gemini CLI tools and MCP servers only when they materially improve correctness or access to relevant context, while
  preserving the workflow and safety boundaries defined in `AGENTS.md`.
- Before changing Gemini configuration, inspect the nearby files and keep machine-local settings and credentials out of
  version control.
- Report verification results and unresolved risks using the reporting requirements in `AGENTS.md`.
