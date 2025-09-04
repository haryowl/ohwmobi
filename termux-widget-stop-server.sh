#!/data/data/com.termux/files/usr/bin/bash

# Galileosky Server Stop Widget Script
# Place this file in ~/.shortcuts/ directory in Termux

# Set the project directory
PROJECT_DIR="/data/data/com.termux/files/home/ohw-mobs"

# Change to project directory
cd "$PROJECT_DIR"

# Stop the server
echo "Stopping OHW Parser Server..."

# Kill Node.js processes
pkill -f "node.*termux-enhanced-backend.js" 2>/dev/null
pkill -f "node.*termux-simple-backend.js" 2>/dev/null
pkill -f "node.*server.js" 2>/dev/null

# Stop PM2 processes if using PM2
if command -v pm2 &> /dev/null; then
    pm2 stop all 2>/dev/null
    pm2 delete all 2>/dev/null
fi

# Remove PID file
rm -f ~/ohw-server.pid

echo "✅ Server stopped!" 