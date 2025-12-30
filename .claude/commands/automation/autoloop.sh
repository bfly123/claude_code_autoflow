#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKDIR"

PIDFILE="$WORKDIR/.claude/autoloop.pid"
LOGFILE="$WORKDIR/.claude/autoloop.log"

ensure_deps() {
  command -v python3 >/dev/null || { echo "python3 not found" >&2; exit 1; }
  command -v lask >/dev/null || { echo "lask not found" >&2; exit 1; }
}

is_running() {
  if [[ -f "$PIDFILE" ]]; then
    local pid
    pid="$(cat "$PIDFILE" 2>/dev/null || true)"
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
  else
    return 1
  fi
}

start() {
  ensure_deps
  mkdir -p "$WORKDIR/.claude"

  if is_running; then
    echo "autoloop already running (pid $(cat "$PIDFILE"))"
    exit 0
  fi

  : >"$LOGFILE"
  nohup python3 -u "$WORKDIR/automation/autoloop.py" >>"$LOGFILE" 2>&1 &
  local pid=$!
  echo "$pid" >"$PIDFILE"
  echo "autoloop started (pid $pid)"
  echo "log: $LOGFILE"
}

stop() {
  if ! [[ -f "$PIDFILE" ]]; then
    echo "autoloop not running"
    exit 0
  fi
  local pid
  pid="$(cat "$PIDFILE" 2>/dev/null || true)"
  if [[ -z "$pid" ]]; then
    rm -f "$PIDFILE"
    echo "autoloop not running"
    exit 0
  fi

  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    sleep 0.2
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
    fi
  fi
  rm -f "$PIDFILE"
  echo "autoloop stopped"
}

status() {
  if is_running; then
    echo "autoloop running (pid $(cat "$PIDFILE"))"
    exit 0
  fi
  echo "autoloop not running"
}

once() {
  ensure_deps
  python3 "$WORKDIR/automation/autoloop.py" --once
}

cmd="${1:-start}"
case "$cmd" in
  start) start ;;
  stop) stop ;;
  status) status ;;
  once) once ;;
  *)
    echo "Usage: $0 {start|stop|status|once}" >&2
    exit 2
    ;;
esac
