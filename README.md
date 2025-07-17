# Todo.txt Helpers

A unified command-line tool for todo.txt management, converted from sourced aliases and functions to a standalone program.

## Installation

### System-wide installation (requires sudo)
```bash
sudo ./install.sh
```

### User-local installation
```bash
INSTALL_DIR=~/.local/bin ./install.sh
```

Make sure the installation directory is in your PATH.

## Configuration

Set the required environment variables in your shell configuration file (e.g., `~/.zshrc`):

```bash
export TODO_FILE=~/todo.txt
export TODO_DONE_FILE=~/done.txt
export TODO_RECUR_FILE=~/recur.txt  # optional
export AUTOSORT_TODO=true           # optional, defaults to true
export COLORIZE_TODO=true           # optional, defaults to true
```

## Usage

Run `todo-txt-helpers help` to see all available commands.

### Examples

```bash
# View tasks
todo-txt-helpers ls                    # show all tasks
todo-txt-helpers next                  # show top task
todo-txt-helpers head 10               # show first 10 tasks
todo-txt-helpers grep "project"        # search for tasks containing "project"
todo-txt-helpers due                   # show tasks with due dates
todo-txt-helpers inbox                 # show inbox tasks (*)

# Add and manage tasks
todo-txt-helpers add "New task description"
todo-txt-helpers x 1 3 5               # mark tasks 1, 3, and 5 as done
todo-txt-helpers rm 2                  # delete task 2
todo-txt-helpers archive               # move completed tasks to done file

# Reports
todo-txt-helpers priorities            # count tasks by priority
todo-txt-helpers projects              # count tasks by project
todo-txt-helpers contexts              # count tasks by context

# Edit files
todo-txt-helpers edit                  # open todo file in editor
todo-txt-helpers recur                 # edit recurring tasks file
```

## Migration from Sourced Script

If you were previously sourcing `todo-txt-helpers.sh`, you can now:

1. Remove the `source todo-txt-helpers.sh` line from your shell configuration
2. Install this standalone program using the instructions above
3. Update any scripts or aliases that used the old function names:
   - `todo-add` → `todo-txt-helpers add`
   - `todo-x` → `todo-txt-helpers x`
   - `todo-ls` → `todo-txt-helpers ls`
   - etc.

## Features

- **Colored output**: Priority-based coloring (A=red, B=orange, C=yellow, etc.)
- **Automatic sorting**: Optionally sort todo file after modifications
- **Line numbers**: All listing commands show line numbers for easy reference
- **Flexible installation**: Install system-wide or user-local
- **Environment variable support**: Configurable via environment variables
- **Todo.txt spec compliance**: Follows the todo.txt format specification

## Original Script

The original `todo-txt-helpers.sh` script with aliases and functions has been backed up and converted to this standalone program.

## Recurring Tasks for `todo.txt`

This setup adds recurring tasks (daily, weekly, monthly) to your `todo.txt` file if they haven’t been added yet today/week/month. Tasks are prepended with a timestamp like:

```
(*) 2025-07-16 Take vitamins +health +recurring
```

It works fully in user-space — no root, no cron, no external tools required.

---

### ✅ 1. Install the Script

Create the script at `~/.local/bin/todo-recur.sh` and make it executable:

```bash
mkdir -p ~/.local/bin
chmod +x ~/.local/bin/todo-recur.sh
```

Paste the full script content [here](#) or copy from your reference.

---

### ✅ 2. Create Your Recurring Task List

```bash
# ~/.todo-recurring.txt
daily Take vitamins +health
weekly Clean fridge +chores
monthly Rotate backups +infra
```

Each line = `<frequency> <task>`
Supported frequencies: `daily`, `weekly`, `monthly`

---

### ✅ 3. Connect it to systemd (runs daily at 8AM)

Create `~/.config/systemd/user/todo-recur.service`:

```ini
[Unit]
Description=Add recurring tasks to todo.txt

[Service]
Type=oneshot
ExecStart=%h/.local/bin/todo-recur.sh
```

Create `~/.config/systemd/user/todo-recur.timer`:

```ini
[Unit]
Description=Run recurring task injector daily

[Timer]
OnCalendar=*-*-* 08:00
Persistent=true

[Install]
WantedBy=default.target
```

Enable and start:

```bash
systemctl --user daemon-reload
systemctl --user enable --now todo-recur.timer
```

---

### ✅ 4. Test It

Force a run manually:

```bash
~/.local/bin/todo-recur.sh force
```

Your `~/todo.txt` should now include lines like:

```
(*) 2025-07-16 Take vitamins +health +recurring
```

---

### ✅ 5. Debugging

Logs are saved to:

```bash
~/todo-recur.log
```

To manually inspect:

```bash
cat ~/todo-recur.log
```

Or check `systemd` logs:

```bash
journalctl --user -u todo-recur.service
```

