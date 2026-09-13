# Agent Skills

Skills are installed dynamically rather than committed to this repository. The declarative list lives
in the deployed mise configuration, so a machine can restore it without treating downloaded content as
dotfiles source code.

## Install

After deploying the global mise configuration and installing its toolchain, run:

```sh
mise run setup:skills
```

## Managed skills

| Repository                                              | Skills                                                                                                                                                                                                                                                                        | Agents                                  |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| [obra/superpowers](https://github.com/obra/superpowers) | brainstorming, systematic-debugging, test-driven-development, requesting-code-review, receiving-code-review, verification-before-completion, writing-plans, executing-plans, subagent-driven-development, dispatching-parallel-agents, using-git-worktrees, using-superpowers | Codex, Claude Code, OpenCode, Kimi Code |
| [pr-pm/prpm](https://github.com/pr-pm/prpm)             | human-writing                                                                                                                                                                                                                                                                 | Claude Code                             |
| [Hunk](https://www.hunk.dev/docs/agents/review-skill/)  | hunk-review                                                                                                                                                                                                                                                                   | Loaded on demand with `hunk skill path` |

## Hunk reviews

See the [Hunk agent review documentation](https://www.hunk.dev/docs/agents/review-with-an-agent/).
