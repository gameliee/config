#!/usr/bin/env bash
# Toggle a manual "deferred" flag on the focused agent.
# On:  write "pane_id<TAB>epoch<TAB>state_change_seq" to state file, render an
#      additive "$deferred" metadata token (badge "●") in the sidebar.
# Off: remove entry, clear token.
# Nothing auto-clears; only this toggle removes the flag.
#
# The badge is a metadata token (--token deferred=●), NOT --display-agent:
# display_agent REPLACES the agent name in the agent panel (so the row would
# freeze on the static badge); a token renders alongside the live agent name
# and status. --clear-display-agent is sent on every toggle to scrub any badge
# left by the pre-token version of this plugin.
set -euo pipefail

bin="${HERDR_BIN_PATH:-herdr}"
state_dir="${HERDR_PLUGIN_STATE_DIR:?}"
deferred_file="$state_dir/deferred.tsv"
mkdir -p "$state_dir"
touch "$deferred_file"

pane_id=$(printf '%s' "${HERDR_PLUGIN_CONTEXT_JSON:-}" \
  | jq -r '.focused_pane_id // .pane_id // empty')
[ -n "$pane_id" ] || exit 0

agents="$($bin agent list 2>/dev/null)"
seq="$(printf '%s' "$agents" \
  | jq -r --arg p "$pane_id" '.result.agents[] | select(.pane_id == $p) | .state_change_seq // empty' 2>/dev/null || true)"
[ -n "$seq" ] || seq=0

if grep -q "^${pane_id}	" "$deferred_file"; then
  # toggle off
  grep -v "^${pane_id}	" "$deferred_file" > "$deferred_file.tmp" || true
  mv "$deferred_file.tmp" "$deferred_file"
  "$bin" pane report-metadata "$pane_id" --source local-nav \
    --clear-token deferred --clear-display-agent
else
  # toggle on (re-mark refreshes timestamp + seq)
  now=$(date +%s)
  grep -v "^${pane_id}	" "$deferred_file" > "$deferred_file.tmp" || true
  printf '%s\t%s\t%s\n' "$pane_id" "$now" "$seq" >> "$deferred_file.tmp"
  mv "$deferred_file.tmp" "$deferred_file"
  "$bin" pane report-metadata "$pane_id" --source local-nav \
    --token deferred=● --clear-display-agent
fi
