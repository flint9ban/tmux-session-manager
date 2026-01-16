#!/usr/bin/env bash

tmux bind-key a display-popup -EE -w 70% -h 80% \
  "bash ~/.tmux/plugins/tmux-session-manager/session-manager.sh"

