#!/usr/bin/env bash
# Stop the brainstorm server and clean up
# Usage: stop-server.sh <screen_dir>
#
# Asks the server to exit (stop-request file), then force-kills the node
# process if it is still alive. Works on Windows/Git Bash too, where killing
# the MSYS wrapper PID does not reach the native node.exe child. A recorded
# PID is only ever killed after confirming it is this brainstorm server.
#
# Only deletes the session directory if it is an ephemeral /tmp/brainstorm-*
# session. Persistent directories (<tool-dir>/brainstorm/) are kept so mockups
# can be reviewed later.

SCREEN_DIR="$1"

if [[ -z "$SCREEN_DIR" ]]; then
  echo '{"error": "Usage: stop-server.sh <screen_dir>"}'
  exit 1
fi

PID_FILE="${SCREEN_DIR}/.server.pid"
NODE_PID_FILE="${SCREEN_DIR}/.server.node-pid"

IS_WINDOWS="false"
case "${OSTYPE:-}" in msys*|cygwin*|mingw*) IS_WINDOWS="true" ;; esac

# Full command line of a process in this shell's PID namespace (MSYS PIDs on Windows).
proc_args() {
  if [[ -r "/proc/$1/cmdline" ]]; then
    tr '\0' ' ' < "/proc/$1/cmdline"
  else
    ps -p "$1" -o args= 2>/dev/null
  fi
}

# Is <pid> this brainstorm server? (node writes its native PID; on Windows that
# is a Windows PID, invisible to MSYS tools.) Slow on Windows -- call once.
is_our_server() {
  local pid="$1"
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  if [[ "$IS_WINDOWS" == "true" ]]; then
    powershell.exe -NoProfile -NonInteractive -Command \
      "(Get-CimInstance Win32_Process -Filter 'ProcessId=$pid').CommandLine" 2>/dev/null \
      | grep -q 'server\.cjs'
  else
    proc_args "$pid" | grep -q 'server\.cjs'
  fi
}

# Cheap liveness check for a PID already confirmed as ours.
node_alive() {
  local pid="$1"
  [[ -n "$pid" ]] || return 1
  if [[ "$IS_WINDOWS" == "true" ]]; then
    MSYS2_ARG_CONV_EXCL='*' tasklist /FI "PID eq $pid" /NH 2>/dev/null | grep -qi '^node'
  else
    kill -0 "$pid" 2>/dev/null
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

# A PID that is not (or no longer) our server is stale -- never kill it.
is_our_server "$NODE_PID" || NODE_PID=""
if [[ -n "$WRAPPER_PID" && "$WRAPPER_PID" != "$NODE_PID" ]]; then
  proc_args "$WRAPPER_PID" | grep -q 'start-server\.sh\|server\.cjs' || WRAPPER_PID=""
fi

if [[ -z "$NODE_PID" && -z "$WRAPPER_PID" ]]; then
  rm -f "$PID_FILE" "$NODE_PID_FILE" "${SCREEN_DIR}/.stop-request"
  echo '{"status": "not_running"}'
  exit 0
fi

forced="false"
if [[ -n "$NODE_PID" ]]; then
  # 1. Graceful: the server watches its dir and exits on the stop-request file.
  touch "${SCREEN_DIR}/.stop-request"
  deadline=$((SECONDS + 3))   # wall clock: tasklist checks are slow on Windows
  while (( SECONDS < deadline )) && node_alive "$NODE_PID"; do
    sleep 0.1
  done

  # 2. Force: still alive -> kill the node process itself.
  if node_alive "$NODE_PID"; then
    force_kill_node "$NODE_PID"
    forced="true"
    sleep 0.2
  fi
fi

# 3. Wrapper (foreground mode on Windows, or an older server without a node PID).
if [[ -n "$WRAPPER_PID" && "$WRAPPER_PID" != "$NODE_PID" ]] && kill -0 "$WRAPPER_PID" 2>/dev/null; then
  kill "$WRAPPER_PID" 2>/dev/null || true
  for _ in {1..20}; do kill -0 "$WRAPPER_PID" 2>/dev/null || break; sleep 0.1; done
  kill -0 "$WRAPPER_PID" 2>/dev/null && kill -9 "$WRAPPER_PID" 2>/dev/null
fi

if node_alive "$NODE_PID"; then
  echo '{"status": "failed", "error": "process still running"}'
  exit 1
fi

# A killed server could not clean up after itself: don't leave a "running" signal.
if [[ "$forced" == "true" || ! -f "${SCREEN_DIR}/.server-stopped" ]]; then
  rm -f "${SCREEN_DIR}/.server-info"
  printf '{"reason":"%s","timestamp":%s}\n' \
    "$([[ "$forced" == "true" ]] && echo 'force-killed by stop-server' || echo 'stopped by stop-server')" \
    "$(date +%s)000" > "${SCREEN_DIR}/.server-stopped"
fi

rm -f "$PID_FILE" "$NODE_PID_FILE" "${SCREEN_DIR}/.stop-request" "${SCREEN_DIR}/.server.log"

# Only delete ephemeral /tmp/brainstorm-* sessions (resolved: no ../ escapes;
# on Windows the server reports /tmp sessions as C:/.../Temp/...).
real_dir="$(cd "$SCREEN_DIR" 2>/dev/null && pwd -P)"
tmp_root="$(cd /tmp 2>/dev/null && pwd -P)"
if [[ -n "$real_dir" && -n "$tmp_root" && "$real_dir" == "$tmp_root"/brainstorm-* ]]; then
  rm -rf "$real_dir"
fi

echo '{"status": "stopped"}'
