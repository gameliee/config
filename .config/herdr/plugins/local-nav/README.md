# local-nav

Keyboard-only agent triage for Herdr: one unified **unread** queue —
auto-finished agents plus anything you manually mark as deferred — with a
toggle to bookmark what you pause mid-read.

## Bindings

| Action | Binding | Behavior |
|---|---|---|
| previous pane (toggle) | `alt+backtick` | Herdr built-in `last_pane`; toggles the previously focused pane |
| jump to newest unread | `alt+u` or `cmd+shift+u` | Newest item of the unified queue: auto-finished (`done`) or manually deferred, by Herdr `state_change_seq`; focus it |
| mark / unmark deferred | `ctrl+shift+u` | Toggle: records `pane_id` + timestamp + `state_change_seq` in state file; renders an additive `● deferred` sidebar token; only this key clears it |
| focus agent by number | `alt+1..9` | Herdr indexed `focus_agent`; `alt+N` = Nth entry of the sidebar agent list (spaces order — workspace order, then panes) |

Bindings are defined in `~/.config/herdr/config.toml`:

```toml
[keys]
focus_agent = "alt+1..9"

[[keys.command]]
key = "alt+u"
type = "plugin_action"
command = "local-nav.jump-unread"
description = "Jump to newest unread agent (finished or deferred)"

[[keys.command]]
key = "ctrl+shift+u"
type = "plugin_action"
command = "local-nav.mark-deferred"
description = "Toggle deferred flag on focused agent"

[[keys.command]]
key = "cmd+shift+u"
type = "plugin_action"
command = "local-nav.jump-unread"
description = "Jump to newest unread agent (finished or deferred)"
```

## Semantics

One mental model: **unread = anything you haven't finished reading.** The queue
has two sources, ordered on the same scale (Herdr `state_change_seq`):

- **Auto** — Herdr native `done`: agent detected Idle while pane unseen.
  Focusing marks it seen → status flips to `idle` → it leaves the done set, so
  repeated presses walk the queue newest-first.
- **Manual** — your `● deferred` bookmark: works on any status (done, idle,
  working, blocked). Persists across focusing, reading, and moving away;
  survives Herdr restarts. Nothing auto-clears; `ctrl+shift+u` toggles it off.
  The `state_change_seq` recorded at mark time is its position in the queue.

`alt+u` and `cmd+shift+u` are aliases for the same jump (one for your hand, one
for cmux muscle memory). Pane entries whose agent pane no longer exists are
pruned on jump.

## How it works

- All actions are small bash scripts composing only the native Herdr
  CLI (`herdr agent list`, `herdr agent focus`, `herdr pane report-metadata`).
- State file: `$HERDR_PLUGIN_STATE_DIR/deferred.tsv` →
  `~/.local/state/herdr/plugins/local-nav/deferred.tsv`; lines are
  `pane_id<TAB>epoch_seconds<TAB>state_change_seq`.
- Badge: `herdr pane report-metadata <pane_id> --source local-nav --token deferred=●`.
  A metadata token, not `--display-agent`: `display_agent` **replaces** the
  agent name in the agent panel (row freezes on the static badge); a token
  renders alongside the live name and status. Sidebar rows must include
  `$deferred`:

  ```toml
  [ui.sidebar.agents]
  rows = [
    ["state_icon", "workspace", "tab"],
    ["agent", "$deferred", "state_text"],
  ]
  ```
- No daemon, no network, no other state. Dependencies: `bash`, `jq`.

## Enable / disable / uninstall

```bash
herdr plugin link /Users/datn/.config/herdr/plugins/local-nav   # register local plugin
herdr plugin enable local-nav                                   # enable (linked plugins are enabled by default)
herdr server reload-config                                      # apply after config.toml changes
herdr plugin list                                               # verify: shows "enabled"
herdr plugin disable local-nav                                  # stop actions without removing files
herdr plugin unlink local-nav                                   # unregister, leaves files in place
herdr plugin uninstall local-nav                                # unregister + remove herdr-managed files
```

Requirements: herdr >= 0.7.3 (tested on 0.7.5), `bash`, `jq`.

## Verification performed

- Chords conflict-free across macOS, Ghostty, Herdr defaults, Pi (73 default
  bindings), Claude Code, Codex (`tui_keymap.rs`), OpenCode (`keybind.ts`).
  `cmd+shift+u` intentionally matches cmux's `jumpToUnread`.
- `herdr config check` → `ok`; `herdr server reload-config` → applied, no diagnostics.
- Live: newest done resolved (`w3:p1`, seq 354); invocation moved focus and
  was restored; mark → state entry + badge; jump → newest deferred focused;
  unmark → file emptied + badge cleared.
- Unified queue: two deferred entries with seqs 1 and 476 → jump focused the
  higher-seq pane (`w7:p4`); focus restored after test.
- Badge regression fixed: `--display-agent` replaced the agent name
  (aggregate.rs `effective_display_agent().unwrap_or(fallback)`), freezing the
  row text on the static badge while the underlying status kept updating
  (seq 541→558, idle→working, observed live). Replaced with an additive
  `$deferred` metadata token + `state_text` row; legacy badges scrubbed;
  toggle round-trip verified.

## Trust note

Runs as plain bash with your user privileges and full CLI path. It calls only
the Herdr CLI, writes one state file, and never reads your transcripts,
sessions, or credentials.
