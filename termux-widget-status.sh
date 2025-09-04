#!/data/data/com.termux/files/usr/bin/bash

# Galileosky Server Status Widget Script
# Place this file in ~/.shortcuts/ directory in Termux

# Set the project directory
PROJECT_DIR="/data/data/com.termux/files/home/ohw-mobs"

# Change to project directory
cd "$PROJECT_DIR"

echo "=== OHW Parser Server Status ==="

# Check if server is running
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    echo "✅ Server is RUNNING"
    echo ""
    
    # Show PID if available
    if [ -f ~/ohw-server.pid ]; then
        PID=$(cat ~/ohw-server.pid)
        echo "📊 Process ID: $PID"
    fi
    
    echo ""
    echo "Processes:"
    ps aux | grep -E "(termux-enhanced|termux-simple)" | grep -v grep
    
    echo ""
    echo "Ports in use:"
    netstat -tlnp 2>/dev/null | grep -E ":3001|:3003" || echo "No ports found"
    
    echo ""
    echo "Access URLs:"
    echo "🌐 Web Interface: http://localhost:3001"
    echo "📡 API Endpoint: http://localhost:3001/api"
    echo "🔌 TCP Server: localhost:3003"
    
    # Get network IP
    LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "Not available")
    if [ "$LOCAL_IP" != "Not available" ]; then
        echo "🌍 Network Access: http://$LOCAL_IP:3001"
    fi
else
    echo "❌ Server is NOT RUNNING"
    echo ""
    echo "To start server, use one of these commands:"
    echo "cd $PROJECT_DIR"
    echo "node termux-enhanced-backend.js  # Full features"
    echo "node termux-simple-backend.js    # Simple version"
    echo ""
    echo "Or use the 'Start Server' widget!"
fi 