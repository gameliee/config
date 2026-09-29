# Executes commands at the start of an interactive Zsh session.

# Prezto is installed separately and remains an unmodified dependency.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export PATH="$HOME/.local/bin:$HOME/.bun/bin:/opt/homebrew/opt/libpq/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

if command -v fzf >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--walker-skip .git,node_modules,.venv,__pycache__"
  source <(fzf --zsh)
fi

if [[ -x /usr/libexec/java_home ]]; then
  _java_home="$(/usr/libexec/java_home -v 11 2>/dev/null)"
  if [[ -n "$_java_home" ]]; then
    export JAVA_HOME="$_java_home"
  fi
  unset _java_home
fi

export VISUAL='nvim'

# Bun completions.
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Local dotenv secrets.
if [[ -r "$HOME/.secrets" ]]; then
  set -a
  source "$HOME/.secrets"
  set +a
fi

# Machine- and work-specific shell configuration.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

ha() {
  local pane
  pane=$(herdr agent list \
    | jq -r '.result.agents[] | [.pane_id, .agent_status, .agent, .cwd, .terminal_title_stripped] | @tsv' \
    | while IFS=$'\t' read -r id st ag cwd title; do
        br=$(git -C "$cwd" branch --show-current 2>/dev/null)
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$st" "$ag" "${cwd:t}" "${br:--}" "$title"
      done \
    | column -t -s $'\t' \
    | fzf --prompt='agent> ' \
    | awk '{print $1}')
  [ -n "$pane" ] && herdr agent attach "$pane"
}
