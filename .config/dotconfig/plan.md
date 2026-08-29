# Migration Plan

## Herdr keybindings

```toml
[keys]
help = ["prefix+?", "f1"]
settings = ["prefix+s", "f9"]
detach = ["prefix+q", "f6"]
new_tab = ["prefix+c", "f2"]
rename_tab = ["prefix+shift+t", "f8"]
previous_tab = ["prefix+p", "f3", "cmd+shift+["]
next_tab = ["prefix+n", "f4", "cmd+shift+]"]
goto = ["prefix+g", "f5"]
copy_mode = ["prefix+[", "f7"]
switch_workspace = "cmd+1..9"
split_vertical = ["prefix+v", "ctrl+f2"]
split_horizontal = ["prefix+minus", "shift+f2"]
```

## Behavior

- `Cmd+1..9`: select Herdr workspace.
- `F1`: open Herdr keybinding help.
- `F2`: create a tab.
- `Shift+F2`: split horizontally (stacked panes).
- `Ctrl+F2`: split vertically (side-by-side panes).
- `F3` / `F4`: previous / next tab.
- `Cmd+Shift+[` / `Cmd+Shift+]`: previous / next tab.
- `F5`: open Goto for workspace search and agent-attention filters.
- `F6`: detach from Herdr.
- `F7`: enter Herdr copy/scrollback mode; use `j`/`k` and exit with `q`.
- `F8`: rename the active tab.
- `F9`: open Herdr settings.
- Leave `F12` unmapped and keep `Ctrl+B` as the prefix.
- Keep `Cmd+O` available to Claude Code.
- Use the mouse for rare split-pane navigation and resizing.
- Keep the default `Ctrl+B` prefix for uncommon Herdr actions.
- Preserve default Herdr bindings alongside the added shortcuts.
- Do not install pane-navigation plugins.

## Ghostty

Release Ghostty's default `Cmd+1..9` and `Cmd+Shift+[` / `Cmd+Shift+]` tab bindings so Herdr can receive them. Keep all other Ghostty changes minimal.

## Pi

An example of Pi models. Note the "anthropic-messages", "cacheControlFormat"

```json

      "models": [
        {
          "id": "cc/claude-fable-5",
          "name": "Claude Fable 5",
          "api": "anthropic-messages",
          "reasoning": true,
          "input": [
            "text",
            "image"
          ],
          "contextWindow": 1000000,
          "maxTokens": 128000,
          "compat": {
            "cacheControlFormat": "anthropic"
          }
        },
```
