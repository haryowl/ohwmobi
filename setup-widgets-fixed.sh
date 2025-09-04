#!/bin/bash

# Fixed Widget Setup for OHW Parser
# This provides widgets that work with or without termux-toast

echo "========================================"
echo "  Fixed Widget Setup for OHW Parser"
echo "========================================"

# Create shortcuts directory
mkdir -p ~/.shortcuts

# Check if termux-toast is available
if command -v termux-toast &> /dev/null; then
    echo "✅ termux-toast is available - using toast widgets"
    USE_TOAST=true
else
    echo "⚠️  termux-toast not found - using no-toast widgets"
    echo "   To install: pkg install termux-api"
    USE_TOAST=false
fi

# Create widgets based on availability
if [ "$USE_TOAST" = true ]; then
    # Toast widgets
    cat > ~/.shortcuts/ohw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-toast "Starting OHW Parser..."
cd ~/ohw-mobs 2>/dev/null || cd ~/ohwmobi 2>/dev/null || { termux-toast "Project not found!"; exit 1; }
if pgrep -f "node.*termux" > /dev/null; then
    termux-toast "Server already running!"
    exit 0
fi
if [ -f "termux-enhanced-backend.js" ]; then
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    termux-toast "Enhanced server started! localhost:3001"
elif [ -f "termux-simple-backend.js" ]; then
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    termux-toast "Simple server started! localhost:3001"
else
    termux-toast "No backend found!"
fi
EOF

    cat > ~/.shortcuts/ohw-stop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-toast "Stopping OHW Parser..."
pkill -f "node.*termux" 2>/dev/null
rm -f ~/ohw-server.pid
termux-toast "Server stopped!"
EOF

    cat > ~/.shortcuts/ohw-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if pgrep -f "node.*termux" > /dev/null; then
    termux-toast "Server is RUNNING - localhost:3001"
else
    termux-toast "Server is NOT running"
fi
EOF

else
    # No-toast widgets
    cat > ~/.shortcuts/ohw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🚀 Starting OHW Parser..."
cd ~/ohw-mobs 2>/dev/null || cd ~/ohwmobi 2>/dev/null || { echo "❌ Project not found!"; exit 1; }
if pgrep -f "node.*termux" > /dev/null; then
    echo "⚠️ Server already running!"
    exit 0
fi
if [ -f "termux-enhanced-backend.js" ]; then
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Enhanced server started! localhost:3001"
elif [ -f "termux-simple-backend.js" ]; then
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Simple server started! localhost:3001"
else
    echo "❌ No backend found!"
fi
EOF

    cat > ~/.shortcuts/ohw-stop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🛑 Stopping OHW Parser..."
pkill -f "node.*termux" 2>/dev/null
rm -f ~/ohw-server.pid
echo "✅ Server stopped!"
EOF

    cat > ~/.shortcuts/ohw-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if pgrep -f "node.*termux" > /dev/null; then
    echo "✅ Server is RUNNING - localhost:3001"
else
    echo "❌ Server is NOT running"
fi
EOF

fi

# Make widgets executable
chmod +x ~/.shortcuts/ohw-*.sh

echo "✅ Widgets created successfully!"
echo ""
echo "📱 Widgets created:"
echo "  • ohw-start.sh - Start server"
echo "  • ohw-stop.sh - Stop server"
echo "  • ohw-status.sh - Check status"
echo ""
if [ "$USE_TOAST" = false ]; then
    echo "💡 To get toast notifications:"
    echo "   pkg install termux-api"
    echo "   Then re-run this setup script"
    echo ""
fi
echo "🔧 Next steps:"
echo "1. Install 'Termux:Widget' from Google Play Store"
echo "2. Add widgets to home screen"
echo "3. Select the ohw-*.sh scripts"
echo ""
echo "📖 Widgets will show output in Termux terminal"
