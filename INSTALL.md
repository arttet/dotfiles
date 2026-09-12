# Installing a release set

This file is the offline guide for a published release. It requires
[dotter](https://github.com/SuperCuber/dotter). For the full guide, see <https://dotfiles.arttet.dev>.

## Verify

```sh
sha256sum --check checksums.sha256
gh attestation verify dotfiles.tar.gz --repo arttet/dotfiles
```

Every checksum must report `OK`. Stop if verification fails.

## Unpack and deploy

```sh
mkdir dotfiles && tar -xzf dotfiles.tar.gz -C dotfiles && cd dotfiles
dotter deploy --verbose --dry-run
dotter deploy --verbose --force
```

Read the dry-run before applying: it lists every symlink dotter will create or replace. The archive
already includes its vendored plugins and themes; do not run `vendir sync` inside it.

To remove only links created by dotter:

```sh
dotter undeploy --verbose --noconfirm --force
```
