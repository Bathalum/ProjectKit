#!/usr/bin/env bash
# Stop the brainstorm server and clean up
# Usage: stop-server.sh <screen_dir>
#
# Asks the server to exit (stop-request file), then force-kills the node
# process if it is still alive. Works on Windows/Git Bash too, where killing
# the MSYS wrapper PID does not reach the native node.exe child.
#
# Only deletes session directory if it's under /tmp (ephemeral). Persistent
# directories (<tool-dir>/brainstorm/) are kept so mockups can be reviewed later.

SCREEN_DIR="$1"

if [[ -z "$SCREEN_DIR" ]]; then
  echo '{"error": "Usage: stop-server.sh <screen_dir>"}'
  exit 1
fi

PID_FILE="${SCREEN_DIR}/.server.pid"
NODE_PID_FILE="${SCREEN_DIR}/.server.node-pid"

IS_WINDOWS="false"
case "${OSTYPE:-}" in msys*|cygwin*|mingw*) IS_WINDOWS="true" ;; esac

# Is <pid> a live node process? (node writes its native PID; on Windows that
# is a Windows PID, invisible to MSYS kill -0.)
node_alive() {
  local pid="$1"
  [[ -n "$pid" ]] || return 1
  if [[ "$IS_WINDOWS" == "true" ]]; then
    MSYS2_ARG_CONV_EXCL='*' tasklist /FI "PID eq $pid" /NH 2>/dev/null | grep -qi '^node'
  else
    ps -p "$pid" -o comm= 2>/dev/null | grep -qi 'node'
  fi
}

force_kill_node() {
  local pid="$1"
  if [[ "$IS_WINDOWS" == "true" ]]; then
    MSYS2_ARG_CONV_EXCL='*' taskkill /PID "$pid" /F >/dev/null 2>&1
  else
    kill "$pid" 2>/dev/null
    for _ in {1..10}; do node_alive "$pid" || return 0; sleep 0.1; done
    kill -9 "$pid" 2>/dev/null
  fi
}

NODE_PID=""
[[ -f "$NODE_PID_FILE" ]] && NODE_PID="$(tr -d '[:space:]' < "$NODE_PID_FILE")"
WRAPPER_PID=""
[[ -f "$PID_FILE" ]] && WRAPPER_PID="$(tr -d '[:space:]' < "$PID_FILE")"

if [[ -z "$NODE_PID" && -z "$WRAPPER_PID" ]]; then
  echo '{"status": "not_running"}'
  exit 0
fi

# 1. Graceful: the server watches its dir and exits on the stop-request file.
if node_alive "$NODE_PID"; then
  touch "${SCREEN_DIR}/.stop-request"
  deadline=$((SECONDS + 3))   # wall clock: tasklist checks are slow on Windows
  while (( SECONDS < deadline )) && node_alive "$NODE_PID"; do
    sleep 0.1
  done
fi

# 2. Force: still alive after ~3s -> kill the node process itself.
if node_alive "$NODE_PID"; then
  force_kill_node "$NODE_PID"
  sleep 0.2
fi

# 3. Wrapper (foreground mode on Windows): exits once node is gone; make sure.
if [[ -n "$WRAPPER_PID" && "$WRAPPER_PID" != "$NODE_PID" ]] && kill -0 "$WRAPPER_PID" 2>/dev/null; then
  kill "$WRAPPER_PID" 2>/dev/null || true
fi

# Older servers wrote no node PID: fall back to killing the recorded PID.
if [[ -z "$NODE_PID" && -n "$WRAPPER_PID" ]]; then
  kill "$WRAPPER_PID" 2>/dev/null || true
  for _ in {1..20}; do kill -0 "$WRAPPER_PID" 2>/dev/null || break; sleep 0.1; done
  kill -0 "$WRAPPER_PID" 2>/dev/null && kill -9 "$WRAPPER_PID" 2>/dev/null
fi

if node_alive "$NODE_PID"; then
  echo '{"status": "failed", "error": "process still running"}'
  exit 1
fi

rm -f "$PID_FILE" "$NODE_PID_FILE" "${SCREEN_DIR}/.stop-request" "${SCREEN_DIR}/.server.log"

# Only delete ephemeral /tmp directories
if [[ "$SCREEN_DIR" == /tmp/* ]]; then
  rm -rf "$SCREEN_DIR"
fi

echo '{"status": "stopped"}'
