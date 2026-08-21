#!/bin/bash
## Example: ShellCheck can detect some higher level semantic problems

while getopts "nf:" param
do
  case "$param" in
    f) file="$OPTARG" ;;
    v) set -x ;;
  esac
done
