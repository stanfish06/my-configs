#!/usr/bin/env bash
set -euo pipefail
INPUT="$(cat)"
(
  json_get() {
    local filter="$1"
    printf '%s' "$INPUT" | jq -r "$filter // empty" 2>/dev/null || true
  }

  TRANSCRIPT="$(json_get '.transcript_path')"
  [ -z "$TRANSCRIPT" ] && TRANSCRIPT="$(json_get '.transcriptPath')"
  [ -z "$TRANSCRIPT" ] && TRANSCRIPT="$(json_get '.session.transcript_path')"

  LAST_MSG="$(json_get '.last_assistant_message')"
  [ -z "$LAST_MSG" ] && LAST_MSG="$(json_get '.lastAssistantMessage')"
  [ -z "$LAST_MSG" ] && LAST_MSG="$(json_get '.session.last_assistant_message')"

  CLAUDE_SUM="$(timeout 45s claude -p --model "haiku" \
    "Here is the last assistant message: ${LAST_MSG}. The transcript is at ${TRANSCRIPT}. Based on the last message and relevant parts of the transcript, give me a short summary: 0. when it finished, based on timestamps in the transcript 1. how long it took 2. success or fail; say task ✅ or task ❌ 3. major changes 4. what is next. Cap summary at 10-15 words. Reply in one human-readable sentence, not markdown." \
    2>/dev/null || true)"

  [ -z "$CLAUDE_SUM" ] && CLAUDE_SUM="$LAST_MSG"
  [ -z "$CLAUDE_SUM" ] && CLAUDE_SUM="summary unavailable"

  notify-send -a "codex" 'Codex' "Codex stopped: ${CLAUDE_SUM}" >/dev/null 2>&1 || true
) &
disown
exit 0
