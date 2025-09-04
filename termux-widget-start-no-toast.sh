#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Start Widget - No Toast Version
# This widget works without termux-toast

# Find project directory
if [ -d "/data/data/com.termux/files/home/ohw-mobs" ]; then
    cd /data/data/com.termux/files/home/ohw-mobs
elif [ -d "/data/data/com.termux/files/home/ohwmobi" ]; then
    cd /data/data/com.termux/files/home/ohwmobi
else
    echo "❌ Project directory not found!"
    exit 1
fi

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
