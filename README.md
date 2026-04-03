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
## 🔍 SIEM Integration - Wazuh

### Overview
The lab includes **Wazuh** - a free, open-source SIEM/XDR platform running in a custom Docker container with persistent auto-start capabilities.

**Why Wazuh?**
- No licensing limitations (unlimited data ingestion)
- Built-in EDR capabilities
- File integrity monitoring (FIM)
- Vulnerability detection
- Active response capabilities
- Industry-standard open-source platform

### Architecture

**Custom Docker Image:**
- Built from `jrei/systemd-ubuntu:22.04` with Wazuh pre-configured
- Automatic installation on first boot
- Persistent auto-start system via systemd service
- All configurations and data preserved across restarts

**Wazuh Components:**
- **Wazuh Manager** - Core SIEM engine for log analysis, correlation, and alerting
- **Wazuh Indexer** - OpenSearch-based data storage (~5GB memory allocation)
- **Wazuh Dashboard** - Web-based interface for visualization and incident response

**Container Specifications:**
- **Base Image:** `jrei/systemd-ubuntu:22.04` (systemd-enabled)
- **Custom Image:** `wazuh-siem:latest` (built from Dockerfile.wazuh)
- **Platform:** `linux/amd64` (required for Wazuh/Java compatibility on Apple Silicon)
- **Memory Requirements:** 
  - Minimum: 10GB Docker Desktop allocation
  - Indexer: ~5GB during operation
  - Manager: ~400MB
  - Dashboard: ~230MB
- **Privileges:** Runs privileged with cgroup access for systemd functionality
- **First Boot Time:** 15-18 minutes (Wazuh installation)
- **Subsequent Boots:** 2-3 minutes (services start automatically)

### Access

- **Dashboard:** `https://localhost:8443`
- **Default Credentials:** `admin` / `admin` ⚠️ **Change after first login**
- **Wazuh API:** `https://localhost:55000`
- **Indexer API:** `https://localhost:9200`

**🔒 Security Note:** All Wazuh ports are bound to `127.0.0.1` (localhost only) and are NOT exposed to your home network or the internet.

### Building the Image

The custom Wazuh image is built using:
```bash
docker build --platform linux/amd64 -t wazuh-siem:latest -f Dockerfile.wazuh .
```

**Key Files:**
- `Dockerfile.wazuh` - Custom image definition
- `wazuh-first-boot.sh` - First-time installation script
- `docker-compose.yml` - Service configuration with build directive

**Image Features:**
- Installs Wazuh automatically on first container boot
- Creates systemd auto-start service
- Configures proper permissions and security settings
- Survives container restarts with full persistence

### Service Status

Check all Wazuh services:
```bash
# Check Wazuh manager services
docker exec -it wazuh-server /var/ossec/bin/wazuh-control status

# Check indexer
docker exec -it wazuh-server systemctl status wazuh-indexer

# Check dashboard
docker exec -it wazuh-server systemctl status wazuh-dashboard

# Check auto-start service
docker exec -it wazuh-server systemctl status wazuh-autostart.service
```

Expected output for manager:
- ✅ wazuh-modulesd, wazuh-monitord, wazuh-logcollector
- ✅ wazuh-remoted, wazuh-syscheckd, wazuh-analysisd
- ✅ wazuh-execd, wazuh-db, wazuh-authd, wazuh-apid

### Implementation Challenges & Solutions

**Challenge 1: Wazuh Installation in Docker Build**
- **Issue:** Wazuh installer requires systemd to be running, which isn't available during `docker build`
- **Solution:** Created two-stage approach:
  1. Dockerfile creates base image with installation scripts
  2. First container boot triggers automatic Wazuh installation via systemd service

**Challenge 2: Installation Timeout**
- **Issue:** Wazuh installation takes 15+ minutes, exceeding default systemd timeout
- **Root Cause:** Installing indexer (~3 min), manager (~5 min), and dashboard (~3 min) sequentially
- **Solution:** Increased systemd service timeout to 1200 seconds (20 minutes)
```bash
TimeoutStartSec=1200
```

**Challenge 3: Permission Persistence**
- **Issue:** `/etc/wazuh-indexer/backup` permissions reset on container restart
- **Solution:** Auto-fix permissions in startup script before starting services
```bash
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/backup
chmod 750 /etc/wazuh-indexer/backup
```

**Challenge 4: Java JNA Library Loading**
- **Issue:** Indexer failed with `UnsatisfiedLinkError` when `/tmp` was mounted as tmpfs
- **Solution:** Removed `/tmp` from tmpfs mounts in docker-compose.yml

**Challenge 5: OpenSearch Security Initialization**
- **Issue:** Dashboard couldn't connect - "Not yet initialized"
- **Solution:** Run securityadmin after indexer starts
```bash
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh \
  -cd /etc/wazuh-indexer/opensearch-security/ \
  -icl -nhnv \
  -cacert /etc/wazuh-indexer/certs/root-ca.pem \
  -cert /etc/wazuh-indexer/certs/admin.pem \
  -key /etc/wazuh-indexer/certs/admin-key.pem
```

### Auto-Start Configuration

**Startup Script:** `/usr/local/bin/start-wazuh.sh` (inside container)
```bash
#!/bin/bash
# Run first-boot installation if needed
/usr/local/bin/wazuh-first-boot.sh

# Fix permissions
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/backup 2>/dev/null || true
chmod 750 /etc/wazuh-indexer/backup 2>/dev/null || true

# Start services
systemctl start wazuh-indexer
sleep 45  # Wait for full initialization

# Initialize security
export JAVA_HOME=/usr/share/wazuh-indexer/jdk
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh \
  -cd /etc/wazuh-indexer/opensearch-security/ \
  -icl -nhnv \
  -cacert /etc/wazuh-indexer/certs/root-ca.pem \
  -cert /etc/wazuh-indexer/certs/admin.pem \
  -key /etc/wazuh-indexer/certs/admin-key.pem 2>/dev/null || true

systemctl start wazuh-manager
systemctl start wazuh-dashboard
/var/ossec/bin/wazuh-control start
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
TimeoutStartSec=1200

[Install]
WantedBy=multi-user.target
```

### Agent Deployment

**Mac Host Agent:**
- **Status:** Active (ID: 001)
- **Install Location:** `/Library/Ossec/`
- **Events Collected:** System logs, file integrity, security assessments
- **Start Command:** `sudo /Library/Ossec/bin/wazuh-control start`
- **Configuration:** `/Library/Ossec/etc/ossec.conf`

**Installation:**
```bash
curl -so wazuh-agent.pkg https://packages.wazuh.com/4.x/macos/wazuh-agent-4.7.5-1.arm64.pkg
echo "WAZUH_MANAGER='127.0.0.1' && WAZUH_AGENT_NAME='macbook-host'" > /tmp/wazuh_envs
sudo installer -pkg ./wazuh-agent.pkg -target /
sudo /Library/Ossec/bin/wazuh-control start
```

### Troubleshooting

**Dashboard not loading:**
```bash
# Check if indexer is running
docker exec -it wazuh-server systemctl status wazuh-indexer

# Manually initialize security if needed
docker exec -it wazuh-server bash -c 'export JAVA_HOME=/usr/share/wazuh-indexer/jdk && \
  /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh \
  -cd /etc/wazuh-indexer/opensearch-security/ -icl -nhnv \
  -cacert /etc/wazuh-indexer/certs/root-ca.pem \
  -cert /etc/wazuh-indexer/certs/admin.pem \
  -key /etc/wazuh-indexer/certs/admin-key.pem'

# Restart dashboard
docker exec -it wazuh-server systemctl restart wazuh-dashboard
```

**First boot taking too long:**
- This is normal! First boot installs Wazuh and takes 15-18 minutes
- Monitor progress: `docker logs -f wazuh-server`
- Subsequent boots will be much faster (2-3 minutes)

**Services not auto-starting:**
```bash
# Check auto-start service
docker exec -it wazuh-server systemctl status wazuh-autostart.service

# Check logs
docker exec -it wazuh-server journalctl -u wazuh-autostart.service -n 50
```

### Next Steps

- [X] Wazuh SIEM deployed and operational
- [X] Mac host agent installed and collecting data
- [ ] Deploy agents to Docker containers (Kali, DVWA, etc.)
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

- **Wazuh Documentation:** https://documentation.wazuh.com
- **GitHub Repo:** https://github.com/wazuh/wazuh
- **Custom Image Build:** See `Dockerfile.wazuh` and `wazuh-first-boot.sh`
---
## Author

[Nathan Harris]  
Aspiring SOC Analyst

## License

MIT License - Feel free to use this for your own learning!
## Agent Deployment

**Mac Host Agent:**
- **Status:** Active (ID: 001)
- **Install Location:** /Library/Ossec/
- **Events Collected:** System logs, file integrity, security assessments
- **Start Command:** `sudo /Library/Ossec/bin/wazuh-control start`

**Container Agents:**
- Pending - requires systemd-enabled base images or alternative init system

