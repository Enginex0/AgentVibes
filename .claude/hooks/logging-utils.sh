#!/usr/bin/env bash
#
# AgentVibes Logging Utilities
#
# Provides comprehensive logging for debugging silent failures and latency.
# All logs go to ~/.claude/logs/agentvibes/
#
# Usage in scripts:
#   source "$(dirname "${BASH_SOURCE[0]}")/logging-utils.sh"
#   av_log_init "script-name"
#   av_log_info "Starting operation"
#   av_log_start "OPERATION_NAME"
#   ... do work ...
#   av_log_end "OPERATION_NAME"
#

# Log directory (absolute path, works from any CWD)
AV_LOG_DIR="$HOME/.claude/logs/agentvibes"

# Session ID (unique per invocation chain)
AV_SESSION_ID="${AV_SESSION_ID:-$(date +%Y%m%d-%H%M%S)-$$}"
export AV_SESSION_ID

# Log files
AV_SESSION_LOG="$AV_LOG_DIR/session-${AV_SESSION_ID}.log"
AV_ERROR_LOG="$AV_LOG_DIR/errors.log"
AV_DAEMON_LOG="$AV_LOG_DIR/daemon.log"

# Timing tracking (associative array for operation start times)
declare -A AV_OP_START_TIMES 2>/dev/null || true

# Current component name
AV_COMPONENT=""

# Debug mode (set AGENTVIBES_DEBUG=1 to enable verbose logging)
AV_DEBUG="${AGENTVIBES_DEBUG:-1}"

#
# Initialize logging for a component
#
av_log_init() {
    local component="${1:-unknown}"
    AV_COMPONENT="$component"

    # Create log directory if needed
    mkdir -p "$AV_LOG_DIR" 2>/dev/null || true

    # Log initialization with environment context
    av_log_info "=== Component initialized ==="
    av_log_info "PWD: $(pwd)"
    av_log_info "SCRIPT: ${BASH_SOURCE[1]:-unknown}"
    av_log_info "USER: $(whoami)"
    av_log_info "HOME: $HOME"
}

#
# Get high-precision timestamp (milliseconds)
#
av_timestamp() {
    if date +%s%3N >/dev/null 2>&1; then
        # GNU date with milliseconds
        date +"%Y-%m-%dT%H:%M:%S.%3N"
    else
        # Fallback for macOS/BSD
        date +"%Y-%m-%dT%H:%M:%S.000"
    fi
}

#
# Get epoch milliseconds for duration calculation
#
av_epoch_ms() {
    if date +%s%3N >/dev/null 2>&1; then
        date +%s%3N
    else
        # Fallback: seconds * 1000
        echo "$(($(date +%s) * 1000))"
    fi
}

#
# Internal log writer
#
_av_log() {
    local level="$1"
    local message="$2"
    local duration="${3:-}"

    [[ "$AV_DEBUG" != "1" ]] && [[ "$level" != "ERROR" ]] && return 0

    local ts
    ts=$(av_timestamp)

    local duration_str=""
    [[ -n "$duration" ]] && duration_str=" [${duration}ms]"

    local log_line="[$ts] [$level] [$AV_COMPONENT]${duration_str} $message"

    # Write to session log
    echo "$log_line" >> "$AV_SESSION_LOG" 2>/dev/null || true

    # Write errors to dedicated error log
    if [[ "$level" == "ERROR" ]]; then
        echo "$log_line" >> "$AV_ERROR_LOG" 2>/dev/null || true
    fi
}

#
# Log levels
#
av_log_debug() {
    _av_log "DEBUG" "$1"
}

av_log_info() {
    _av_log "INFO" "$1"
}

av_log_warn() {
    _av_log "WARN" "$1"
}

av_log_error() {
    _av_log "ERROR" "$1"
}

#
# Start timing an operation
#
av_log_start() {
    local operation="$1"
    local start_ms
    start_ms=$(av_epoch_ms)

    # Store in environment variable (associative arrays not reliable across subshells)
    eval "AV_START_${operation}=${start_ms}"
    export "AV_START_${operation}"

    av_log_info "START: $operation"
}

#
# End timing an operation and log duration
#
av_log_end() {
    local operation="$1"
    local status="${2:-OK}"
    local end_ms
    end_ms=$(av_epoch_ms)

    # Retrieve start time
    local start_var="AV_START_${operation}"
    local start_ms="${!start_var:-}"

    local duration=""
    if [[ -n "$start_ms" ]]; then
        duration=$((end_ms - start_ms))
    fi

    if [[ "$status" == "OK" ]]; then
        _av_log "INFO" "END: $operation ($status)" "$duration"
    else
        _av_log "ERROR" "END: $operation ($status)" "$duration"
    fi

    # Cleanup
    unset "$start_var" 2>/dev/null || true
}

#
# Log to daemon-specific log (for piper-worker-enhanced.sh)
#
av_log_daemon() {
    local level="$1"
    local message="$2"
    local duration="${3:-}"

    local ts
    ts=$(av_timestamp)

    local duration_str=""
    [[ -n "$duration" ]] && duration_str=" [${duration}ms]"

    local log_line="[$ts] [$level] [daemon]${duration_str} $message"

    echo "$log_line" >> "$AV_DAEMON_LOG" 2>/dev/null || true

    # Also write to session log if available
    [[ -n "$AV_SESSION_ID" ]] && echo "$log_line" >> "$AV_SESSION_LOG" 2>/dev/null || true
}

#
# Log environment variables (useful for debugging path issues)
#
av_log_env() {
    av_log_debug "=== Environment Dump ==="
    av_log_debug "PATH: $PATH"
    av_log_debug "PWD: $(pwd)"
    av_log_debug "HOME: $HOME"
    av_log_debug "SHELL: $SHELL"
    av_log_debug "AV_SESSION_ID: $AV_SESSION_ID"
    av_log_debug "AGENTVIBES_DEBUG: ${AGENTVIBES_DEBUG:-unset}"
}

#
# Log a function call with arguments (for tracing)
#
av_log_call() {
    local func="$1"
    shift
    av_log_debug "CALL: $func($*)"
}

#
# Wrap a command with timing and error capture
#
av_log_exec() {
    local operation="$1"
    shift
    local cmd="$*"

    av_log_start "$operation"
    av_log_debug "EXEC: $cmd"

    local output
    local exit_code

    output=$("$@" 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        av_log_end "$operation" "OK"
    else
        av_log_end "$operation" "FAIL(exit=$exit_code)"
        av_log_error "Output: $output"
    fi

    echo "$output"
    return $exit_code
}

#
# Check if logging is enabled
#
av_logging_enabled() {
    [[ "$AV_DEBUG" == "1" ]]
}

#
# Get log file paths (for external tools)
#
av_get_session_log() {
    echo "$AV_SESSION_LOG"
}

av_get_error_log() {
    echo "$AV_ERROR_LOG"
}

av_get_daemon_log() {
    echo "$AV_DAEMON_LOG"
}

# Auto-create log directory on source
mkdir -p "$AV_LOG_DIR" 2>/dev/null || true
