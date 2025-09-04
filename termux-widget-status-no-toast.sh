#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Status Widget - No Toast Version
# This widget works without termux-toast

# Check if running
if pgrep -f "node.*termux" > /dev/null; then
    echo "✅ Server is RUNNING"
    echo "🌐 Access: localhost:3001"
    echo "📱 Simple Interface: localhost:3001/simple-unified-interface.html"
else
    echo "❌ Server is NOT running"
fi
