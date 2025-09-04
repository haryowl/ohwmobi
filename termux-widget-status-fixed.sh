#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Server Status Widget Script - Fixed Version
# Place this file in ~/.shortcuts/ directory in Termux

# Auto-detect project directory
if [ -d "/data/data/com.termux/files/home/ohw-mobs" ]; then
    PROJECT_DIR="/data/data/com.termux/files/home/ohw-mobs"
elif [ -d "/data/data/com.termux/files/home/ohwmobi" ]; then
    PROJECT_DIR="/data/data/com.termux/files/home/ohwmobi"
elif [ -d "$HOME/ohw-mobs" ]; then
    PROJECT_DIR="$HOME/ohw-mobs"
elif [ -d "$HOME/ohwmobi" ]; then
    PROJECT_DIR="$HOME/ohwmobi"
else
    echo "❌ Project directory not found!"
    echo "Please ensure the project is in one of these locations:"
    echo "  /data/data/com.termux/files/home/ohw-mobs"
    echo "  /data/data/com.termux/files/home/ohwmobi"
    echo "  $HOME/ohw-mobs"
    echo "  $HOME/ohwmobi"
    exit 1
fi

echo "=== OHW Parser Server Status ==="
echo "📁 Project: $PROJECT_DIR"

# Change to project directory
cd "$PROJECT_DIR" || {
    echo "❌ Cannot access project directory: $PROJECT_DIR"
    exit 1
}

# Check if server is running
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null || pgrep -f "node.*server.js" > /dev/null; then
    echo "✅ Server is RUNNING"
    echo ""
    
    # Show PID if available
    if [ -f ~/ohw-server.pid ]; then
        PID=$(cat ~/ohw-server.pid)
        echo "📊 Process ID: $PID"
    fi
    
    echo ""
    echo "🔍 Running processes:"
    ps aux | grep -E "(termux-enhanced|termux-simple|server\.js)" | grep -v grep || echo "No matching processes found"
    
    echo ""
    echo "🔌 Ports in use:"
    netstat -tlnp 2>/dev/null | grep -E ":3001|:3003" || echo "No ports found"
    
    echo ""
    echo "🌐 Access URLs:"
    echo "   Main Interface: http://localhost:3001"
    echo "   Simple Interface: http://localhost:3001/simple-unified-interface.html"
    echo "   API Endpoint: http://localhost:3001/api"
    echo "   TCP Server: localhost:3003"
    
    # Get network IP
    LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "Not available")
    if [ "$LOCAL_IP" != "Not available" ]; then
        echo ""
        echo "🌍 Network Access:"
        echo "   Main: http://$LOCAL_IP:3001"
        echo "   Simple: http://$LOCAL_IP:3001/simple-unified-interface.html"
    fi
    
    # Check if interface files exist
    echo ""
    echo "📱 Interface Files:"
    if [ -f "simple-unified-interface.html" ]; then
        echo "   ✅ simple-unified-interface.html"
    else
        echo "   ❌ simple-unified-interface.html (not found)"
    fi
    
    if [ -f "simple-frontend.html" ]; then
        echo "   ✅ simple-frontend.html"
    else
        echo "   ❌ simple-frontend.html (not found)"
    fi
    
else
    echo "❌ Server is NOT RUNNING"
    echo ""
    echo "📋 Available backend files:"
    if [ -f "termux-enhanced-backend.js" ]; then
        echo "   ✅ termux-enhanced-backend.js"
    else
        echo "   ❌ termux-enhanced-backend.js (not found)"
    fi
    
    if [ -f "termux-simple-backend.js" ]; then
        echo "   ✅ termux-simple-backend.js"
    else
        echo "   ❌ termux-simple-backend.js (not found)"
    fi
    
    if [ -f "backend/src/server.js" ]; then
        echo "   ✅ backend/src/server.js"
    else
        echo "   ❌ backend/src/server.js (not found)"
    fi
    
    echo ""
    echo "🚀 To start server:"
    echo "   Use the 'Start Server' widget"
    echo "   Or run: cd $PROJECT_DIR && node termux-enhanced-backend.js"
fi
