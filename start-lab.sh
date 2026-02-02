#!/bin/bash
set -e  # Exit on any error

echo "🚀 Starting SOC Lab..."

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ ERROR: Docker daemon is not running!"
    echo "   Please start Docker Desktop and try again."
    exit 1
fi

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ ERROR: docker-compose.yml not found!"
    echo "   Make sure you're in the soc-lab directory."
    exit 1
fi

# Start containers
echo "📦 Starting containers..."
if ! docker-compose up -d; then
    echo "❌ ERROR: Failed to start containers!"
    exit 1
fi

# Wait for containers to be ready
echo "⏳ Waiting for containers to initialize..."
sleep 5

# Verify containers are running
EXPECTED_CONTAINERS=("kali-attacker" "dvwa-target" "juiceshop-target" "webgoat-target" "nginx-webserver")
FAILED_CONTAINERS=()

for container in "${EXPECTED_CONTAINERS[@]}"; do
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        FAILED_CONTAINERS+=("$container")
    fi
done

if [ ${#FAILED_CONTAINERS[@]} -gt 0 ]; then
    echo "⚠️  WARNING: Some containers failed to start:"
    for container in "${FAILED_CONTAINERS[@]}"; do
        echo "   - $container"
    done
    echo ""
    echo "Run 'docker ps -a' to see container status"
    echo "Run 'docker logs <container-name>' to check logs"
fi

# Start log collection
if [ -f "collect-docker-logs.sh" ]; then
    echo "📋 Starting log collection..."
    ./collect-docker-logs.sh
else
    echo "⚠️  WARNING: collect-docker-logs.sh not found. Skipping log collection."
fi

echo ""
echo "✅ Lab is ready!"
echo ""
echo "🔧 Access containers:"
echo "   Kali:     docker exec -it kali-attacker /bin/bash"
echo "   DVWA:     http://localhost:8080"
echo "   Juice:    http://localhost:3000"
echo "   WebGoat:  http://localhost:8081"
echo "   Nginx:    http://localhost:8082"
echo ""
echo "📊 Check status: docker ps"
echo "🛑 Stop lab:     ./stop-lab.sh"
