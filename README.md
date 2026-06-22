# dotfiles

Personal macOS development environment: shell, git, vim, terminal, and Claude
Code configuration, kept in version control and symlinked into `$HOME` by a
single `make install`. Cloning this repo and running the bootstrap below brings
a fresh machine to a known-good baseline.

## Bootstrap

```bash
git clone https://github.com/benfasoli/dotfiles ~/repos/dotfiles
cd ~/repos/dotfiles
make install
```

`make install` symlinks every tracked config from `home/` into `$HOME`. Any
real file already at one of the destination paths is replaced by a symlink, so
back up anything with unique state first.

### Per-tool targets

Re-run a single tool's links after editing:

```bash
make zsh
make git
make vim
make claude
```

`make claude` links `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, the `docs/` reference files,
and the bundled skills (`ship`, `improve-docs`).

Targets are idempotent — re-running any of them overwrites stale links cleanly.

### Brew bundle

```bash
make brew
```

Runs `brew bundle` against the repo's `Brewfile`. Not part of `make install` —
keep `install` offline-safe.

### Per-machine overrides

`~/.zshrc` and `~/.zshenv` each source an untracked `*.local` sibling
(`~/.zshrc.local` and `~/.zshenv.local`) at the end if it exists; both are
gitignored. Put machine- or host-specific exports, aliases, or PATH tweaks there
to keep them out of the tracked config — use `~/.zshenv.local` for anything that
must also be set for non-interactive shells.

## Manual setup steps

1. Install [Homebrew](https://brew.sh)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
1. Install Homebrew bundle from `Brewfile`
   ```bash
   make brew
   ```
1. Install [`uv`](https://github.com/astral-sh/uv)
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
1. Open terminal settings. Drag `One Dark.terminal` onto the Profiles list and set it as default.
1. Set terminal font to Fira Code Nerdfont.
1. Open System Settings > Keyboard. Set repeat rate to fast. Set delay until repeat to short.
1. Open System Settings > Trackpad. Enable tap to click.
1. Open System Settings > Desktop & Dock. Disable recent apps.
1. [Generate SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and configure GitHub auth
