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
3. **A divergence on the machine branch.** When the software has no include
   mechanism at all (karabiner.json). Record it below.

### Deliberate divergences

| Branch | File | Why |
|---|---|---|
| `macos` | `.config/karabiner/karabiner.json` | Karabiner-Elements has no include mechanism and rewrites the file itself. `main` holds the full profile; a machine may legitimately differ. Merges silently — see Hazards. |

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

# pi packages — the list is tracked in .pi/agent/settings.json and pi installs
# anything missing on next launch. Only needed to add one.
pi list
pi install <source>

# gitleaks: the hook lands in ~/.cfg/hooks, which git cannot track
GIT_DIR="$HOME/.cfg" GIT_WORK_TREE="$HOME" pre-commit install
```

pi config is tracked: `.pi/agent/models.json`, `settings.json` and
`web-search.json`. They carry no credentials — the gateway is
`http://localhost:20128/v1` with a literal `no-api-key`. `auth.json`,
`models-store.json` and `sessions/` stay untracked.

Expect churn: pi rewrites these files as it runs, so fields like
`lastChangelogVersion` drift on their own. Commit the change you meant, discard
the rest.

`thinkingLevelMap` is sparse on purpose. `off` `minimal` `low` `medium` `high`
are offered unless the key is set to `null`; `xhigh` and `max` are hidden unless
the key names a value. An absent key sends the level name to the provider
unchanged. Write only the keys that change something — `"low": "low"` does
nothing.

## Hazards for agents

- **Never `config switch` or `config checkout <branch>`** on an existing
  machine — the work-tree is `$HOME`, so it rewrites the home directory. Use
  `git worktree` for branch work. Merging into the current machine branch is
  safe; switching off it is not.
- **Never `config reset --hard` on a machine branch.** Backmerge is always
  `config merge origin/main`. Reset moves the branch off commits the user never
  asked to lose, and `--hard` overwrites the work-tree — which is `$HOME`.
  Suggest it if the machine branch holds nothing worth keeping, then wait for an
  explicit yes. Same for `push --force`.
- **Branch before anything destructive**: `config branch <machine>-old-<sha>`.
  Free, and it turns a mistake into one command to undo.
- `config diff HEAD origin/main` after merging — divergences don't conflict, so
  they don't show up.
- **`karabiner.json` merges silently wrong.** It has no include mechanism, so it
  is a deliberate divergence, and a machine-side deletion beats an untouched
  `main` with no conflict. After any merge:
  `grep -c keyboard_fn ~/.config/karabiner/karabiner.json` — 2 is right, 0 means
  the fn/left_option swap was dropped. Restore with
  `config checkout origin/main -- .config/karabiner/karabiner.json`.
- **Clear the merge blockers first.** Git aborts rather than overwrite an
  untracked or dirty file that an incoming commit adds. On this repo that is
  `.pi/agent/{models,settings}.json` and, on a machine still using prezto's
  symlink, `.zshrc`. Copy them somewhere outside `$HOME`'s tracked paths, delete
  the originals, then merge.
- `status.showUntrackedFiles=no` is set, so untracked files never appear in
  `config status`. Intentional. No `.gitignore` needed.
- Use the `config` alias. Raw `git --git-dir=...` without `--work-tree` fails.
- **Secrets go in `~/.secrets`, machine config in `~/.zshrc.local`.** Both
  untracked, both sourced at the end of `.zshrc` — `.secrets` under `set -a`, so
  it needs no `export`. Never inline a credential into a tracked file. When
  moving lines out of an untracked file into these, move them, don't copy: a
  second plaintext copy is a second leak.
- **`~/.zprezto` is a vendored dependency, not ours.** It is a clone of
  `sorin-ionescu/prezto` with its own remote. Do not track, commit, or revert
  files under it. `runcoms/zprofile` carries the `brew shellenv` line that puts
  Homebrew on `PATH` — `/etc/paths` does not — so reverting it costs every brew
  binary on the next login. `runcoms/zpreztorc` carries the pmodule list.
  Contrary to the note on #9, those two are *not* byte-identical to prezto's
  templates on macos; `.zshenv`, `.zlogin` and `.zlogout` are.
