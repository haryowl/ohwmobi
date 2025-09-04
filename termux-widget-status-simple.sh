#!/data/data/com.termux/files/usr/bin/bash

# Simple OHW Parser Status Widget
# This widget should work reliably in Termux

# Check if running
if pgrep -f "node.*termux" > /dev/null; then
    termux-toast "Server is RUNNING - Access: localhost:3001"
else
    termux-toast "Server is NOT running"
fi
