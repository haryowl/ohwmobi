#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Start Widget - Fixed Version
# This widget actually executes the start command

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

# Check if already running
if pgrep -f "node.*termux" > /dev/null; then
    echo "⚠️ Server already running!"
    exit 0
fi

# Start server
if [ -f "termux-enhanced-backend.js" ]; then
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Enhanced server started!"
elif [ -f "termux-simple-backend.js" ]; then
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Simple server started!"
elif [ -f "backend/src/server.js" ]; then
    nohup node backend/src/server.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Backend server started!"
else
    echo "❌ No backend found!"
    exit 1
fi

# Wait and check
sleep 3
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "✅ Server running! Access: localhost:3001"
        echo "📱 Simple Interface: localhost:3001/simple-unified-interface.html"
    else
        echo "❌ Server failed to start"
    fi
fi
