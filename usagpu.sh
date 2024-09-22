#!/bin/bash

# Log file path
LOG_FILE="/var/log/system_usage.log"

echo "Time, CPU Usage, Used Memory, GPU Usage, GPU Used Memory, GPU Power"

# Infinite loop to log metrics every minute
while true
do
    # Get current date and time
    DATE=$(date '+%Y-%m-%d %H:%M:%S')

    # Get used memory in MiB
    USED_MEM=$(top -b -n1 | grep "MiB Mem" | awk '{printf "%.2f", $8/1024}')

    # Get CPU usage (user + system)
    CPU_USAGE=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')

    # Get GPU usage, memory usage, and power consumption from nvidia-smi
    GPU_STATS=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,power.draw --format=csv,noheader,nounits)

    # Parse GPU stats into variables
    GPU_UTIL=$(echo $GPU_STATS | awk -F, '{print $1"%"}')
    GPU_MEM_USED=$(echo $GPU_STATS | awk -F, '{print $2" MiB"}')
    GPU_MEM_USED_GB=$(awk "BEGIN {printf \"%.2f\", $GPU_MEM_USED/1024}")
    GPU_POWER=$(echo $GPU_STATS | awk -F, '{print $3" W"}')

    # Append the date, CPU usage, used memory, and GPU stats to the log file in one line
    echo "$DATE, $CPU_USAGE%, $USED_MEM GB, $GPU_UTIL, $GPU_MEM_USED_GB GB, $GPU_POWER"

    # Wait for 60 seconds before repeating
    sleep 60
done
