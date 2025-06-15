#!/bin/bash

command_list=("compute" "transfer")
if [[ "$1" == ${command_list[0]} ]]; then
    module purge
    module load use.own fzf uv matlab python/3.12
elif [[ "$1" == ${command_list[1]} ]]; then
    module purge
    module load use.own python fzf globus-cli rclone
    if type globus > /dev/null 2>&1; then
        eval "$(globus --bash-completer)"
    fi
else
    echo "Invalid command. Available options are: ${command_list[*]}"
fi
