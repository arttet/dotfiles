---
# https://vitepress.dev/reference/default-theme-home-page
layout: home
hero:
  name: "Dotfiles"
  text: "Secure. Fast. Modern."
  tagline: "One repository for a shell, terminal, editor, and AI-agent setup — symlinked into place with dotter and validated in CI on every change."
  actions:
    - theme: brand
      text: Get Started
      link: /guide/
features:
  - icon: 🚀
    title: Benchmarked Startup
    details: Shell startup is measured with hyperfine on every change and compared against a committed baseline — a regression past the threshold fails CI.
  - icon: ⚡
    title: Cross-Platform Native
    details: The same configuration deploys on <strong>Windows</strong>, <strong>macOS</strong>, and <strong>Linux</strong>. PowerShell, Bash, Zsh, and Nushell share one set of aliases and functions, so your workflow travels with you.
  - icon: 🛠
    title: One Toolchain
    details: Every tool is pinned and installed by <strong>mise</strong> — <strong>Neovim (vim.pack)</strong>, <strong>WezTerm</strong>, <strong>Starship</strong>, <strong>Zoxide</strong>, <strong>Yazi</strong> — and the same pinned versions run locally and in CI.
  - icon: 🔐
    title: Security First
    details: Every push runs TruffleHog secret scanning, Trivy, and ClamAV. Agent tools follow default-deny permission rules that keep credentials, SSH keys, and kubeconfigs unreadable.
  - icon: 🧩
    title: Modular Architecture
    details: Configuration is split into small per-topic files — shell logic lives in <code>shell.d</code> fragments, one directory per tool — so a change touches exactly one file.
  - icon: 🎨
    title: Aesthetic Consistency
    details: One theme family (Catppuccin/Gruvbox) is applied across the shell, editor, terminal, and multiplexer, with light and dark variants kept in sync.
---
