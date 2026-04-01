#!/bin/bash
# Called by tmux hooks to log structural events.
# Usage: tmux-log-event.sh <EVENT> [args...]
# Appends to ~/.tmux-activity.log
echo "$(date -Iseconds)|$*" >> "$HOME/.tmux-activity.log"
