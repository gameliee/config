#!/usr/bin/env bash
# Jump to the newest "unread" agent.
# Unread = the newer of:
#   - newest auto-finished (done) agent, by Herdr state_change_seq
#   - newest manually deferred agent, by seq recorded at mark time
# Focusing a done agent marks it seen (it leaves the done set), so repeated
# presses walk the queue newest-first. Deferred entries persist until toggled
# off; panes that no longer exist are pruned here.
set -euo pipefail

bin="${HERDR_BIN_PATH:-herdr}"
state_dir="${HERDR_PLUGIN_STATE_DIR:?}"
deferred_file="$state_dir/deferred.tsv"

agents="$("$bin" agent list 2>/dev/null)"

# --- newest done agent ---
done_pane="$(printf '%s' "$agents" \
  | jq -r '.result.agents | map(select(.agent_status == "done")) | max_by(.state_change_seq) | .pane_id // empty' 2>/dev/null || true)"
done_seq="$(printf '%s' "$agents" \
  | jq -r '.result.agents | map(select(.agent_status == "done")) | max_by(.state_change_seq) | .state_change_seq // empty' 2>/dev/null || true)"
[ -n "$done_seq" ] || done_seq=0

# --- newest deferred agent; prune dead panes in the same pass ---
deferred_pane=""
deferred_seq=0
if [ -s "$deferred_file" ]; then
  : > "$deferred_file.tmp"
  while IFS=$'\t' read -r pane epoch seq; do
    [ -n "$pane" ] || continue
    # pane still an agent?
    if printf '%s' "$agents" | jq -e --arg p "$pane" '.result.agents[] | select(.pane_id == $p)' >/dev/null 2>&1; then
      printf '%s\t%s\t%s\n' "$pane" "$epoch" "${seq:-}" >> "$deferred_file.tmp"
      if [ -z "${seq:-}" ]; then
        # legacy entry without stored seq: use live seq once
        seq="$(printf '%s' "$agents" | jq -r --arg p "$pane" '.result.agents[] | select(.pane_id == $p) | .state_change_seq // empty' 2>/dev/null || true)"
      fi
      if [ "${seq:-0}" -gt "$deferred_seq" ]; then
        deferred_seq="${seq:-0}"
        deferred_pane="$pane"
      fi
    fi
  done < "$deferred_file"
  mv "$deferred_file.tmp" "$deferred_file"
fi

# --- pick the newer of the two ---
target=""
if [ -n "$done_pane" ] && [ -n "$deferred_pane" ]; then
  if [ "$deferred_seq" -ge "$done_seq" ]; then target="$deferred_pane"; else target="$done_pane"; fi
elif [ -n "$done_pane" ]; then
  target="$done_pane"
elif [ -n "$deferred_pane" ]; then
  target="$deferred_pane"
fi

[ -n "$target" ] || exit 0
exec "$bin" agent focus "$target"
