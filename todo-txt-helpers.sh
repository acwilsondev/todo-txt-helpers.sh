# Todo.txt aliases
export AUTOSORT_TODO="true"
export COLORIZE_TODO="true"


todo-highlight-priorities() {
  MAGENTA="$(printf '\033[1;35m')"
  RED="$(printf '\033[1;31m')"          # Bright red
  ORANGE="$(printf '\033[38;5;208m')"   # ANSI 256-color orange
  YELLOW="$(printf '\033[1;33m')"       # Bright yellow
  DIM="$(printf '\033[2m')"
  RESET="$(printf '\033[0m')"
  GRAY="$(printf '\033[38;5;239m')"
  BLUE="$(printf '\033[34m')"

  if [ "$COLORIZE_TODO" = "true" ]; then
    sed -E \
      -e "s/^(\(\*\))/${MAGENTA}\1${RESET}/" \
      -e "s/^(\(A\))/${RED}\1${RESET}/" \
      -e "s/^(\(B\))/${ORANGE}\1${RESET}/" \
      -e "s/^(\(C\))/${YELLOW}\1${RESET}/" \
      -e "s/^(\([D-Z]\) .*)/${DIM}\1${RESET}/" \
      -e "s/(\+.*)/${BLUE}\1${RESET}/" \
      -e "s/^(x .*)/${GRAY}${DIM}\1${RESET}/"
  else
    cat
  fi
}

# per spec, todo.txt sorts naturally in lexicographic order
alias -- todo-sort='sort -u $TODO_FILE -o $TODO_FILE' 
alias -- todo-edit='$EDITOR $TODO_FILE' # open todo file in your editor
alias -- todo-next='head -n 1 $TODO_FILE | todo-highlight-priorities | nl' # show top one task
alias -- todo-ls='cat $TODO_FILE | todo-highlight-priorities | nl' # show top five tasks
alias -- todo-grep='todo-ls | grep' # find tasks matching the given input
alias -- todo-due='todo-ls | grep "due:"' # show all tasks with a due date
alias -- todo-wc='wc -l $TODO_FILE'
alias -- todo-inbox='todo-ls | grep "(*)"'
alias -- todo-easy='todo-ls | grep -E "effort:(S|XS)"'

# Mark a task as done
function todo-head() {
  head -n "$1" $TODO_FILE | nl 
}


function todo-x() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: todo-x LINE [LINE ...]"
    return 1
  fi

  local today
  today=$(date +%Y-%m-%d)

  for n in "$@"; do
    # remove priority marker (if present)
    sed -i "${n}s/^ *(\([A-Z\*]\)) //" "$TODO_FILE"
    # prefix line with completion mark and date
    sed -i "${n}s/^/x $today /" "$TODO_FILE"
  done

  if [ "$AUTOSORT_TODO" = true ]; then
    todo-sort
  fi
}


function todo-add() {
  local today
  today=$(date +%Y-%m-%d)
  echo "(*) $today $*" >> "$TODO_FILE"

  if [ "$AUTOSORT_TODO" = true ]; then
    todo-sort
  fi
}

# Todo.txt report alias
alias -- todo-priorities='grep -oE "^\([A-Z]\)" $TODO_FILE | sort | uniq -c'
alias -- todo-projects='grep -oE "\+[a-zA-Z0-9_\-]+" $TODO_FILE | sort | uniq -c | sort -nr'
alias -- todo-contexts='grep -oE "@[a-zA-Z0-9_\-]+" $TODO_FILE | sort | uniq -c | sort -nr'

# delete nth task
function todo-rm() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: todo-rm LINE [LINE ...]"
    return 1
  fi

  # Build sed delete expression like '5d;10d;12d'
  local sed_expr=""
  for n in "$@"; do
    sed_expr+="${n}d;"
  done

  sed -i "$sed_expr" "$TODO_FILE"
}

# archive done tasks
function todo-archive() {
  grep '^x ' "$TODO_FILE" >> "$TODO_DONE_FILE"
  sed -i '/^x /d' "$TODO_FILE"
}

function todo-help() {
cat <<'EOF'
# todo-help: usage info for todo.txt helpers

# Environment variables:
#   AUTOSORT_TODO=true     # automatically sort file after add/remove
#   COLORIZE_TODO=true     # colorize output by priority and done state

note: environment variables must be EXPORTED, they cannot be used inline

# View tasks:
alias todo-ls        # show todo list
alias todo-ls-all    # show all tasks with line numbers
alias todo-next      # show top task (first line)
alias todo-grep      # grep through tasks with line numbers
alias todo-due       # list tasks that contain "due:"

# Edit:
alias todo-edit      # open todo file in your editor
alias todo-sort      # sort and deduplicate the todo file (per todo.txt spec)

# Add / remove / complete tasks:
todo-add "your task"         # append task to file, then autosort if enabled
todo-x N+                    # mark tasks N as done (adds date, removes priority)
todo-rm N+                   # delete tasks N (by line number)
todo-head N                  # print first N tasks with line numbers
todo-archive                 # move all done tasks (starting with 'x ') to $TODO_DONE_FILE

# Reports:
alias todo-priorities  # count of tasks by priority (A, B, C, etc.)
alias todo-projects    # count of +projects
alias todo-contexts    # count of @contexts

# Helpers:
highlight_priorities   # used internally; colorizes tasks by (A)/(B)/(C)/done

# Call `todo-help` to print this info
EOF
}

