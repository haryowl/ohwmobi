#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Start Widget - Persistent Version
# This widget keeps Termux open to show the output

# Set proper environment
export PATH="/data/data/com.termux/files/usr/bin:$PATH"
cd /data/data/com.termux/files/home

echo "🚀 OHW Parser - Starting Server..."
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

# Check if already running
if pgrep -f "node.*termux" > /dev/null; then
    echo "⚠️ Server already running!"
    echo "Process ID: $(pgrep -f "node.*termux")"
    echo ""
    echo "Press Enter to close..."
    read
    exit 0
fi

# Start server
echo "🔄 Starting server..."
if [ -f "termux-enhanced-backend.js" ]; then
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Enhanced server started!"
elif [ -f "termux-simple-backend.js" ]; then
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Simple server started!"
elif [ -f "backend/src/server.js" ]; then
    nohup node backend/src/server.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Backend server started!"
else
    echo "❌ No backend found!"
    echo "Available files:"
    ls -la *.js 2>/dev/null || echo "No .js files found"
    echo ""
    echo "Press Enter to close..."
    read
    exit 1
fi

# Wait and check
echo "⏳ Waiting for server to start..."
sleep 3

if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "✅ Server running successfully!"
        echo "📊 Process ID: $PID"
        echo "🌐 Access URLs:"
        echo "   - http://localhost:3001"
        echo "   - http://localhost:3001/simple-unified-interface.html"
        
        # Get network IP
        if command -v ip >/dev/null 2>&1; then
            LOCAL_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -1)
            if [ -n "$LOCAL_IP" ]; then
                echo "   - http://$LOCAL_IP:3001"
                echo "   - http://$LOCAL_IP:3001/simple-unified-interface.html"
            fi
        fi
        
        echo ""
        echo "🎉 Server is ready to use!"
    else
        echo "❌ Server failed to start"
        echo "📋 Check logs: tail -f ~/ohw-server.log"
    fi
else
    echo "❌ No PID file created"
fi

echo ""
echo "Press Enter to close..."
read
