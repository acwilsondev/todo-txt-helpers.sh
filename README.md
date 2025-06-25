# Todo.txt Helpers

Simple shell aliases and functions for managing todo.txt files.

## Usage

1. Source the script in your shell:
   ```bash
   source todo-txt-helpers.sh
   ```

2. Set your todo file location:
   ```bash
   export TODO_FILE="/path/to/your/todo.txt"
   export TODO_DONE_FILE="/path/to/your/done.txt"
   ```

3. Use the commands:
   - `todo-ls` - view your todo list
   - `todo-add "task"` - add a new task
   - `todo-x N` - mark task N as done
   - `todo-help` - see all available commands

## Features

- Color-coded priorities (A=red, B=orange, C=yellow)
- Auto-sorting after adding/completing tasks
- Project and context tracking
- Task archiving

For complete usage info, run `todo-help` after sourcing the script.
