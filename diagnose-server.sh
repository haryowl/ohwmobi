#!/bin/bash

# Server Diagnostic Script
# This helps identify server startup issues

echo "========================================"
echo "  OHW Parser Server Diagnostic"
echo "========================================"

# Check Node.js
echo "1. Checking Node.js..."
if command -v node &> /dev/null; then
    echo "✅ Node.js version: $(node --version)"
else
    echo "❌ Node.js not found!"
    exit 1
fi

# Check project directory
echo ""
echo "2. Checking project directory..."
if [ -d "/data/data/com.termux/files/home/ohw-mobs" ]; then
    PROJECT_DIR="/data/data/com.termux/files/home/ohw-mobs"
    echo "✅ Project found: $PROJECT_DIR"
elif [ -d "/data/data/com.termux/files/home/ohwmobi" ]; then
    PROJECT_DIR="/data/data/com.termux/files/home/ohwmobi"
    echo "✅ Project found: $PROJECT_DIR"
else
    echo "❌ Project directory not found!"
    echo "Please ensure the project is installed"
    exit 1
fi

cd "$PROJECT_DIR"

# Check backend files
echo ""
echo "3. Checking backend files..."
if [ -f "termux-enhanced-backend.js" ]; then
    echo "✅ termux-enhanced-backend.js found"
    BACKEND_FILE="termux-enhanced-backend.js"
elif [ -f "termux-simple-backend.js" ]; then
    echo "✅ termux-simple-backend.js found"
    BACKEND_FILE="termux-simple-backend.js"
elif [ -f "backend/src/server.js" ]; then
    echo "✅ backend/src/server.js found"
    BACKEND_FILE="backend/src/server.js"
else
    echo "❌ No backend files found!"
    exit 1
fi

# Check if server is already running
echo ""
echo "4. Checking if server is already running..."
if pgrep -f "node.*termux" > /dev/null; then
    echo "⚠️  Server is already running!"
    echo "Processes:"
    ps aux | grep -E "(termux|server)" | grep -v grep
    echo ""
    echo "Ports in use:"
    netstat -tlnp 2>/dev/null | grep -E ":3001|:3003" || echo "No ports found"
    exit 0
fi

# Test server startup
echo ""
echo "5. Testing server startup..."
echo "Starting server with: node $BACKEND_FILE"

# Start server in background
nohup node "$BACKEND_FILE" > ~/ohw-server.log 2>&1 &
SERVER_PID=$!
echo "Server PID: $SERVER_PID"

# Wait for server to start
echo "Waiting for server to start..."
sleep 5

# Check if server is running
if kill -0 $SERVER_PID 2>/dev/null; then
    echo "✅ Server is running (PID: $SERVER_PID)"
    
    # Check ports
    echo ""
    echo "6. Checking ports..."
    netstat -tlnp 2>/dev/null | grep -E ":3001|:3003" || echo "No ports found"
    
    # Test localhost access
    echo ""
    echo "7. Testing localhost access..."
    if command -v curl &> /dev/null; then
        if curl -s http://localhost:3001 > /dev/null; then
            echo "✅ localhost:3001 is accessible"
        else
            echo "❌ localhost:3001 is not accessible"
        fi
    else
        echo "⚠️  curl not available, cannot test localhost access"
    fi
    
    # Show server log
    echo ""
    echo "8. Server log (last 10 lines):"
    tail -10 ~/ohw-server.log
    
    # Stop server
    echo ""
    echo "9. Stopping test server..."
    kill $SERVER_PID
    sleep 2
    
    if kill -0 $SERVER_PID 2>/dev/null; then
        echo "⚠️  Server still running, force killing..."
        kill -9 $SERVER_PID
    fi
    echo "✅ Test server stopped"
    
else
    echo "❌ Server failed to start"
    echo ""
    echo "Server log:"
    cat ~/ohw-server.log
fi

echo ""
echo "========================================"
echo "  Diagnostic Complete"
echo "========================================"
