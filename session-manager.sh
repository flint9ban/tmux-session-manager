#!/usr/bin/env bash
# scripts/session-manager.sh

# 可选：排除当前 session，避免切换到自己报错
current_session=$(tmux display-message -p '#S' 2>/dev/null || echo "")

list_cmd="tmux list-sessions -F '#{session_name}\\t#{?session_attached,attached,}\\t#{session_windows} windows'"
if [ -n "$current_session" ]; then
  list_cmd="$list_cmd | grep -v '^$current_session\\t'"
fi

# fzf 选择逻辑
choice=$(eval "$list_cmd" | \
  fzf --reverse --height=100% \
      --delimiter='\t' \
      --with-nth=1.. \
      --nth=1 \
      --header='SESSION MANAGER   Ctrl+n 新建 | Ctrl+d 删除 | Ctrl+r 刷新' \
      --prompt='选择 session > ' \
      --preview='tmux capture-pane -pt {1} -S - 2>/dev/null || echo "(无预览)"' \
      --preview-window='right,60%' \
      --bind 'ctrl-n:execute(tmux command-prompt -p "新 session 名字:" "new-session -d -s %%")+reload(eval \"'"$list_cmd"'\" )+abort' \
      --bind 'ctrl-d:execute(tmux kill-session -t {1})+reload(eval \"'"$list_cmd"'\" )+abort' \
      --bind 'ctrl-r:reload(eval \"'"$list_cmd"'\" )+abort'
)

# 如果有选择，切换过去
[ -n "$choice" ] && tmux switch-client -t "$choice"