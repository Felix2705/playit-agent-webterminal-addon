#!/bin/sh
set -eu

PLAYIT_DAEMON_BIN= /addon/playit-agent
PLAYIT_CLI_BIN=/addon/playit-cli
PLAYIT_CLI_URL=https://github.com/playit-cloud/playit-agent/releases/download/v1.0.4/playit-cli-linux-amd64

download_if_missing() {
  #  = url,  = target
  if [ -f  ]; then
    return 0
  fi
  echo Downloading: 
  wget -q -O  
}

chmod_exec_if_file() {
  #  = target
  if [ -f  ]; then
    chmod +x 
  fi
}

# Ensure wget exists
if ! command -v wget >/dev/null 2>&1; then
  echo wget not found >&2
  exit 1
fi

# Ensure playit CLI exists so playit works in the tty shell
download_if_missing  
chmod_exec_if_file 
ln -sf  /usr/local/bin/playit || true

if [ ! -x  ]; then
  echo Playit agent binary missing or not executable at:  >&2
  exit 1
fi

echo Starting playit agent...
exec 