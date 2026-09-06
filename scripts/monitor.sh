#!/bin/bash

#os name
source /etc/os-release

# Load monitoring thresholds
source /linux-system-monitor/config/monitor.conf

LOG_FILE="/linux-system-monitor/logs/monitor.log"
REPORT_FILE="/linux-system-monitor/reports/system-reports.txt"

exec > >(tee -a "$LOG_FILE" | tee "$REPORT_FILE") 2>&1

echo "========================================"
echo "       LINUX SYSTEM MONITOR"
echo "========================================"

echo "Hostname      : $HOSTNAME"
echo "OS            : $PRETTY_NAME"
echo "Kernel        : $(uname -r)"
echo "Uptime        : $(uptime -p)"

echo "----------------------------------------"
echo "SYSTEM RESOURCES"
echo "----------------------------------------"

# CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
printf "CPU Usage     : %.2f%%\n" "$CPU_USAGE"

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) ))
then
    echo "[WARNING] CPU usage is above ${CPU_THRESHOLD}%"
else
    echo "[OK] CPU usage is normal"
fi

# Load Average
LOAD=$(awk '{print $1}' /proc/loadavg)
echo "Load Average  : $LOAD"

# Memory Usage
MEMORY=$(free | awk '/Mem:/ {printf "%.2f", ($3/$2)*100}')
printf "Memory Usage  : %.2f%%\n" "$MEMORY"

if (( $(echo "$MEMORY > $MEMORY_THRESHOLD" | bc -l) ))
then
    echo "[WARNING] Memory usage is above ${MEMORY_THRESHOLD}%"
else
    echo "[OK] Memory usage is normal"
fi

echo "----------------------------------------"
echo "DISK MONITORING"
echo "----------------------------------------"

df -h --output=target,pcent | grep -v "Mounted" | while read mount usage
do
    USAGE=$(echo "$usage" | tr -d '%')

    echo "$mount : $usage"

    if [ "$USAGE" -gt "$DISK_THRESHOLD" ]
    then
        echo "[WARNING] $mount disk usage is above ${DISK_THRESHOLD}%"
    fi
done

echo "----------------------------------------"
echo "TOP PROCESSES"
echo "----------------------------------------"

ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6

echo "----------------------------------------"
echo "NETWORK MONITORING"
echo "----------------------------------------"

echo "Network Interfaces:"
ip -br addr

echo
echo "Default Route:"
ip route | grep default

echo
echo "Internet Connectivity:"

if ping -c 2 -W 2 8.8.8.8 >/dev/null 2>&1
then
    echo "Status        : CONNECTED"
     echo "[OK] Network connectivity is available"
else
    echo "Status        : NOT CONNECTED"
     echo "[CRITICAL] Network connectivity failed"
fi

echo
echo "----------------------------------------"
echo "SERVICE MONITORING"
echo "----------------------------------------"

check_service() {
    SERVICE=$1

    if systemctl is-active --quiet "$SERVICE"
    then
        echo "$SERVICE : RUNNING"
    else
        echo "$SERVICE : DOWN"
	 echo "[CRITICAL] $SERVICE service is not running"
    fi
}

check_service sshd
check_service firewalld

echo "========================================"

