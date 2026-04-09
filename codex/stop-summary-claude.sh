#!/usr/bin/env bash
set -euo pipefail
CALL_CLAUDE=false

INPUT="$(cat)"

json_get() {
  local filter="$1"
  printf '%s' "$INPUT" | jq -r "$filter // empty" 2>/dev/null || true
}

TRANSCRIPT="$(json_get '.transcript_path')"
if [ -z "$TRANSCRIPT" ]; then
  TRANSCRIPT="$(json_get '.transcriptPath')"
fi
if [ -z "$TRANSCRIPT" ]; then
  TRANSCRIPT="$(json_get '.session.transcript_path')"
fi

LAST_MSG="$(json_get '.last_assistant_message')"
if [ -z "$LAST_MSG" ]; then
  LAST_MSG="$(json_get '.lastAssistantMessage')"
fi
if [ -z "$LAST_MSG" ]; then
  LAST_MSG="$(json_get '.session.last_assistant_message')"
fi

if $CALL_CLAUDE; then
    CLAUDE_SUM="$(timeout 45s claude -p --model "haiku" "Here is the last assistant message: ${LAST_MSG}. The transcript is at ${TRANSCRIPT}. Based on the last message and relevant parts of the transcript, give me a short summary: 0. when it finished, based on timestamps in the transcript 1. how long it took 2. success or fail; say task ✅ or task ❌ 3. major changes 4. what is next. Cap summary at 10-15 words. Reply in one human-readable sentence, not markdown." 2>/dev/null || true)"

    if [ -z "$CLAUDE_SUM" ]; then
      CLAUDE_SUM="$LAST_MSG"
    fi

    if [ -z "$CLAUDE_SUM" ]; then
      CLAUDE_SUM="summary unavailable"
    fi

    notify-send -a "codex" 'Codex' "Codex stopped: ${CLAUDE_SUM}" >/dev/null 2>&1 || true
    exit 0
else
    notify-send -a "codex" 'Codex' "Codex stopped" >/dev/null 2>&1 || true
    exit 0
fi

