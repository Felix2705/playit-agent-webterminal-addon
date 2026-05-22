#!/bin/sh
set -eu

PLAYIT_BIN="/addon/playit-agent"

if [ ! -x "$PLAYIT_BIN" ]; then
  echo "Playit agent binary missing or not executable at: $PLAYIT_BIN" >&2
  exit 1
fi

echo "Starting playit agent..."
exec "$PLAYIT_BIN"
