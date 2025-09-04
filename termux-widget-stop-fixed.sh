#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Stop Widget - Fixed Version
# This widget actually executes the stop command

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

# Stop server using PID file
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo "✅ Server stopped (PID: $PID)"
    else
        echo "⚠️ Server was not running"
    fi
    rm -f ~/ohw-server.pid
else
    echo "⚠️ No PID file found"
fi

# Kill any remaining Node.js processes
pkill -f "node.*termux" 2>/dev/null || true
pkill -f "node.*enhanced" 2>/dev/null || true
pkill -f "node.*simple" 2>/dev/null || true

# Stop PM2 if running
if command -v pm2 >/dev/null 2>&1; then
    pm2 stop all 2>/dev/null || true
    pm2 delete all 2>/dev/null || true
fi

echo "✅ All OHW processes stopped"
