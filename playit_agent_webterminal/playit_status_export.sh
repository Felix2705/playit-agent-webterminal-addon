#!/bin/sh
set -eu

# Export status to Home Assistant via Supervisor Core API
#
# Entities:
# - sensor.playit_agent_phase
# - sensor.playit_agent_uptime_seconds
# - sensor.playit_agent_version
# - sensor.playit_agent_secret_configured

HA_BASE_URL="http://supervisor/core/api"
HA_TOKEN="${SUPERVISOR_TOKEN:-}"

if [ -z "$HA_TOKEN" ]; then
  echo "SUPERVISOR_TOKEN is not set; cannot export status to Home Assistant." >&2
  exit 1
fi

json_escape() {
  # string -> JSON-escaped string (minimal)
  echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\r//g; s/\n/\\n/g'
}

post_state() {
  # $1 entity_id, $2 state, $3 attributes_json_object (e.g. {})
  entity_id="$1"
  state="$2"
  attrs="$3"

  state_escaped="$(json_escape "$state")"
  payload="{\"state\":\"${state_escaped}\",\"attributes\":${attrs}}"

  wget -q -O /dev/null \
    --method=POST \
    --header="Authorization: Bearer ${HA_TOKEN}" \
    --header="Content-Type: application/json" \
    --body-data="$payload" \
    "${HA_BASE_URL}/states/${entity_id}" || true
}

normalize_bool() {
  s="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  case "$s" in
    true|1|yes|on) echo "true" ;;
    false|0|no|off) echo "false" ;;
    *) echo "unknown" ;;
  esac
}

extract_after_colon() {
  # $1 multi-line input, $2 label (e.g. Phase)
  echo "$1" | sed -n "s/^[[:space:]]*$2:[[:space:]]*//p" | head -n 1
}

PLAYIT_BIN="/usr/local/bin/playit"
if [ ! -x "$PLAYIT_BIN" ]; then
  echo "playit binary missing at $PLAYIT_BIN" >&2
  exit 1
fi

INTERVAL_SECONDS="${PLAYIT_STATUS_INTERVAL_SECONDS:-10}"

while :; do
  status_out="$("$PLAYIT_BIN" service status 2>/dev/null || true)"

  if [ -n "$status_out" ]; then
    phase="$(extract_after_colon "$status_out" "Phase")"
    version="$(extract_after_colon "$status_out" "Version")"
    uptime_raw="$(extract_after_colon "$status_out" "Uptime")"
    secret_raw="$(extract_after_colon "$status_out" "Secret configured")"

    uptime_seconds="$(echo "$uptime_raw" | sed 's/^\([0-9][0-9]*\).*/\1/p')"
    if [ -z "$uptime_seconds" ]; then uptime_seconds="0"; fi

    secret_configured="$(normalize_bool "$secret_raw")"

    post_state "sensor.playit_agent_phase" "$phase" "{}"
    post_state "sensor.playit_agent_uptime_seconds" "$uptime_seconds" "{\"unit_of_measurement\":\"s\"}"
    post_state "sensor.playit_agent_version" "$version" "{}"
    post_state "sensor.playit_agent_secret_configured" "$secret_configured" "{}"
  fi

  sleep "$INTERVAL_SECONDS"
done
