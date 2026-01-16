current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bind-key E display-popup -EE -w 70% -h 80% \
  "bash #{current_dir}/session-manager.sh"

