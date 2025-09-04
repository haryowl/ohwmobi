#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Status Widget - Fixed Version
# This widget actually executes the status command

# Set proper environment
export PATH="/data/data/com.termux/files/usr/bin:$PATH"
cd /data/data/com.termux/files/home

# Find project directory
PROJECT_DIR=""
if [ -d "ohw-mobs" ]; then
    PROJECT_DIR="ohw-mobs"
elif [ -d "ohwmobi" ]; then
    PROJECT_DIR="ohwmobi"
else
    echo "❌ Project directory not found!"
    exit 1
fi

cd "$PROJECT_DIR"

# Check if server is running
if pgrep -f "node.*termux" > /dev/null; then
    echo "✅ Server is RUNNING"
    
    # Get process info
    PID=$(pgrep -f "node.*termux")
    echo "📊 Process ID: $PID"
    
    # Check ports
    if netstat -tlnp 2>/dev/null | grep -q ":3001"; then
        echo "🌐 Port 3001: ACTIVE"
    else
        echo "⚠️ Port 3001: NOT LISTENING"
    fi
    
    # Get network info
    if command -v ip >/dev/null 2>&1; then
        LOCAL_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -1)
        if [ -n "$LOCAL_IP" ]; then
            echo "🌐 Local IP: $LOCAL_IP"
            echo "📱 Access URLs:"
            echo "   - http://localhost:3001"
            echo "   - http://$LOCAL_IP:3001"
            echo "   - http://$LOCAL_IP:3001/simple-unified-interface.html"
        fi
    fi
    
    # Check interface files
    if [ -f "simple-unified-interface.html" ]; then
        echo "📱 Simple Interface: Available"
    fi
    
else
    echo "❌ Server is NOT RUNNING"
    echo "💡 Use 'Start Server' widget to start"
fi