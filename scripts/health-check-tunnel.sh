#!/bin/bash
# Audio Tunnel Health Check Script
# Monitors audio tunnel and automatically runs fix if needed
# This script uses audio-tunnel.config for all user-specific settings

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/audio-tunnel.config"

# Load configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    echo "   Copy audio-tunnel.config.example to audio-tunnel.config"
    echo "   and customize it for your setup."
    exit 1
fi

source "$CONFIG_FILE"

# Validate required variables
if [ -z "$REMOTE_HOST" ] || [ "$REMOTE_HOST" = "your-remote-host" ]; then
    echo "❌ REMOTE_HOST not configured in $CONFIG_FILE"
    exit 1
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
FIX_SCRIPT="${SCRIPT_DIR}/fix-audio-tunnel.sh"

# Function to log messages
log_message() {
    echo "[$TIMESTAMP] $1" >> "$AUTO_FIX_LOG"
}

# Check if socat bridge is running
check_socat() {
    if ss -tlnp 2>/dev/null | grep -q ":${TUNNEL_PORT}.*socat"; then
        return 0
    else
        return 1
    fi
}

# Check if SSH tunnel exists on remote
check_remote_tunnel() {
    if ssh "$REMOTE_HOST" "netstat -tlnp 2>/dev/null | grep -q ${TUNNEL_PORT}"; then
        return 0
    else
        return 1
    fi
}

# Main healthcheck
NEEDS_FIX=false

# Check 1: socat bridge
if ! check_socat; then
    log_message "ALERT: socat bridge not running on port ${TUNNEL_PORT}"
    NEEDS_FIX=true
fi

# Check 2: SSH tunnel (only if we're on WSL)
if grep -qi microsoft /proc/version 2>/dev/null; then
    if ! check_remote_tunnel; then
        log_message "ALERT: SSH tunnel not found on ${REMOTE_HOST}:${TUNNEL_PORT}"
        NEEDS_FIX=true
    fi
fi

# Run fix if needed
if [ "$NEEDS_FIX" = true ]; then
    log_message "Running automatic fix..."

    if [ -f "$FIX_SCRIPT" ]; then
        "$FIX_SCRIPT" >> "$AUTO_FIX_LOG" 2>&1

        # Verify fix worked
        sleep 3
        if check_socat; then
            log_message "SUCCESS: Audio tunnel restored automatically"

            # Play TTS notification if AgentVibes is available
            TTS_SCRIPT="${SCRIPT_DIR}/../.claude/hooks/play-tts.sh"
            if [ -f "$TTS_SCRIPT" ]; then
                "$TTS_SCRIPT" "Audio tunnel self healed!" 2>/dev/null || true
            fi
        else
            log_message "ERROR: Automatic fix failed, manual intervention needed"
        fi
    else
        log_message "ERROR: Fix script not found at $FIX_SCRIPT"
    fi
else
    log_message "OK: Audio tunnel is healthy"
fi
