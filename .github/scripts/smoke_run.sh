#!/usr/bin/env bash
# Headless smoke run: boot the Godot project at `application/run/main_scene`
# (`godot --headless --path game`) and pass on a clean startup (epic #91).
#
# The app starts and stays alive; it does not play itself and never quits. So the
# bounded timeout is the success path, not a failure: the engine's start banner
# arrives, the process is still running after a short settle, and no script or
# engine error printed. An early exit fails (unless it is a clean exit 0), as does
# any `SCRIPT ERROR:` / `ERROR:` line wherever it appears.
#
# Environment overrides: `SMOKE_PROJECT_PATH` (default `<repo>/game`),
# `SMOKE_TIMEOUT_SECONDS` (default 20, waiting for the banner),
# `SMOKE_SETTLE_SECONDS` (default 2, staying alive after it).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_PATH="${SMOKE_PROJECT_PATH:-$ROOT/game}"
TIMEOUT_SECONDS="${SMOKE_TIMEOUT_SECONDS:-20}"
SETTLE_SECONDS="${SMOKE_SETTLE_SECONDS:-2}"
ERROR_PATTERN='^(SCRIPT ERROR|USER SCRIPT ERROR|ERROR|USER ERROR):'
BANNER_PATTERN='^Godot Engine v'

log="$(mktemp "${TMPDIR:-/tmp}/smoke-run.XXXXXX")"
pid=""
launched=""

cleanup() {
	local status=$?
	if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
		kill -TERM "$pid" 2>/dev/null || true
		wait "$pid" 2>/dev/null || true
	fi
	if [[ $status -ne 0 && -n "$launched" ]]; then
		echo "--- smoke run log ($log)" >&2
		cat "$log" >&2
	else
		rm -f "$log"
	fi
}
trap cleanup EXIT

fail() {
	echo "error: $*" >&2
	[[ -n "${GITHUB_ACTIONS:-}" ]] && echo "::error::$*"
	exit 1
}

# End the child (terminating it when it is still up) and record its status in
# `child_status`; the harness itself never fails on the child's exit code.
stop_child() {
	child_status=0
	if kill -0 "$pid" 2>/dev/null; then
		kill -TERM "$pid" 2>/dev/null || true
		wait "$pid" 2>/dev/null || child_status=$?
		pid=""
	else
		wait "$pid" 2>/dev/null || child_status=$?
	fi
	return 0
}

# Poll in 0.25 s steps for `quarters` polls: stop as soon as the child exits or
# `pattern` shows up in the log. Sets `stopped_on` to `exit`, `match`, or `timeout`.
await() {
	local quarters=$1
	local pattern=$2
	local i
	stopped_on="timeout"
	for ((i = 0; i < quarters; i++)); do
		if ! kill -0 "$pid" 2>/dev/null; then
			stopped_on="exit"
			return
		fi
		if [[ -n "$pattern" ]]; then
			if grep -q "$pattern" "$log"; then
				stopped_on="match"
				return
			fi
		fi
		sleep 0.25
	done
}

[[ "$TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]] || fail "SMOKE_TIMEOUT_SECONDS must be a positive integer, got '$TIMEOUT_SECONDS'"
[[ "$SETTLE_SECONDS" =~ ^[0-9]+$ ]] || fail "SMOKE_SETTLE_SECONDS must be a non-negative integer, got '$SETTLE_SECONDS'"
[[ -d "$PROJECT_PATH" ]] || fail "no Godot project at $PROJECT_PATH"
command -v godot >/dev/null 2>&1 || fail "godot is not on PATH"

echo "Smoke run: godot --headless --path $PROJECT_PATH (banner timeout ${TIMEOUT_SECONDS}s)"

godot --headless --path "$PROJECT_PATH" >"$log" 2>&1 &
pid=$!
launched=1

# An early crash is a failure, not a clean startup that merely ran out of time.
await $((TIMEOUT_SECONDS * 4)) "$BANNER_PATTERN"
case "$stopped_on" in
exit)
	stop_child
	fail "the project exited $child_status during startup instead of staying up"
	;;
timeout) fail "the engine did not print its start banner within ${TIMEOUT_SECONDS}s" ;;
esac

await $((SETTLE_SECONDS * 4)) ""
if [[ "$stopped_on" == "exit" ]]; then
	stop_child
	fail "the project exited $child_status after the start banner"
fi

stop_child

if grep -nE "$ERROR_PATTERN" "$log"; then
	fail "the startup printed script or engine errors"
fi

echo "Clean startup: process alive after the banner with no script or engine errors"
