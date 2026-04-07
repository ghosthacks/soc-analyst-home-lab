# Attack Detection Dashboard

## Overview
Custom Wazuh dashboard for real-time attack monitoring and threat visualization.

## Panels

### 1. Attack Timeline
- Visualization: Area chart
- Shows: Attack frequency over time
- Use case: Identify attack patterns and peak activity

### 2. Attack Types  
- Visualization: Pie chart
- Shows: Distribution of attack techniques
- Detected: Gobuster, Nikto, SQLMap, etc.

### 3. Attack Source IPs
- Visualization: Data table
- Shows: Top attacking IP addresses
- Use case: Threat actor identification

## Detection Rules
- Rule 100020: Directory brute force (Gobuster)
- Rule 100021: Multiple 404s (enumeration)
- Rule 100022: Attack tools in User-Agent

## MITRE ATT&CK Coverage
- T1083: File and Directory Discovery
- T1595: Active Scanning

