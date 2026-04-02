# SOC Analyst Home Lab

## Overview
A cybersecurity home lab built for practicing SOC analyst skills, including threat detection, log analysis, and incident response using Docker containers and Splunk SIEM.

## Lab Architecture

### Infrastructure
- **Host**: MacBook (Apple Silicon)
- **SIEM**: Splunk Enterprise (running on Ugreen NAS VM at 192.168.0.54)
- **Containerization**: Docker Desktop
- **Network**: Custom isolated Docker network (172.25.0.0/16)

### Lab Components

## Platform Notes

This lab is optimized for Apple Silicon (M1/M2/M3) Macs:
- WebGoat is used instead of Metasploitable2 for better ARM64 compatibility
- All containers run natively or via Rosetta 2 emulation
- Works equally well on Intel Macs and Linux systems

#### Attack Machine
- **Kali Linux** - Penetration testing platform with tools:
  - nmap (network scanning)
  - sqlmap (SQL injection)
  - hydra (password cracking)
  - nikto (web vulnerability scanning)
  - metasploit (exploitation framework)

#### Vulnerable Targets
- **DVWA** (Damn Vulnerable Web Application) - Port 8080
- **OWASP Juice Shop** - Port 3000
- **Nginx Web Server** - Port 8082

#### Monitoring & Detection
- **Splunk Universal Forwarder** (on Mac host)
- **Docker Log Collection** - Real-time container log forwarding
- **Custom Docker Network** - Isolated lab environment
- **OWASP WebGoat** - Port 8081 (WebGoat), Port 9090 (WebWolf)

## Setup Instructions

### Prerequisites
- Docker Desktop installed
- Splunk instance running (can be VM, NAS, or cloud)
- Basic familiarity with command line

### Option 1: Clone This Repository (If Using My Lab)

If you're using this repository as a template:
```bash
# Clone the repository
git clone https://github.com/ghosthacks/soc-analyst-home-lab.git
cd soc-analyst-home-lab

# Start the lab
docker-compose up -d
```

### Option 2: Build From Scratch (Recommended for Learning)

If you want to build this lab yourself:

**1. Create project directory**
```bash
mkdir ~/soc-lab
cd ~/soc-lab
```

**2. Create docker-compose.yml**

Create a `docker-compose.yml` file with the following content:
(See docker-compose.yml in this repository)

**3. Create log collection script**

Create `collect-docker-logs.sh`:
(See collect-docker-logs.sh in this repository)

Make it executable:
```bash
chmod +x collect-docker-logs.sh
```

**4. Start the lab**
```bash
# Pull all container images
docker-compose pull

# Start all containers
docker-compose up -d

# Verify containers are running
docker-compose ps
```

**5. Set up log forwarding**
```bash
# Create logs directory
mkdir -p container-logs

# Start log collection
./collect-docker-logs.sh
```

**6. Configure Splunk Universal Forwarder**

Install Splunk Universal Forwarder on your host machine, then:
```bash
# Navigate to Splunk forwarder (Mac example)
cd /Applications/SplunkForwarder/bin

# Start and accept license
sudo ./splunk start --accept-license

# Add your Splunk server as forwarding destination
sudo ./splunk add forward-server YOUR-SPLUNK-IP:9997

# Monitor Mac system logs
sudo ./splunk add monitor /var/log/system.log -index main

# Monitor Docker container logs
sudo ./splunk add monitor /Users/YOUR-USERNAME/soc-lab/container-logs -index main

# Restart forwarder
sudo ./splunk restart
```

**Note:** Replace `YOUR-SPLUNK-IP` with your Splunk instance IP address and `YOUR-USERNAME` with your actual username.

**7. Enable receiving on Splunk server**

On your Splunk instance:
- Go to Settings > Forwarding and receiving
- Configure receiving > New Receiving Port
- Enter port 9997
- Save

**8. Access Kali Linux**
```bash
docker exec -it kali-attacker /bin/bash

# Install tools
apt update
apt install -y nmap sqlmap nikto hydra metasploit-framework curl wget netcat-traditional dnsutils iputils-ping
```

### Verification

1. Check all containers are running:
```bash
docker-compose ps
```

2. Verify network connectivity from Kali:
```bash
docker exec -it kali-attacker ping -c 2 dvwa-target
```

3. Access vulnerable applications:
   - DVWA: http://localhost:8080 (admin/password)
   - Juice Shop: http://localhost:3000
   - Nginx: http://localhost:8082

4. Verify logs in Splunk:
   - Go to your Splunk web interface
   - Search: `index=main | stats count by sourcetype`
   - You should see logs from your containers

## Attack Scenarios & Detections

### Scenario 1: Brute Force Attack Detection

**Attack Steps:**
1. Access Kali container
2. Run hydra brute force attack against DVWA login

**Detection Query:**
```spl
index=main source="*/dvwa.log" "login"
| bin _time span=30s
| stats count as login_attempts by _time
| where login_attempts > 10
| eval alert="POSSIBLE BRUTE FORCE ATTACK DETECTED"
```

**Alert Configuration:**
- Trigger: More than 10 login attempts in 30 seconds
- Action: Log to triggered alerts
- Schedule: Every 5 minutes

## Access Points

- **DVWA**: http://localhost:8080 (admin/password)
- **Juice Shop**: http://localhost:3000
- **Nginx**: http://localhost:8082
- **Splunk**: http://192.168.0.54:8000
- **WebGoat**: http://localhost:8081/WebGoat (register to create account)
- **WebWolf**: http://localhost:9090/WebWolf (companion app for WebGoat)

## Skills Demonstrated

- Docker containerization and networking
- SIEM configuration and log forwarding
- Security event detection and alerting
- Penetration testing techniques
- Incident response procedures
- Security monitoring and analysis

## Future Enhancements

- [ ] Add Suricata IDS for network traffic analysis
- [ ] Implement additional attack scenarios (SQL injection, XSS, port scanning)
- [X] Create comprehensive SOC dashboard
- [ ] Add automated incident response playbooks
- [ ] Integrate threat intelligence feeds
- [X] Set up email alerting

## Tools & Technologies

- Docker & Docker Compose
- Splunk Enterprise & Universal Forwarder
- Kali Linux
- DVWA (Damn Vulnerable Web Application)
- OWASP Juice Shop
- Bash scripting

## Learning Resources

- [Splunk Documentation](https://docs.splunk.com)
- [DVWA Guide](https://github.com/digininja/DVWA)
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)
- [Kali Linux Tools](https://www.kali.org/tools/)


## 🛡️ Blue Team Detection & Analysis

### DVWA Brute Force Attack Detection
Successfully detected and analyzed a credential brute force attack using Splunk SIEM.

**Attack Scenario:**
- **Tool:** Hydra password brute forcer
- **Target:** DVWA login page
- **Volume:** 418 login attempts from Kali container (172.25.0.3)
- **Success Rate:** 33.4% (attacker gained access)
- **User Agent:** Mozilla/5.0 (Hydra)

**Detection Method:**
- Splunk Universal Forwarder collecting Docker container logs
- Custom SPL queries for field extraction and correlation
- Regex parsing for source IP, HTTP method, status codes, user agent

**Dashboard Components:**
1. **Attack Timeline** — Visualized 240 attempts/minute spike
2. **Source IP Analysis** — Identified single attacking host
3. **Success vs Failure Rate** — 66.6% failed, 33.4% successful (HTTP 302 redirects)
4. **Recent Activity Table** — Real-time attack details with user agent fingerprinting

**Alert Configuration:**
- **Threshold:** >20 login attempts in 60 minutes
- **Trigger:** Automated detection with 10-minute suppression
- **Action:** Alert logged in Splunk (email disabled on free license)

📊 **[View Dashboard](dashboards/DVWA_Brute_Force_Detection.pdf)**

---

**Key Takeaways:**
- HTTP status codes reveal attack success (200 = failed, 302 = success)
- User agent strings provide tool attribution
- Concentrated time-based attacks create distinctive log patterns
- Threshold-based alerting effective for brute force detection

## 🔍 SIEM Integration - Wazuh

### Overview
The lab now includes **Wazuh** - a free, open-source SIEM/XDR platform running in a Docker container alongside the existing infrastructure.

**Why Wazuh?**
- No licensing limitations (unlimited data ingestion)
- Built-in EDR capabilities
- File integrity monitoring (FIM)
- Vulnerability detection
- Active response capabilities
- Industry-standard open-source platform

### Architecture

**Wazuh Container Components:**
- **Wazuh Manager** - Core SIEM engine for log analysis, correlation, and alerting
- **Wazuh Indexer** - OpenSearch-based data storage (4GB RAM allocation)
- **Wazuh Dashboard** - Web-based interface for visualization and incident response

**Container Specifications:**

- **Image:** `jrei/systemd-ubuntu:22.04` (systemd-enabled for service management)
- **Platform:** `linux/amd64` (required for Wazuh/Java compatibility on Apple Silicon)
- **Memory Requirements:** 
  - Minimum: 8GB Docker Desktop allocation
  - Recommended: 10GB Docker Desktop allocation
  - Indexer alone: ~4-5GB during operation
- **Privileges:** Runs privileged with cgroup access for systemd functionality
- **Startup Time:** 90-120 seconds for full initialization

### Access

- **Dashboard:** `https://localhost:8443`
- **Default Credentials:** `admin` / `admin` ⚠️ **Change immediately after first login**
- **Wazuh API:** `https://localhost:55000`
- **Indexer API:** `https://localhost:9200`

**🔒 Security Note:** All Wazuh ports are bound to `127.0.0.1` (localhost only) and are NOT exposed to your home network or the internet.

**Password File (inside container):**
```bash
docker exec -it wazuh-server cat wazuh-install-files/wazuh-passwords.txt
```
This file contains all generated passwords for:
- Dashboard admin user
- Wazuh API users
- Indexer internal users

**🔒 Security Note:** All Wazuh ports are bound to `127.0.0.1` (localhost only) and are NOT exposed to your home network or the internet.

### Service Status

Check all Wazuh services:
```bash
docker exec -it wazuh-server /var/ossec/bin/wazuh-control status
```

Expected output:
- ✅ wazuh-modulesd
- ✅ wazuh-monitord
- ✅ wazuh-remoted
- ✅ wazuh-analysisd
- ✅ wazuh-db
- ✅ wazuh-apid

### Implementation Challenges & Solutions

**Challenge 1: Java JNA Library Loading**
- **Issue:** Wazuh indexer failed with `UnsatisfiedLinkError` when `/tmp` was mounted as tmpfs
- **Root Cause:** Java's JNA (Java Native Access) library cannot load native code from tmpfs filesystems
- **Solution:** Removed `/tmp` from tmpfs mounts in docker-compose.yml
```yaml
tmpfs:
  - /run
  - /run/lock
  # - /tmp  # REMOVED - causes Java JNA errors
```

**Challenge 2: OpenSearch Security Not Initialized**
- **Issue:** Indexer running but dashboard couldn't connect - "Not yet initialized (you may need to run securityadmin)"
- **Root Cause:** Wazuh installer doesn't properly initialize the OpenSearch security plugin in containerized environments
- **Solution:** Manually run securityadmin tool after indexer starts
```bash
export JAVA_HOME=/usr/share/wazuh-indexer/jdk
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh \
  -cd /etc/wazuh-indexer/opensearch-security/ \
  -icl -nhnv \
  -cacert /etc/wazuh-indexer/certs/root-ca.pem \
  -cert /etc/wazuh-indexer/certs/admin.pem \
  -key /etc/wazuh-indexer/certs/admin-key.pem
```
**Note:** Config files are in `/etc/wazuh-indexer/opensearch-security/`, NOT `/usr/share/wazuh-indexer/plugins/opensearch-security/securityconfig/`

**Challenge 3: Systemd in Docker Container**
- **Issue:** Standard Ubuntu image doesn't include systemd, breaking Wazuh's service management
- **Solution:** Used `jrei/systemd-ubuntu:22.04` image with pre-configured systemd support
- **Configuration:** Requires privileged mode and cgroup access
```yaml
privileged: true
security_opt:
  - seccomp:unconfined
volumes:
  - /sys/fs/cgroup:/sys/fs/cgroup:rw
command: /sbin/init
```

**Challenge 4: Indexer Permission Errors on Restart**
- **Issue:** `java.nio.file.AccessDeniedException: /etc/wazuh-indexer/backup` on container restart
- **Root Cause:** File permissions reset when container restarts (not persisted in volume)
- **Solution:** Added permission fixes to startup script
```bash
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/backup
chown -R wazuh-indexer:wazuh-indexer /var/log/wazuh-indexer
chmod 750 /etc/wazuh-indexer/backup
```

**Challenge 5: Indexer OOM Killed on Auto-Start (Exit Code 137)**
- **Issue:** Indexer process killed with exit code 137 during container boot
- **Root Cause:** Memory pressure when all services start simultaneously + insufficient Docker memory allocation
- **Solution 1:** Increased Docker Desktop memory from 7.6GB to 10GB
  - Settings → Resources → Memory → 10GB → Apply & Restart
- **Solution 2:** Added 10-second delay to auto-start service to reduce boot race conditions
```bash
[Service]
Type=oneshot
ExecStartPre=/bin/sleep 10
ExecStart=/usr/local/bin/start-wazuh.sh
TimeoutStartSec=300
```

**Challenge 6: Services Not Auto-Starting on Container Restart**
- **Issue:** All Wazuh services stopped when container restarted
- **Solution:** Created systemd service that runs startup script on boot
```bash
# Startup script: /usr/local/bin/start-wazuh.sh
# Systemd service: /etc/systemd/system/wazuh-autostart.service
systemctl enable wazuh-autostart.service
```
**Startup Time:** ~90-120 seconds (45s indexer wait + initialization + dashboard)

### Auto-Start Configuration

The lab includes an automated startup system that ensures all Wazuh services start correctly on container boot.

**Startup Script:** `/usr/local/bin/start-wazuh.sh`
```bash
#!/bin/bash
# Fix permissions that reset on container restart
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/backup 2>/dev/null || true
chown -R wazuh-indexer:wazuh-indexer /var/log/wazuh-indexer 2>/dev/null || true
chmod 750 /etc/wazuh-indexer/backup 2>/dev/null || true

# Start indexer and wait for full initialization
systemctl start wazuh-indexer
sleep 45

# Initialize OpenSearch security plugin
export JAVA_HOME=/usr/share/wazuh-indexer/jdk
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh \
  -cd /etc/wazuh-indexer/opensearch-security/ \
  -icl -nhnv \
  -cacert /etc/wazuh-indexer/certs/root-ca.pem \
  -cert /etc/wazuh-indexer/certs/admin.pem \
  -key /etc/wazuh-indexer/certs/admin-key.pem 2>/dev/null || true

# Start manager and dashboard
systemctl start wazuh-manager
systemctl start wazuh-dashboard
/var/ossec/bin/wazuh-control start

echo "Wazuh fully started"
```

**Systemd Service:** `/etc/systemd/system/wazuh-autostart.service`
```ini
[Unit]
Description=Wazuh Auto-Start Service
After=network.target multi-user.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 10
ExecStart=/usr/local/bin/start-wazuh.sh
RemainAfterExit=yes
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
```

**Verification Commands:**
```bash
# Check auto-start service
docker exec -it wazuh-server systemctl status wazuh-autostart.service

# Check all Wazuh services
docker exec -it wazuh-server /var/ossec/bin/wazuh-control status

# Check indexer specifically
docker exec -it wazuh-server systemctl status wazuh-indexer

# Check dashboard
docker exec -it wazuh-server systemctl status wazuh-dashboard
```

### Stored Credentials

Admin credentials stored inside container:
```bash
docker exec -it wazuh-server cat wazuh-install-files/wazuh-passwords.txt
```

Contains passwords for:
- Dashboard admin user
- API users (wazuh, wazuh-wui)
- Indexer internal users

### Next Steps

- [ ] Install Wazuh agents on Mac host
- [ ] Deploy agents to Docker containers (Kali, DVWA, Juice Shop, etc.)
- [ ] Configure log collection from all attack/target containers
- [ ] Create custom detection rules for attack patterns
- [ ] Build security dashboards for:
  - Brute force attacks
  - SQL injection attempts
  - Port scanning activity
  - Web application attacks
- [ ] Integrate with attack scenarios for real-time detection
- [ ] Set up automated incident response workflows

### Resources

- **Installation Guide:** `bash wazuh-install.sh -a` (all-in-one inside container)
- **Wazuh Docs:** https://documentation.wazuh.com
- **GitHub Repo:** https://github.com/wazuh/wazuh

---
## Author

[Nathan Harris]  
Aspiring SOC Analyst

## License

MIT License - Feel free to use this for your own learning!
