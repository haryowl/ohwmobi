#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Stop Widget - Persistent Version
# This widget keeps Termux open to show the output

# Set proper environment
export PATH="/data/data/com.termux/files/usr/bin:$PATH"
cd /data/data/com.termux/files/home

echo "🛑 OHW Parser - Stopping Server..."
echo "=================================="

# Find project directory
PROJECT_DIR=""
if [ -d "ohw-mobs" ]; then
    PROJECT_DIR="ohw-mobs"
elif [ -d "ohwmobi" ]; then
    PROJECT_DIR="ohwmobi"
else
    echo "❌ Project directory not found!"
    echo "Please make sure the project is installed."
    echo ""
    echo "Press Enter to close..."
    read
    exit 1
fi

cd "$PROJECT_DIR"
echo "📁 Project directory: $PROJECT_DIR"

# Stop server using PID file
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "🔄 Stopping server (PID: $PID)..."
        kill $PID
        sleep 2
        if kill -0 $PID 2>/dev/null; then
            echo "⚠️ Server still running, force killing..."
            kill -9 $PID
        fi
        echo "✅ Server stopped (PID: $PID)"
    else
        echo "⚠️ Server was not running (PID: $PID)"
    fi
    rm -f ~/ohw-server.pid
else
    echo "⚠️ No PID file found"
fi

# Kill any remaining Node.js processes
echo "🔄 Checking for remaining processes..."
REMAINING=$(pgrep -f "node.*termux" | wc -l)
if [ "$REMAINING" -gt 0 ]; then
    echo "🔄 Killing $REMAINING remaining Node.js processes..."
    pkill -f "node.*termux" 2>/dev/null || true
    pkill -f "node.*enhanced" 2>/dev/null || true
    pkill -f "node.*simple" 2>/dev/null || true
    sleep 1
fi

# Stop PM2 if running
if command -v pm2 >/dev/null 2>&1; then
    echo "🔄 Stopping PM2 processes..."
    pm2 stop all 2>/dev/null || true
    pm2 delete all 2>/dev/null || true
fi

# Final check
REMAINING=$(pgrep -f "node.*termux" | wc -l)
if [ "$REMAINING" -eq 0 ]; then
    echo "✅ All OHW processes stopped successfully!"
else
    echo "⚠️ $REMAINING processes still running"
    echo "Process IDs: $(pgrep -f "node.*termux")"
fi

echo ""
echo "Press Enter to close..."
read
