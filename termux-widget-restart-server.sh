#!/data/data/com.termux/files/usr/bin/bash

# Galileosky Server Restart Widget Script
# Place this file in ~/.shortcuts/ directory in Termux

# Set the project directory
PROJECT_DIR="/data/data/com.termux/files/home/ohw-mobs"

# Change to project directory
cd "$PROJECT_DIR"

echo "=== Restarting Galileosky Server ==="

# Stop existing server processes
echo "Stopping existing server..."
pkill -f "node.*server.js" 2>/dev/null
pkill -f "node.*termux-enhanced-backend.js" 2>/dev/null
pkill -f "node.*termux-simple-backend.js" 2>/dev/null

# Stop PM2 processes if using PM2
if command -v pm2 &> /dev/null; then
    pm2 stop all 2>/dev/null
    pm2 delete all 2>/dev/null
fi

# Wait a moment for processes to stop
sleep 2

# Start the server
echo "Starting server..."
echo "Project: $PROJECT_DIR"

# Try to start the enhanced backend first, fallback to simple
if [ -f "termux-enhanced-backend.js" ]; then
    echo "Starting enhanced backend..."
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
elif [ -f "termux-simple-backend.js" ]; then
    echo "Starting simple backend..."
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
else
    echo "No backend found!"
    exit 1
fi

# Wait a moment for server to start
sleep 3

# Check if server started successfully
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "✅ Server restarted successfully (PID: $PID)"
        echo "Access: http://localhost:3001"
    else
        echo "❌ Server failed to start"
        rm -f ~/ohw-server.pid
    fi
else
    echo "❌ Server failed to start"
fi
