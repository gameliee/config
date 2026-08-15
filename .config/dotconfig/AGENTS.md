# Dotfiles

Bare git repo at `~/.cfg`, work-tree `$HOME`, one branch: `main`.
Everything goes through the `config` alias.

## What lives here

**Can a command regenerate the file?**

- **Yes** → don't track it. Put the command under [Replicate](#replicate).
- **No** (hand-tuned: keybindings, nvim configs, karabiner) → track it.

Machine- or work-specific files (credentials, per-host paths) are never
tracked, and get no note either.

One branch for every machine. Per-machine differences go in untracked
`*.local` files or a conditional inside the config itself — not a branch.

## Bootstrap a new machine

```sh
git clone --bare https://github.com/gameliee/config.git ~/.cfg
alias config='git --git-dir=$HOME/.cfg --work-tree=$HOME'   # also add to ~/.zshrc.local (untracked)
config checkout main              # fresh machine only; refuses if it would overwrite
config config status.showUntrackedFiles no
```

One remote: `origin` = `gameliee/config` (public). Commits are scanned for
credentials by gitleaks — see `.pre-commit-config.yaml` and the `leak-scan`
workflow.

## Replicate

One setup on every machine, so the muscle memory carries — same keys, same
tools, same behaviour everywhere. A machine may differ, but on purpose.

Tracked files carry the settings themselves. Below is the rest of what should
be true, with the commands that usually get there. Read the intent, check what
the machine actually has, close the gap. Re-run this whenever the repo moves.

**Every agent in use should have its herdr integration installed and current.**
Here that means pi, claude, codex and opencode.

```sh
herdr integration status
herdr integration install pi
herdr integration install claude
herdr integration install codex
herdr integration install opencode
```

**`local-nav` should be linked.** Its files are tracked; the link is not — herdr
does not discover a plugin directory on its own.

```sh
herdr plugin list
herdr plugin link ~/.config/herdr/plugins/local-nav
```

**pi should have these packages.**

```sh
pi list
pi install npm:pi-mcp-adapter
pi install npm:pi-web-search
pi install npm:pi-codex-goal
pi install npm:pi-tool-display
pi install git:github.com/DietrichGebert/ponytail
pi install https://github.com/gsanhueza/pi-token-speed
```

**gitleaks should run on every commit.** The hook lands in `~/.cfg/hooks/`,
inside the git directory, which git cannot track.

```sh
GIT_DIR="$HOME/.cfg" GIT_WORK_TREE="$HOME" pre-commit install
```

**pi's own settings stay untracked.** pi rewrites that file, so a tracked copy
would publish the model list every time the settings TUI is used. These are the
values that differ from pi's defaults — re-apply in `pi config`:

| setting | value |
| --- | --- |
| compaction | off (pi defaults to on) |
| hide thinking block | on |
| show cache-miss notices | on |
| collapse changelog | on |
| editor padding X | 1 |
| theme | light/dark |

## Hazards for agents

- **Never `config switch` or `config checkout <branch>`** on an existing
  machine — the work-tree is `$HOME`, so it rewrites the home directory. Use
  `git worktree` for branch work.
- `status.showUntrackedFiles=no` is set, so untracked files never appear in
  `config status`. Intentional. No `.gitignore` needed.
- Use the `config` alias. Raw `git --git-dir=...` without `--work-tree` fails.
