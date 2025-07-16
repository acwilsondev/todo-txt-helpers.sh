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

