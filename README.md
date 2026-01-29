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

## Setup Instructions

### Prerequisites
- Docker Desktop installed
- Splunk instance running (can be VM, NAS, or cloud)
- Basic familiarity with command line

### Option 1: Clone This Repository (If Using My Lab)

If you're using this repository as a template:
```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/soc-analyst-home-lab.git
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
- [ ] Create comprehensive SOC dashboard
- [ ] Add automated incident response playbooks
- [ ] Integrate threat intelligence feeds
- [ ] Set up email alerting

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

## Author

[Nathan Harris]  
Aspiring SOC Analyst

## License

MIT License - Feel free to use this for your own learning!
