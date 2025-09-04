#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Server Start Widget Script - Fixed Version
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

echo "📁 Project directory: $PROJECT_DIR"

# Change to project directory
cd "$PROJECT_DIR" || {
    echo "❌ Cannot access project directory: $PROJECT_DIR"
    exit 1
}

# Check if backend is already running
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null || pgrep -f "node.*server.js" > /dev/null; then
    echo "⚠️  Server is already running!"
    echo "Use 'Stop Server' widget first, or 'Restart Server' widget"
    exit 0
fi

# Start the server
echo "🚀 Starting OHW Parser Server..."
echo "📁 Project: $PROJECT_DIR"

# Try to start the enhanced backend first, fallback to simple, then backend
if [ -f "termux-enhanced-backend.js" ]; then
    echo "📱 Starting enhanced backend..."
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Enhanced backend started successfully (PID: $!)"
elif [ -f "termux-simple-backend.js" ]; then
    echo "📱 Starting simple backend..."
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Simple backend started successfully (PID: $!)"
elif [ -f "backend/src/server.js" ]; then
    echo "📱 Starting backend server..."
    nohup node backend/src/server.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Backend server started successfully (PID: $!)"
else
    echo "❌ No backend found!"
    echo ""
    echo "Available files:"
    ls -la termux-*.js 2>/dev/null || echo "No termux-*.js files found"
    ls -la backend/src/server.js 2>/dev/null || echo "No backend/src/server.js found"
    echo ""
    echo "Please ensure you have one of these files:"
    echo "  - termux-enhanced-backend.js"
    echo "  - termux-simple-backend.js"
    echo "  - backend/src/server.js"
    exit 1
fi

# Wait a moment for server to start
sleep 2

# Verify server started
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo ""
        echo "🌐 Access URLs:"
        echo "   Main: http://localhost:3001"
        echo "   Simple Interface: http://localhost:3001/simple-unified-interface.html"
        
        # Get network IP
        LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "Not available")
        if [ "$LOCAL_IP" != "Not available" ]; then
            echo "   Network: http://$LOCAL_IP:3001"
            echo "   Network Simple: http://$LOCAL_IP:3001/simple-unified-interface.html"
        fi
    else
        echo "❌ Server failed to start (stale PID file)"
        rm -f ~/ohw-server.pid
    fi
else
    echo "❌ Server failed to start (no PID file)"
fi
