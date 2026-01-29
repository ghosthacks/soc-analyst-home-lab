#!/bin/bash

LOG_DIR=~/soc-lab/container-logs

# Create log files for each container
docker logs -f kali-attacker > $LOG_DIR/kali.log 2>&1 &
docker logs -f dvwa-target > $LOG_DIR/dvwa.log 2>&1 &
docker logs -f juiceshop-target > $LOG_DIR/juiceshop.log 2>&1 &
docker logs -f nginx-webserver > $LOG_DIR/nginx.log 2>&1 &

echo "Docker log collection started. Logs are in $LOG_DIR"
