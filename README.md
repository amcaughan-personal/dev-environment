# dev-environment

My development environment, in two parts:

- **Dotfiles** (`dotfiles/`, applied by `install.sh`): shell prompt with the Git branch,
  a few aliases, mise activation, the `dc` helper, and vim settings with mouse support and a
  command cheat sheet. The same on my machine and inside every dev container.
- **Dev container base image** (`devcontainer-base/`): Ubuntu with the AWS CLI and
  [mise](https://mise.jdx.dev), for amd64 and arm64, published as
  `ghcr.io/amcaughan-personal/devcontainer-base`. Each repo's `.devcontainer/` starts from it
  (pinned by digest) and installs its own tool versions from `.tool-versions`.

## Using the dotfiles

On a machine: `git clone https://github.com/amcaughan-personal/dev-environment && dev-environment/install.sh`.

In dev containers, both tools apply them automatically:

- **VS Code** user settings:
  ```json
  "dotfiles.repository": "amcaughan-personal/dev-environment",
  "dotfiles.installCommand": "install.sh"
  ```
- **Terminal:** `dc` passes `--dotfiles-repository` to the devcontainer CLI.

Keep machine-specific settings (SSH keys, local paths) in that machine's `~/.bashrc`, and
nothing secret or personal in this repo: it's public.

## The base image

[`devcontainer-base.yml`](.github/workflows/devcontainer-base.yml) builds it for amd64 and
arm64 on every PR, and publishes it on merge to main (`:latest` and `:<commit>`). The
package is public, so anyone opening the repos can use it; that needs the org setting
*Packages → Package creation → Public*, which the GitHub Terraform provider can't manage. Repos pin
`:latest@sha256:…`; their Dependabot proposes the new digest. Every download in the
Dockerfile is checked against a SHA-256 recorded with its version.
