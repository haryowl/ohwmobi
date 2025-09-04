#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Stop Widget - No Toast Version
# This widget works without termux-toast

# Kill processes
pkill -f "node.*termux" 2>/dev/null
pkill -f "node.*server" 2>/dev/null

# Remove PID file
rm -f ~/ohw-server.pid

# Check if stopped
sleep 2
if ! pgrep -f "node.*termux" > /dev/null; then
    echo "✅ Server stopped!"
else
    echo "⚠️ Some processes may still be running"
fi
