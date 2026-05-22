#!/bin/sh
set -eu

TTyD_BIN="/usr/local/bin/ttyd"
TTY_PORT="7681"
PLAYIT_BIN="/addon/playit-agent"
PLAYIT_URL="https://github.com/playit-cloud/playit-agent/releases/download/v1.0.4/playit-linux-amd64"
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
  echo "wget not found"
  exit 1
fi

download_if_missing "$TTYD_URL" "$TTyD_BIN"
chmod_exec_if_file "$TTyD_BIN"

# Download Playit agent (amd64)
download_if_missing "$PLAYIT_URL" "$PLAYIT_BIN"
chmod_exec_if_file "$PLAYIT_BIN"

# Expose an interactive shell in ttyd.
# Auto-start Playit agent in the background, then keep the shell for user input.
exec "$TTyD_BIN" -p "$TTY_PORT" -W -- /bin/sh -lc "/addon/start_playit.sh & exec /bin/sh"
