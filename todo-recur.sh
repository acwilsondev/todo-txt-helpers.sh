#!/bin/bash

TODO_FILE="${TODO_FILE:-$HOME/todo.txt}"
TODO_RECUR_FILE="$HOME/.todo-recurring.txt"
STAMP_DIR="$HOME/.cache/todo-stamps"
LOG_FILE="$HOME/todo-recur.log"
FORCE="$1"

mkdir -p "$STAMP_DIR"

today=$(date +%F)
dow=$(date +%u)
week=$(date +%V)
month=$(date +%Y-%m)

echo "[$(date)] START todo-recur (force=$FORCE)" >> "$LOG_FILE"

if [ ! -f "$TODO_RECUR_FILE" ]; then
  echo "Missing TODO_RECUR_FILE: $TODO_RECUR_FILE" >> "$LOG_FILE"
  exit 1
fi

tmpfile=$(mktemp)

# Start by copying existing tasks to tmp
cp "$TODO_FILE" "$tmpfile"

while read -r freq rest; do
  [[ -z "$freq" || -z "$rest" ]] && continue

  key="$(echo "$freq $rest" | sha1sum | awk '{print $1}')"
  stamp_file="$STAMP_DIR/$key.stamp"
  should_run=false
  last_date=$(cat "$stamp_file" 2>/dev/null || echo "1970-01-01")

  case "$freq" in
    daily)
      [[ "$last_date" != "$today" ]] && should_run=true
      ;;
    weekly)
      last_week=$(date -d "$last_date" +%V)
      [[ "$last_week" != "$week" ]] && should_run=true
      ;;
    monthly)
      last_month=$(date -d "$last_date" +%Y-%m)
      [[ "$last_month" != "$month" ]] && should_run=true
      ;;
    *)
      echo "Unknown frequency: $freq" >> "$LOG_FILE"
      continue
      ;;
  esac

  if [[ "$should_run" = true || "$FORCE" = "force" ]]; then
    task="(*) $today $rest +recurring"
    echo "$task" >> "$tmpfile.new"       # new top
    echo "$today" > "$stamp_file"
    echo "Added at top: $task" >> "$LOG_FILE"
  else
    echo "Skipped: $rest (already added)" >> "$LOG_FILE"
  fi
done < "$TODO_RECUR_FILE"

# Prepend new tasks (if any) above old ones
if [ -f "$tmpfile.new" ]; then
  cat "$tmpfile.new" "$tmpfile" > "$TODO_FILE"
  rm "$tmpfile.new"
else
  cp "$tmpfile" "$TODO_FILE"
fi

rm "$tmpfile"
echo "DONE" >> "$LOG_FILE"

