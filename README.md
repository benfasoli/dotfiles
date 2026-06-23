# dotfiles

Personal macOS development environment: shell, git, vim, terminal, and Claude
Code configuration, kept in version control and symlinked into `$HOME` by a
single `make install`.

## Fresh machine setup

On a brand-new Mac, run these steps in order:

1. Install [Homebrew](https://brew.sh)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
1. Clone and symlink config
   ```bash
   git clone https://github.com/benfasoli/dotfiles ~/repos/dotfiles
   cd ~/repos/dotfiles
   make install
   ```
1. Install CLI tools from `Brewfile`
   ```bash
   make brew
   ```
1. Install [`uv`](https://github.com/astral-sh/uv) (Python toolchain)
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
1. [Generate SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and configure GitHub auth
1. Open Terminal → Settings. Drag `One Dark.terminal` onto the Profiles list and set it as default.
1. Set terminal font to Fira Code Nerd Font.
1. Open System Settings → Keyboard. Set key repeat rate to fast, delay until repeat to short.
1. Open System Settings → Trackpad. Enable tap to click.
1. Open System Settings → Desktop & Dock. Disable "Show recent applications in Dock."

## Syncing config on an existing machine

`make install` symlinks every tracked config from `home/` into `$HOME`. Any
real file already at one of the destination paths is replaced by a symlink, so
back up anything with unique state first. Targets are idempotent — re-running
any of them overwrites stale links cleanly.

```bash
cd ~/repos/dotfiles
make install
```

Re-run a single tool's links after editing:

```bash
make zsh
make git
make vim
make claude   # links CLAUDE.md, settings.json, docs/, and bundled skills
```

Install or update CLI tools:

```bash
make brew
```

`make brew` is not part of `make install` — kept separate so `install` stays
offline-safe.

## Per-machine overrides

`~/.zshrc` and `~/.zshenv` each source an untracked `*.local` sibling
(`~/.zshrc.local` and `~/.zshenv.local`) at the end if it exists; both are
gitignored. Put machine- or host-specific exports, aliases, or PATH tweaks there
to keep them out of the tracked config. Use `~/.zshenv.local` for anything that
must be set for non-interactive shells (environment variables picked up by
launch agents, build tools, etc.).
