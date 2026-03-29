#!/usr/bin/env zsh
# ~/.config/tmux/scripts/claude-layout.sh
#
# Creates or switches to a Claude Code working layout:
#
#  ┌──────────────────────────┬──────────────┐
#  │                          │              │
#  │        nvim (70%)        │    claude    │
#  │                          │    (30%)     │
#  │                          │              │
#  └──────────────────────────┴──────────────┘
#
# If a window named 'work' exists in the current session, switch to it.
# Otherwise create it with the layout above.

SESSION=$(tmux display-message -p '#S')
WINDOW_NAME="work"

# Check if 'work' window already exists
if tmux list-windows -t "$SESSION" -F '#W' 2>/dev/null | grep -q "^${WINDOW_NAME}$"; then
    tmux select-window -t "$SESSION:$WINDOW_NAME"
else
    # Create new window with the layout
    tmux new-window -t "$SESSION" -n "$WINDOW_NAME" -c "#{pane_current_path}"

    # Left pane: nvim (will use auto-session to restore if available)
    tmux send-keys -t "$SESSION:$WINDOW_NAME" "nvim ." Enter

    # Right pane: claude (30%)
    tmux split-window -t "$SESSION:$WINDOW_NAME" -h -p 30 -c "#{pane_current_path}"
    tmux send-keys -t "$SESSION:$WINDOW_NAME" "claude" Enter

    # Focus back to nvim pane
    tmux select-pane -t "$SESSION:$WINDOW_NAME.left"
fi
