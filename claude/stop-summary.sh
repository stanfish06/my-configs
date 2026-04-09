#!/usr/bin/env bash
INPUT=$(cat)
IS_CURSOR=$(echo "$INPUT" | jq 'has("cursor_version")')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')
LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message')
CALL_CLAUDE=false

if ! $IS_CURSOR && $CALL_CLAUDE; then
    CLAUDE_SUM=$(claude -p --model "haiku" "Here is the last assistant message: ${LAST_MSG}. The transcript is at ${TRANSCRIPT}. Based on last message and relevant parts of transcript, give me a short summary: 0. When was it finished (time of last message), based on timestamps in transcript. How long does it take 1. success or fail? Just say task ✅ or ❌ 2. major changes 3. what is next. Cap summary in 10-15 words. Reply in human readable paragraph, not markdown.")

    if [ -z "$CLAUDE_SUM" ]; then
      CLAUDE_SUM="(summary unavailable)"
    fi

    notify-send -a "claude-code" 'Claude Code' "Claude Code stopped: ${CLAUDE_SUM}"
    exit 0
else
    notify-send -a "claude-code" 'Claude Code' "Claude Code stopped"
    exit 0
fi
