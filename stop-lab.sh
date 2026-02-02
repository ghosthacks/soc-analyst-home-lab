#!/bin/bash
set -e  # Exit on any error

echo "🛑 Stopping SOC Lab..."

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "⚠️  WARNING: Docker daemon is not running."
    echo "   Containers may already be stopped."
    exit 0
fi

# Stop log collection processes
echo "📋 Stopping log collection..."
if pgrep -f "docker logs" > /dev/null; then
    pkill -f "docker logs"
    echo "   ✓ Log collection stopped"
else
    echo "   ℹ️  No log collection processes found"
fi

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "⚠️  WARNING: docker-compose.yml not found!"
    echo "   Make sure you're in the soc-lab directory."
    exit 1
fi

# Stop containers
echo "📦 Stopping containers..."
if ! docker-compose down; then
    echo "❌ ERROR: Failed to stop containers!"
    echo "   Try manually: docker-compose down --remove-orphans"
    exit 1
fi

# Verify containers stopped
RUNNING_CONTAINERS=$(docker ps --filter "name=kali-attacker|dvwa-target|juiceshop-target|webgoat-target|nginx-webserver" --format '{{.Names}}' | wc -l)

if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
    echo "⚠️  WARNING: Some containers are still running:"
    docker ps --filter "name=kali-attacker|dvwa-target|juiceshop-target|webgoat-target|nginx-webserver" --format '   - {{.Names}}'
    echo ""
    echo "Force stop with: docker stop <container-name>"
else
    echo "   ✓ All containers stopped"
fi

echo ""
echo "✅ Lab stopped successfully!"
echo ""
echo "🚀 To restart: ./start-lab.sh"
echo "🧹 Clean up:   docker system prune"
