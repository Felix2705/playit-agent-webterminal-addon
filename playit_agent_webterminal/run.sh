#!/bin/sh
set -eu

TTyD_BIN="/usr/local/bin/ttyd"
TTY_PORT="7681"

PLAYIT_DAEMON_BIN="/addon/playit-agent"
PLAYIT_DAEMON_URL="https://github.com/playit-cloud/playit-agent/releases/download/v1.0.4/playit-linux-amd64"

PLAYIT_CLI_BIN="/addon/playit-cli"
PLAYIT_CLI_URL="https://github.com/playit-cloud/playit-agent/releases/download/v1.0.4/playit-cli-linux-amd64"

TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64"

download_if_missing() {
  # $1 = url, $2 = target
  if [ -f "$2" ]; then
    return 0
  fi
  echo "Downloading: $1"
  wget -q -O "$2" "$1"
}

chmod_exec_if_file() {
  # $1 = target
  if [ -f "$1" ]; then
    chmod +x "$1"
  fi
}

# Ensure deps
if ! command -v wget >/dev/null 2>&1; then
  echo "wget not found" >&2
  exit 1
fi

download_if_missing "$TTYD_URL" "$TTyD_BIN"
chmod_exec_if_file "$TTyD_BIN"

download_if_missing "$PLAYIT_DAEMON_URL" "$PLAYIT_DAEMON_BIN"
chmod_exec_if_file "$PLAYIT_DAEMON_BIN"

download_if_missing "$PLAYIT_CLI_URL" "$PLAYIT_CLI_BIN"
chmod_exec_if_file "$PLAYIT_CLI_BIN"

# Make `playit` available in the ttyd shell + for status exporter
ln -sf "$PLAYIT_CLI_BIN" /usr/local/bin/playit || true

# Persist playit secret/config across addon/container restarts (HA maps config:rw to /config)
export XDG_CONFIG_HOME="/config"

# Start playit agent detached so ttyd/client exit doesn't kill it
nohup /addon/start_playit.sh >/var/log/playit-agent.log 2>&1 &

# Start status exporter detached (updates HA entities)
nohup /addon/playit_status_export.sh >/var/log/playit-status-export.log 2>&1 &

sleep 1

# Launch interactive shell in ttyd; keep it running even if the browser websocket closes
exec "$TTyD_BIN" -p "$TTY_PORT" -W -- /bin/sh -lc "export XDG_CONFIG_HOME=/config; trap '' HUP; exec /bin/sh"
