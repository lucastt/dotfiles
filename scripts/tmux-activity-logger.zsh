# Logs shell commands with their tmux context to ~/.tmux-activity.log
# Source this from .zshrc — only activates inside tmux

_tmux_log_cmd() {
  [[ -z "$TMUX" ]] && return
  local cmd="$1"
  local ts session window window_idx
  ts=$(date -Iseconds)
  session=$(tmux display-message -p '#S' 2>/dev/null)
  window_idx=$(tmux display-message -p '#I' 2>/dev/null)
  window=$(tmux display-message -p '#W' 2>/dev/null)
  echo "${ts}|CMD|${session}|${window_idx}:${window}|${cmd}" >> "$HOME/.tmux-activity.log"
}

preexec_functions+=(_tmux_log_cmd)
