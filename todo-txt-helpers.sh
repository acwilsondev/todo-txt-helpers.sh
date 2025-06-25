# Todo.txt aliases
export AUTOSORT_TODO="true"
export COLORIZE_TODO="true"


todo-highlight-priorities() {
  RED="$(printf '\033[1;31m')"          # Bright red
  ORANGE="$(printf '\033[38;5;208m')"   # ANSI 256-color orange
  YELLOW="$(printf '\033[1;33m')"       # Bright yellow
  DIM="$(printf '\033[2;38;5;240m')"
  RESET="$(printf '\033[0m')"           # Reset all styles

  if [ "$COLORIZE_TODO" = "true" ]; then
    sed -E \
      -e "s/^(\(A\))/${RED}\1${RESET}/" \
      -e "s/^(\(B\))/${ORANGE}\1${RESET}/" \
      -e "s/^(\(C\))/${YELLOW}\1${RESET}/" \
      -e "s/^(x .*)/${DIM}\1${RESET}/"
  else
    cat
  fi
}

# per spec, todo.txt sorts naturally in lexicographic order
alias -- todo-sort='sort -u $TODO_FILE -o $TODO_FILE' 
alias -- todo-edit='$EDITOR $TODO_FILE' # open todo file in your editor
alias -- todo-next='head -n 1 $TODO_FILE | todo-highlight-priorities | nl' # show top one task
alias -- todo-ls='cat $TODO_FILE | todo-highlight-priorities | nl' # show top five tasks
alias -- todo-ls-all='cat $TODO_FILE | todo-highlight-priorities | nl' # show everything
alias -- todo-grep='cat $TODO_FILE | todo-highlight-priorities | nl | grep' # find tasks matching the given input
alias -- todo-due='cat $TODO_FILE | todo-highlight-priorities | nl grep "due:"' # show all tasks with a due date


# Mark a task as done
function todo-head() {
  head -n "$1" $TODO_FILE | nl 
}


function todo-x() {
  # remove pri
  sed -i "${1}s/^\([A-Z]\) //" "$TODO_FILE"
  # add x and completion date
  sed -i "${1}s/^/x $(date +%Y-%m-%d) /" $TODO_FILE
  if [ "$AUTOSORT_TODO" = true ]; then
    todo-sort
  fi
}


function todo-add() {
  echo "$1" >> "$TODO_FILE"
  if [ "$AUTOSORT_TODO" = true ]; 
  then 
    todo-sort 
  fi
}


# Todo.txt report alias
alias -- todo-priorities='grep -oE "^\([A-Z]\)" $TODO_FILE | sort | uniq -c'
alias -- todo-projects='grep -oE "\+[a-zA-Z0-9_\-]+" $TODO_FILE | sort | uniq -c | sort -nr'
alias -- todo-contexts='grep -oE "@[a-zA-Z0-9_\-]+" $TODO_FILE | sort | uniq -c | sort -nr'

# delete nth task
function todo-rm() {
  sed -i "${1}d" "$TODO_FILE"
}
# archive done tasks
function todo-archive() {
  grep '^x ' "$TODO_FILE" >> "$DONE_FILE"
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
todo-x N                     # mark task N as done (adds date, removes priority)
todo-rm N                    # delete task N (by line number)
todo-head N                  # print first N tasks with line numbers
todo-archive                 # move all done tasks (starting with 'x ') to $DONE_FILE

# Reports:
alias todo-priorities  # count of tasks by priority (A, B, C, etc.)
alias todo-projects    # count of +projects
alias todo-contexts    # count of @contexts

# Helpers:
highlight_priorities   # used internally; colorizes tasks by (A)/(B)/(C)/done

# Call `todo-help` to print this info
EOF
}

