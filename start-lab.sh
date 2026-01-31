#!/bin/bash
echo "🚀 Starting SOC Lab..."

# Start containers
docker-compose up -d

# Wait for containers to be ready
sleep 5

# Start log collection
./collect-docker-logs.sh

echo "✅ Lab is ready!"
echo "Access Kali: docker exec -it kali-attacker /bin/bash"
