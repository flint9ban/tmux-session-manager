bind-key S display-popup -EE -w 70% -h 80% \
  "tmux list-sessions -F '#{session_name}\\t#{?session_attached,• attached,}\\t#{session_windows} windows' | \
   fzf --reverse --height=100% --delimiter='\\t' --with-nth=1.. --nth=1 \
       --preview='tmux capture-pane -pt {1} -S -' \
       --preview-window=right,60% \
   | cut -f1 | xargs -I{} tmux switch-client -t '{}'"