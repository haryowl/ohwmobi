#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Server Stop Widget Script - Fixed Version
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

echo "🛑 Stopping OHW Parser Server..."
echo "📁 Project: $PROJECT_DIR"

# Change to project directory
cd "$PROJECT_DIR" || {
    echo "❌ Cannot access project directory: $PROJECT_DIR"
    exit 1
}

# Check if server is running first
if ! pgrep -f "node.*termux-enhanced-backend.js" > /dev/null && ! pgrep -f "node.*termux-simple-backend.js" > /dev/null && ! pgrep -f "node.*server.js" > /dev/null; then
    echo "⚠️  Server is not running"
    rm -f ~/ohw-server.pid
    exit 0
fi

# Kill Node.js processes
echo "🔍 Stopping Node.js processes..."

# Kill by PID if available
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "🛑 Stopping process $PID..."
        kill $PID
        sleep 2
        if kill -0 $PID 2>/dev/null; then
            echo "⚠️  Process still running, force killing..."
            kill -9 $PID 2>/dev/null
        fi
    fi
    rm -f ~/ohw-server.pid
fi

# Kill by process name
pkill -f "node.*termux-enhanced-backend.js" 2>/dev/null && echo "✅ Stopped enhanced backend"
pkill -f "node.*termux-simple-backend.js" 2>/dev/null && echo "✅ Stopped simple backend"
pkill -f "node.*server.js" 2>/dev/null && echo "✅ Stopped server.js"
pkill -f "backend/src/server.js" 2>/dev/null && echo "✅ Stopped backend server"

# Stop PM2 processes if using PM2
if command -v pm2 &> /dev/null; then
    echo "🛑 Stopping PM2 processes..."
    pm2 stop all 2>/dev/null && echo "✅ PM2 processes stopped"
    pm2 delete all 2>/dev/null && echo "✅ PM2 processes deleted"
fi

# Wait a moment for processes to stop
sleep 2

# Verify all processes are stopped
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null || pgrep -f "node.*server.js" > /dev/null; then
    echo "⚠️  Some processes may still be running"
    echo "🔍 Remaining processes:"
    ps aux | grep -E "(termux-enhanced|termux-simple|server\.js)" | grep -v grep
else
    echo "✅ All server processes stopped"
fi

# Clean up
rm -f ~/ohw-server.pid

echo "✅ Server stop complete!"



