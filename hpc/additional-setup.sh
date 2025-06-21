#!/bin/bash

command_list=("compute" "transfer" "build")
if [[ "$1" == ${command_list[0]} ]]; then
    module purge
    module load use.own fzf uv
    module load cuda/12.6
    module load cudnn/12.6
    module load python/3.12
elif [[ "$1" == ${command_list[1]} ]]; then
    module purge
    module load use.own python fzf rclone
elif [[ "$1" == ${command_list[2]} ]]; then
    module purge
    module load use.own fzf uv rust gcc
else
    echo "Invalid command. Available options are: ${command_list[*]}"
fi
