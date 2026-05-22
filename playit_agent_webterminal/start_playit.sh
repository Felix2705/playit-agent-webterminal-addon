#!/bin/sh
set -eu

PLAYIT_DAEMON_BIN="/addon/playit-agent"

if [ ! -x "$PLAYIT_DAEMON_BIN" ]; then
  echo "playit-agent binary missing or not executable at: $PLAYIT_DAEMON_BIN" >&2
  exit 1
fi

# Persist playit secret/config across addon/container restarts (HA maps config:rw to /config)
export XDG_CONFIG_HOME="/config"

echo "Starting playit agent (playitd)..."
exec "$PLAYIT_DAEMON_BIN"
