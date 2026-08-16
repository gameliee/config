# Dotfiles

Bare git repo at `~/.cfg`, work-tree `$HOME`. `main` is upstream; each machine
sits on its own branch (`macos`, `linux`). Everything goes through the `config`
alias.

## What lives here

**Can a command regenerate the file?**

- **Yes** → don't track it. Put the command under [Replicate](#replicate).
- **No** (hand-tuned: keybindings, nvim configs, karabiner) → track it.

Machine- or work-specific files (credentials, per-host paths) are never
tracked, and get no note either.

## Branches

`main` holds what every machine shares. A machine lives on its own branch and
**merges down** from `main`; shared work goes **up** by PR into `main`.

For a per-machine difference, in order:

1. **An untracked `*.local` file** the config sources (`~/.zshrc.local`). Best —
   `main` stays the single copy of the shared file.
2. **A conditional inside the tracked file** (`if [[ $(uname) == Darwin ]]`).
3. **A divergence on the machine branch.** Only when neither works — plenty of
   software has no include mechanism (karabiner.json, ghostty is partial).
   Fine, but know the cost: `main` never touched the file, so every later
   `merge origin/main` silently keeps your version and reports no conflict.
   Divergences don't announce themselves — check with
   `config diff HEAD origin/main` after merging, and leave a note here for any
   that are deliberate.

### Deliberate divergences

| Branch | File | Why |
|---|---|---|
| _(none recorded)_ | | |

## Bootstrap a new machine

```sh
git clone --bare https://github.com/gameliee/config.git ~/.cfg
alias config='git --git-dir=$HOME/.cfg --work-tree=$HOME'   # also add to ~/.zshrc.local (untracked)
config checkout -b <machine> origin/main   # fresh machine only; refuses if it would overwrite
config config status.showUntrackedFiles no
```

One remote: `origin` = `gameliee/config` (public). Commits are scanned for
credentials by gitleaks — see `.pre-commit-config.yaml` and the `leak-scan`
workflow.

## Replicate

One setup on every machine — same keys, same tools, muscle memory carries.
Differences are deliberate, not drift. Check state, close the gap.

```sh
# herdr integrations, current on every agent in use here
herdr integration status
herdr integration install pi
herdr integration install claude
herdr integration install codex
herdr integration install opencode

# local-nav: files are tracked, the link is not
herdr plugin list
herdr plugin link ~/.config/herdr/plugins/local-nav

# pi packages
pi list
pi install npm:pi-mcp-adapter
pi install npm:pi-web-search
pi install npm:pi-codex-goal
pi install npm:pi-tool-display
pi install git:github.com/DietrichGebert/ponytail
pi install https://github.com/gsanhueza/pi-token-speed

# gitleaks: the hook lands in ~/.cfg/hooks, which git cannot track
GIT_DIR="$HOME/.cfg" GIT_WORK_TREE="$HOME" pre-commit install
```

pi settings stay untracked — pi rewrites that file and would publish the model
list with it. Non-default, re-apply in `pi config`: compaction off,
hideThinkingBlock, showCacheMissNotices, collapseChangelog on, editorPaddingX 1,
theme light/dark.

## Hazards for agents

- **Never `config switch` or `config checkout <branch>`** on an existing
  machine — the work-tree is `$HOME`, so it rewrites the home directory. Use
  `git worktree` for branch work. Merging into the current machine branch is
  safe; switching off it is not.
- **A merge that reports no conflict is not a merge that took everything.** If
  only the machine branch touched a file since the merge-base, git keeps the
  machine version without asking. `config diff HEAD origin/main` after every
  merge.
- `status.showUntrackedFiles=no` is set, so untracked files never appear in
  `config status`. Intentional. No `.gitignore` needed.
- Use the `config` alias. Raw `git --git-dir=...` without `--work-tree` fails.
