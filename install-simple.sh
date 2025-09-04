#!/bin/bash

# Simple OHW Parser Installation for Termux
# This should work seamlessly like before

set -e

echo "========================================"
echo "  OHW Parser - Simple Installation"
echo "========================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "❌ This script must be run in Termux!"
    exit 1
fi

print_status "Termux environment detected"

# Update packages
print_info "Updating packages..."
pkg update -y
print_status "Packages updated"

# Install required packages
print_info "Installing required packages..."
pkg install -y nodejs git wget curl
print_status "Required packages installed"

# Verify Node.js
print_info "Verifying Node.js..."
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Clone or update project
print_info "Setting up project..."
if [ -d "ohw-mobs" ]; then
    cd ohw-mobs
    git pull origin main
    print_status "Project updated"
else
    git clone https://github.com/haryowl/ohwmobi.git ohw-mobs
    cd ohw-mobs
    print_status "Project cloned"
fi

# Install dependencies
print_info "Installing dependencies..."
npm install --no-optional
print_status "Dependencies installed"

# Create simple startup script
print_info "Creating startup script..."
cat > ~/ohw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/ohw-mobs
echo "🚀 Starting OHW Parser Server..."
if [ -f "termux-enhanced-backend.js" ]; then
    node termux-enhanced-backend.js
elif [ -f "termux-simple-backend.js" ]; then
    node termux-simple-backend.js
else
    echo "❌ No backend found!"
    exit 1
fi
EOF

chmod +x ~/ohw-start.sh
print_status "Startup script created"

# Create simple widgets
print_info "Creating simple widgets..."
mkdir -p ~/.shortcuts

# Start widget
cat > ~/.shortcuts/ohw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-toast "Starting OHW Parser..."
cd ~/ohw-mobs
if [ -f "termux-enhanced-backend.js" ]; then
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    termux-toast "Server started! Access: localhost:3001"
elif [ -f "termux-simple-backend.js" ]; then
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    termux-toast "Server started! Access: localhost:3001"
else
    termux-toast "No backend found!"
fi
EOF

# Stop widget
cat > ~/.shortcuts/ohw-stop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-toast "Stopping OHW Parser..."
pkill -f "node.*termux" 2>/dev/null
rm -f ~/ohw-server.pid
termux-toast "Server stopped!"
EOF

# Status widget
cat > ~/.shortcuts/ohw-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if pgrep -f "node.*termux" > /dev/null; then
    termux-toast "Server is RUNNING - localhost:3001"
else
    termux-toast "Server is NOT running"
fi
EOF

# Make widgets executable
chmod +x ~/.shortcuts/ohw-*.sh
print_status "Widgets created"

# Final instructions
echo ""
echo "========================================"
echo "  🎉 Installation Complete!"
echo "========================================"
echo ""
print_status "OHW Parser installed successfully!"
echo ""
echo "🚀 Quick Start:"
echo "  ~/ohw-start.sh          # Start server"
echo ""
echo "📱 Widgets:"
echo "  • ohw-start.sh - Start server"
echo "  • ohw-stop.sh - Stop server"
echo "  • ohw-status.sh - Check status"
echo ""
echo "🌐 Access:"
echo "  http://localhost:3001"
echo "  http://localhost:3001/simple-unified-interface.html"
echo ""
echo "📋 Next Steps:"
echo "1. Install 'Termux:Widget' from Google Play Store"
echo "2. Add widgets to home screen"
echo "3. Start server: ~/ohw-start.sh"
echo ""
print_info "Installation completed successfully!"
