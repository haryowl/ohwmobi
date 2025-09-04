#!/data/data/com.termux/files/usr/bin/bash

# Galileosky Server Start Widget Script
# Place this file in ~/.shortcuts/ directory in Termux

# Set the project directory
PROJECT_DIR="/data/data/com.termux/files/home/ohw-mobs"

# Change to project directory
cd "$PROJECT_DIR"

# Check if backend is already running
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    echo "Server is already running!"
    exit 0
fi

# Start the server
echo "Starting OHW Parser Server..."
echo "Project: $PROJECT_DIR"

# Try to start the enhanced backend first, fallback to simple
if [ -f "termux-enhanced-backend.js" ]; then
    echo "Starting enhanced backend..."
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Server started successfully (PID: $!)"
    echo "Access: http://localhost:3001"
elif [ -f "termux-simple-backend.js" ]; then
    echo "Starting simple backend..."
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Server started successfully (PID: $!)"
    echo "Access: http://localhost:3001"
else
    echo "❌ No backend found!"
    exit 1
fi

# Alternative commands you can uncomment:
# node backend/src/server.js
# npm start
# pm2 start ecosystem.config.js 