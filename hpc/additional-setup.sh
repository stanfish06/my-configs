#!/bin/bash

command_list=("compute-1" "compute-2" "ngs" "transfer" "build" "list")

show_help() {
    echo "Available commands and their modules:"
    echo ""
    echo "  compute-1:"
    echo "    - use.own, fzf, uv"
    echo "    - cuda/12.6"
    echo "    - cudnn/12.6" 
    echo "    - python/3.12"
    echo ""
    echo "  compute-2:"
    echo "    - use.own, fzf, uv"
    echo "    - matlab"
    echo "    - python/3.12"
    echo ""
    echo "  ngs:"
    echo "    - use.own, fzf, nextflow"
    echo "    - singularity, uv"
    echo "    - sratoolkit"
    echo ""
    echo "  transfer:"
    echo "    - use.own, python, fzf, rclone"
    echo ""
    echo "  build:"
    echo "    - use.own, fzf, uv, rust, gcc"
    echo ""
    echo "Usage: $0 <command>"
    echo "       $0 list    # Show this help"
}
if [[ "$1" == ${command_list[0]} ]]; then
    module purge
    module load use.own fzf uv
    module load cuda/12.6
    module load cudnn/12.6
    module load python/3.12
elif [[ "$1" == ${command_list[1]} ]]; then
    module purge
    module load use.own fzf uv
    module load matlab
elif [[ "$1" == ${command_list[2]} ]]; then
    module purge
    module load use.own nextflow fzf
    module load singularity uv
    module load Bioinformatics
    module load sratoolkit
elif [[ "$1" == ${command_list[3]} ]]; then
    module purge
    module load use.own python fzf rclone
elif [[ "$1" == ${command_list[4]} ]]; then
    module purge
    module load use.own fzf uv rust gcc
elif [[ "$1" == ${command_list[5]} ]] || [[ "$1" == "help" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
else
    echo "Invalid command. Available options are: ${command_list[*]}"
    echo ""
    show_help
fi
