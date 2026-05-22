#!/bin/sh
set -eu

PLAYIT_DAEMON_BIN="/addon/playit-agent"

if [ ! -x "$PLAYIT_DAEMON_BIN" ]; then
  echo "playit-agent binary missing or not executable at: $PLAYIT_DAEMON_BIN" >&2
  exit 1
fi

echo "Starting playit agent..."
exec "$PLAYIT_DAEMON_BIN"
