# Installing a release set

This describes the published archive. To work on the dotfiles instead, clone the repository and follow
[the guide](https://arttet.github.io/dotfiles/guide/) — the archive is for deploying, not developing.

A release set is six files:

| File               | What it is                                          |
| :----------------- | :-------------------------------------------------- |
| `dotfiles.tar.gz`  | the configuration tree and its vendored plugins     |
| `sbom.spdx.json`   | what is inside                                      |
| `licenses.json`    | where each component came from and under what terms |
| `vex.openvex.json` | which scanner findings do not apply here, and why   |
| `manifest.json`    | which commit and which vendir state produced this   |
| `checksums.sha256` | that nothing changed in transit                     |

## 1. Check it before you trust it

```sh
sha256sum --check checksums.sha256
```

Every file must report `OK`. If any does not, stop — you have a corrupted or tampered download, and
nothing below is safe to run.

The archive is built by GitHub Actions with build provenance, so you can also verify who built it and
from what, without trusting the checksums file itself:

```sh
gh attestation verify dotfiles.tar.gz --repo arttet/dotfiles
```

To see what you are about to deploy:

```sh
jq -r '.source.commit, .build.vendir.lock.sha256' manifest.json
jq -r '.warnings[]' licenses.json
```

The license warnings are informational. Some vendored components are GPL-3.0 or AGPL-3.0 while this
repository is MIT; they are used deliberately, and the point is that you can see them.

## 2. Unpack

```sh
mkdir dotfiles && tar -xzf dotfiles.tar.gz -C dotfiles && cd dotfiles
```

You get three things: `dotfiles/` (the configuration), `.dotter/` (the deployment map), and this file.
That is the layout `dotter` expects, and you run it from this directory.

**The vendored plugins and themes are already inside the archive.** Do not run `vendir sync` — there is
no `vendir.yml` here, and the versions in the archive are the ones the manifest and the SBOM describe.

## 3. Deploy

`dotter` is the only deployer, on every platform. Install it first — it is a single binary:

```sh
mise use -g dotter          # or: cargo install dotter
```

Preview before touching anything in your home directory:

```sh
dotter deploy --verbose --dry-run
```

Read that output. It lists every symlink that will be created and every file that will be replaced. If
you already have configuration at those paths, back it up now.

Then apply:

```sh
dotter deploy --verbose --force
```

To choose a subset instead of everything, edit `packages` in `.dotter/local.toml`. The `default`
package covers `~/.config`; `bash`, `zsh` and the per-tool packages are opt-in. `.dotter/global.toml`
is the full map if you want to read what goes where.

## 4. Undo

```sh
dotter undeploy --verbose --noconfirm --force
```

This removes the links dotter created and leaves everything else alone.

## What this archive does not include

The tools themselves. Nushell, Yazi, Zellij, Starship and the rest are configured here but installed
separately — through `mise`, your package manager, or however you prefer. The configuration degrades
quietly when a tool is missing rather than failing at shell startup.
