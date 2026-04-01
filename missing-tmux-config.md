# Tmux Tips

## Rename a window (tab)

Interactive:
```
Ctrl+b ,
```

From command line:
```sh
tmux rename-window "my-tab"
```

## Session templates

### 1. Shell script (simplest, no dependencies)

```sh
#!/bin/zsh
tmux new-session -d -s work -n editor
tmux new-window -t work -n server
tmux new-window -t work -n logs
tmux attach -t work
```

### 2. tmuxinator (Ruby gem, YAML config)

```sh
gem install tmuxinator
tmuxinator new myproject
```

```yaml
# ~/.tmuxinator/myproject.yml
name: myproject
root: ~/github/myproject
windows:
  - editor: vim
  - server: npm run dev
  - logs:
```

```sh
tmuxinator start myproject
```

### 3. tmux-resurrect / tmux-continuum

Persists sessions across reboots.

- `prefix + Ctrl+s` to save
- `prefix + Ctrl+r` to restore

### 4. Native tmux config (~/.tmux.conf, runs on start)

```
new-session -s main -n editor
new-window -n server
```
