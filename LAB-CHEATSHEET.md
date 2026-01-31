# SOC Lab Quick Reference Guide

## 🎯 Quick Start/Stop

### Start Everything
```bash
cd ~/soc-lab
./start-lab.sh
```

### Stop Everything
```bash
cd ~/soc-lab
./stop-lab.sh
```

---

## 🚀 Starting the Lab

### Start All Containers
```bash
cd ~/soc-lab
docker-compose up -d
```

### Check Container Status
```bash
docker-compose ps
```

### Start Log Collection
```bash
cd ~/soc-lab
./collect-docker-logs.sh
```

### Start Splunk Forwarder (Mac)
```bash
cd /Applications/SplunkForwarder/bin
sudo ./splunk start
```

---

## 🔐 Accessing Containers

### Kali Linux (Attack Machine)
```bash
docker exec -it kali-attacker /bin/bash
```

### DVWA
```bash
docker exec -it dvwa-target /bin/bash
```

### Juice Shop
```bash
docker exec -it juiceshop-target /bin/bash
```

### Nginx
```bash
docker exec -it nginx-webserver /bin/sh
```

---

## 🌐 Web Access

| Application | URL | Credentials |
|------------|-----|-------------|
| DVWA | http://localhost:8080 | admin / password |
| Juice Shop | http://localhost:3000 | (create account) |
| Nginx | http://localhost:8082 | N/A |
| Splunk | http://192.168.0.54:8000 | (your credentials) |

---

## 🛠️ Common Kali Commands

### Network Scanning
```bash
# Ping test
ping -c 2 dvwa-target

# Discover all hosts
nmap -sn 172.25.0.0/24

# Port scan
nmap -sV dvwa-target

# Aggressive scan
nmap -A juiceshop-target
```

### Web Attacks
```bash
# SQL injection with sqlmap
sqlmap -u "http://dvwa-target/vulnerabilities/sqli/?id=1&Submit=Submit" --batch

# Web vulnerability scan
nikto -h http://dvwa-target

# Brute force login
hydra -l admin -P /tmp/passwords.txt dvwa-target http-get-form "/login.php:username=^USER^&password=^PASS^:Login failed"
```

---

## 📊 Splunk Queries

### Check All Data Sources
```spl
index=main | stats count by sourcetype
```

### View Docker Container Logs
```spl
index=main sourcetype="docker:container:logs"
```

### Brute Force Detection
```spl
index=main source="*/dvwa.log" "login"
| bin _time span=30s
| stats count as login_attempts by _time
| where login_attempts > 10
| eval alert="POSSIBLE BRUTE FORCE ATTACK DETECTED"
```

### Failed Login Timeline
```spl
index=main source="*/dvwa.log" "login" OR "failed"
| timechart count
```

### Top Activity by Source
```spl
index=main | stats count by source | sort -count
```

---

## 🔧 Container Management

### View Container Logs
```bash
docker logs kali-attacker
docker logs dvwa-target
docker logs -f juiceshop-target  # Follow in real-time
```

### Restart a Container
```bash
docker restart kali-attacker
```

### Stop All Containers
```bash
cd ~/soc-lab
docker-compose down
```

### Restart All Containers
```bash
cd ~/soc-lab
docker-compose restart
```

### Remove Everything (Clean Slate)
```bash
cd ~/soc-lab
docker-compose down -v  # Removes volumes too
```

---

## 🔍 Troubleshooting

### Splunk Forwarder Issues
```bash
# Check status
cd /Applications/SplunkForwarder/bin
sudo ./splunk status

# View forwarder logs
tail -50 /Applications/SplunkForwarder/var/log/splunk/splunkd.log

# Restart forwarder
sudo ./splunk restart

# Check forwarding configuration
sudo ./splunk list forward-server
```

### Container Not Starting
```bash
# View detailed logs
docker logs <container-name>

# Check Docker resources
docker system df

# Restart Docker Desktop
# Click Docker icon in menu bar > Restart
```

### Network Issues
```bash
# Check Docker network
docker network inspect soc-lab_lab_network

# Test connectivity from Kali
docker exec -it kali-attacker ping dvwa-target
```

---

## 📝 Git Commands

### Save Your Work
```bash
cd ~/soc-lab
git add .
git commit -m "Description of changes"
git push
```

### Check Status
```bash
git status
```

### View Commit History
```bash
git log --oneline
```

---

## 🎯 Attack Scenarios

### Scenario 1: Brute Force Attack
1. Access Kali: `docker exec -it kali-attacker /bin/bash`
2. Create password list: `echo -e "password\nadmin\n123456" > /tmp/pass.txt`
3. Run hydra: `hydra -l admin -P /tmp/pass.txt dvwa-target http-get-form`
4. Check Splunk for detections

### Scenario 2: Port Scanning
1. Access Kali
2. Run: `nmap -sV -p- dvwa-target`
3. Search Splunk for scan patterns

### Scenario 3: SQL Injection
1. Access Kali
2. Run: `sqlmap -u "http://dvwa-target/vulnerabilities/sqli/?id=1" --batch`
3. Create detection query in Splunk

---

## 🆘 Emergency Commands

### Kill All Containers
```bash
docker stop $(docker ps -q)
```

### Free Up Disk Space
```bash
docker system prune -a
```

### Reset Lab Completely
```bash
cd ~/soc-lab
docker-compose down -v
docker-compose up -d
./collect-docker-logs.sh
```

---

## 📚 Useful Resources

- Splunk Docs: https://docs.splunk.com
- DVWA Guide: https://github.com/digininja/DVWA
- Kali Tools: https://www.kali.org/tools/
- OWASP Juice Shop: https://owasp.org/www-project-juice-shop/

---

**Last Updated:** $(1/30/2026)
**GitHub:** https://github.com/ghosthacks/soc-analyst-home-lab
