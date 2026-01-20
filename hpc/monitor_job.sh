#!/bin/bash
mem_to_human() {
  local mem=$1
  if [[ $mem =~ ^([0-9]+)K$ ]]; then
    local kb=${BASH_REMATCH[1]}
    local gb=$(echo "scale=1; $kb / 1024 / 1024" | bc)
    echo "${gb}G"
  elif [[ $mem =~ ^([0-9]+)M$ ]]; then
    local mb=${BASH_REMATCH[1]}
    local gb=$(echo "scale=1; $mb / 1024" | bc)
    echo "${gb}G"
  else
    echo "$mem"
  fi
}

time_to_seconds() {
  local time=$1
  local seconds=0
  
  if [[ $time =~ ^([0-9]+):([0-9]+):([0-9]+)$ ]]; then
    seconds=$((${BASH_REMATCH[1]} * 3600 + ${BASH_REMATCH[2]} * 60 + ${BASH_REMATCH[3]}))
  elif [[ $time =~ ^([0-9]+):([0-9]+)$ ]]; then
    seconds=$((${BASH_REMATCH[1]} * 60 + ${BASH_REMATCH[2]}))
  fi
  echo $seconds
}

while true; do
  clear
  date
  printf "%-10s %-8s %-10s %-8s %-10s %-8s\n" "JOBID" "TIME" "NODE" "MaxMem" "CPUTime" "CPU%"
  printf "%-10s %-8s %-10s %-8s %-10s %-8s\n" "----------" "--------" "----------" "--------" "----------" "--------"
  
  for jobid in $(squeue -u zyyu -h -o "%i"); do
    elapsed=$(squeue -j $jobid -h -o "%M")
    node=$(squeue -j $jobid -h -o "%N")
    ncpus=$(squeue -j $jobid -h -o "%C")
    
    stats=$(sstat -j ${jobid}.batch --format=MaxRSS,AveCPU --noheader 2>/dev/null)
    if [ -n "$stats" ]; then
      maxrss=$(echo $stats | awk '{print $1}')
      avecpu=$(echo $stats | awk '{print $2}')
      maxrss_human=$(mem_to_human "$maxrss")
      
      elapsed_sec=$(time_to_seconds "$elapsed")
      cpu_sec=$(time_to_seconds "$avecpu")
      
      if [ $elapsed_sec -gt 0 ] && [ $ncpus -gt 0 ]; then
        cpu_pct=$(echo "scale=1; ($cpu_sec / $elapsed_sec / $ncpus) * 100" | bc)
      else
        cpu_pct="N/A"
      fi
      
      printf "%-10s %-8s %-10s %-8s %-10s %-7s%%\n" "$jobid" "$elapsed" "$node" "$maxrss_human" "$avecpu" "$cpu_pct"
    fi
  done
  sleep 10
done
