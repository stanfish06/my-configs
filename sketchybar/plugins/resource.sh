#!/usr/bin/env bash
VENV_PATH="./.sketchy_pyvenv"
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
    "$VENV_PATH/bin/pip" install psutil
fi
USAGE=$($VENV_PATH/bin/python -c "
import psutil 
cpu=psutil.cpu_percent(interval=1)
ram=psutil.virtual_memory()
ram_total = (ram.total / 1024.0 ** 3)
ram_used = (ram.used / 1024.0 ** 3)
swap=psutil.swap_memory()
swap_total = (swap.total / 1024.0 ** 3)
swap_used = (swap.used / 1024.0 ** 3)
print(f'⟨\uf4bc CPU: {cpu:3.1f}% | \uefc5 RAM: {ram_used:4.1f}/{ram_total:4.1f} GB · SWAP: {swap_used:3.1f}/{swap_total:3.1f} GB⟩')
")
sketchybar --set "$NAME" icon="$ICON" label="${USAGE}"
