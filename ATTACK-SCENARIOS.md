# Attack Scenarios & Detections

## Scenario 1: SSH Brute Force Attack

### Attack Details
- **Attacker**: Kali Linux (172.25.0.2)
- **Target**: Ubuntu VM (192.168.0.54)
- **User**: testuser
- **Tool**: Hydra
- **Duration**: 9 seconds
- **Attempts**: 6 before success

### Attack Command
```bash
hydra -l testuser -P /tmp/passwords.txt 192.168.0.54 ssh -t 4 -V
```

### Detection Queries

**Failed Login Detection:**
```spl
index=main source="/var/log/auth.log" "Failed password"
| stats count by user src_ip
```

**Brute Force Alert:**
```spl
index=main source="/var/log/auth.log" "Failed password"
| bin _time span=30s
| stats count as failed_attempts by _time user
| where failed_attempts > 3
```

### Response Actions
1. Block source IP in firewall
2. Lock compromised account
3. Reset password
4. Review access logs
5. Implement fail2ban

### Lessons Learned
- Weak passwords are easily cracked
- Multiple failed attempts indicate brute force
- Real-time monitoring is critical
