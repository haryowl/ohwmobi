#!/data/data/com.termux/files/usr/bin/bash

# Simple OHW Parser Stop Widget
# This widget should work reliably in Termux

# Show notification
termux-toast "Stopping OHW Parser Server..."

# Kill processes
pkill -f "node.*termux" 2>/dev/null
pkill -f "node.*server" 2>/dev/null

# Remove PID file
rm -f ~/ohw-server.pid

# Check if stopped
sleep 2
if ! pgrep -f "node.*termux" > /dev/null; then
    termux-toast "Server stopped!"
else
    termux-toast "Some processes may still be running"
fi
