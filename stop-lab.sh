#!/bin/bash
echo "🛑 Stopping SOC Lab..."

# Stop log collection processes
pkill -f "docker logs"

# Stop containers
docker-compose down

echo "✅ Lab stopped successfully!"
echo "To restart: ./start-lab.sh"
