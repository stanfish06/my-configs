#!/usr/bin/env bash
# cycle notification visibility: 5 -> 1 -> count only -> all
CYCLE=(default one fold all)
current=$(makoctl mode | tail -n1)
next=${CYCLE[0]}
for i in "${!CYCLE[@]}"; do
    if [ "${CYCLE[i]}" = "$current" ]; then
        next=${CYCLE[$(((i + 1) % ${#CYCLE[@]}))]}
        break
    fi
done
makoctl mode -s "$next" > /dev/null
