#!/usr/bin/env bash
# scripts/session-manager.sh

# 可选：排除当前 session，避免切换到自己报错
current_session=$(tmux display-message -p '#S' 2>/dev/null || echo "")

list_cmd="tmux list-sessions -F '#{session_name}\t#{?session_attached,attached,}\t#{session_windows} windows'"
if [ -n "$current_session" ]; then
  list_cmd="$list_cmd | grep -v '^$current_session\t'"
fi

# fzf 选择逻辑
result=$(eval "$list_cmd" | \
  fzf --reverse --height=100% \
      --print-query \
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

# 解析 fzf 输出
query=$(echo "$result" | head -1)          # 第一行：用户输入的查询字符串
choice=$(echo "$result" | tail -1 | cut -f1)  # 最后一行：选中的 session 名（如果没选则空）


# 处理逻辑
if [ -n "$choice" ]; then
    # 有选中 → 切换到该 session
    tmux switch-client -t "$choice" 2>/dev/null || {
        tmux display-message "无法切换到 session: $choice"
        exit 1
    }
elif [ -n "$query" ]; then
    # 没选中，但输入框有内容 → 用输入内容新建 session
    new_name=$(echo "$query" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # 去除首尾空格
    
    if [ -n "$new_name" ]; then
        tmux new-session -d -s "$new_name" 2>/dev/null || {
            tmux display-message "创建失败：session '$new_name' 已存在"
        }
        tmux display-message "已新建 session: $new_name （按 Ctrl+r 刷新列表）"
    fi
else
    # 完全没输入也没选中 → 什么都不做
    true
fi

