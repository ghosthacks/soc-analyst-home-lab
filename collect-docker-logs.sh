#!/bin/bash
LOG_DIR=~/soc-lab/container-logs

# Kill any existing log collection
pkill -f "docker logs -f" 2>/dev/null

# Create log files for each container (properly backgrounded)
nohup docker logs -f kali-attacker > $LOG_DIR/kali.log 2>&1 &
nohup docker logs -f dvwa-target > $LOG_DIR/dvwa.log 2>&1 &
nohup docker logs -f juiceshop-target > $LOG_DIR/juiceshop.log 2>&1 &
nohup docker logs -f nginx-webserver > $LOG_DIR/nginx.log 2>&1 &

echo "Docker log collection started. Logs are in $LOG_DIR"
ps aux | grep "docker logs" | grep -v grep
