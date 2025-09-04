#!/bin/bash

# 🛰️ OHW Mobile Parser - Termux One-Command Installer
# Run this in Termux: curl -sSL https://raw.githubusercontent.com/haryowl/ohwmobi/main/install-termux.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}"
    echo "========================================"
    echo "  OHW Mobile Parser - Termux Installer"
    echo "========================================"
    echo -e "${NC}"
}

print_header

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "This script must be run in Termux on Android"
    print_info "Please install Termux from F-Droid or Google Play Store"
    exit 1
fi

print_success "Termux environment detected"

# Update packages
print_info "Updating package list..."
pkg update -y

# Install required packages
print_info "Installing required packages..."
pkg install -y nodejs git sqlite wget curl

print_success "Dependencies installed"

# Create project directory
PROJECT_DIR="$HOME/ohwmobi"
print_info "Setting up project directory..."

if [ -d "$PROJECT_DIR" ]; then
    print_warning "Project directory already exists, updating..."
    cd "$PROJECT_DIR"
    git pull origin main || print_warning "Could not pull updates, continuing..."
else
    print_info "Cloning repository..."
    cd "$HOME"
    git clone https://github.com/haryowl/ohwmobi.git
    cd "$PROJECT_DIR"
fi

print_success "Repository ready"

# Install dependencies
print_info "Installing Node.js dependencies..."

# Install root dependencies
if [ -f "package.json" ]; then
    print_info "Installing root dependencies..."
    npm install --no-optional --ignore-scripts || npm install --no-optional --ignore-scripts --force
fi

# Install backend dependencies
if [ -d "backend" ]; then
    cd backend
    print_info "Installing backend dependencies..."
    npm install --no-optional --ignore-scripts || npm install --no-optional --ignore-scripts --force
    cd ..
fi

# Install frontend dependencies (optional)
if [ -d "frontend" ]; then
    cd frontend
    print_info "Installing frontend dependencies..."
    npm install --no-optional --ignore-scripts || npm install --no-optional --ignore-scripts --force
    cd ..
fi

print_success "Dependencies installed"

# Create data directories
print_info "Creating data directories..."
mkdir -p backend/data backend/logs backend/output

# Create mobile configuration
print_info "Creating mobile configuration..."
cd backend
cat > .env << 'EOF'
NODE_ENV=production
PORT=3001
TCP_PORT=3003
WS_PORT=3001
DATABASE_URL=sqlite://./data/mobile.sqlite
LOG_LEVEL=info
MAX_PACKET_SIZE=512
CORS_ORIGIN=*
PEER_SYNC_ENABLED=true
PEER_SYNC_PORT=3004
EOF
cd ..

print_success "Configuration created"

# Create management scripts
print_info "Creating management scripts..."

# Start script
cat > ~/ohw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Starting OHW Mobile Parser..."

# Find the project directory
if [ -d "$HOME/ohwmobi" ]; then
    cd "$HOME/ohwmobi"
else
    echo "❌ Project directory not found"
    echo "Please run the installation script first"
    exit 1
fi

# Check if already running
if [ -f "$HOME/ohw-server.pid" ]; then
    PID=$(cat "$HOME/ohw-server.pid")
    if kill -0 $PID 2>/dev/null; then
        echo "✅ Server is already running (PID: $PID)"
        exit 0
    fi
fi

# Try different backend files
if [ -f "termux-enhanced-backend.js" ]; then
    BACKEND_FILE="termux-enhanced-backend.js"
elif [ -f "backend/src/enhanced-backend.js" ]; then
    BACKEND_FILE="backend/src/enhanced-backend.js"
elif [ -f "backend/src/server.js" ]; then
    BACKEND_FILE="backend/src/server.js"
elif [ -f "termux-simple-backend.js" ]; then
    BACKEND_FILE="termux-simple-backend.js"
else
    echo "❌ No backend file found"
    echo "Available files:"
    find . -name "*.js" -type f | grep -E "(backend|server|termux)" | head -10
    exit 1
fi

echo "📁 Using backend: $BACKEND_FILE"

# Start the backend
echo "🚀 Starting server..."
nohup node "$BACKEND_FILE" > "$HOME/ohw-server.log" 2>&1 &
echo $! > "$HOME/ohw-server.pid"

echo "✅ Server started successfully!"
echo "📱 Access the interface at: http://localhost:3001"
echo "🎯 Unified Interface: http://localhost:3001/unified"
echo "📱 Mobile interface: http://localhost:3001/mobile"
echo "🔄 Peer sync: http://localhost:3001/peer-sync"
echo "📊 Data management: http://localhost:3001/data-management"
echo ""
echo "📋 To check status: ~/ohw-status.sh"
echo "🛑 To stop server: ~/ohw-stop.sh"
EOF

# Status script
cat > ~/ohw-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "📊 OHW Mobile Parser Status"
echo "=========================="

# Check if PID file exists
if [ -f "$HOME/ohw-server.pid" ]; then
    PID=$(cat "$HOME/ohw-server.pid")
    if kill -0 $PID 2>/dev/null; then
        echo "✅ Server is running (PID: $PID)"
        echo "📱 Web Interface: http://localhost:3001"
        echo "🎯 Unified Interface: http://localhost:3001/unified"
        echo "📱 Mobile Interface: http://localhost:3001/mobile"
        echo "🔄 Peer Sync: http://localhost:3001/peer-sync"
        echo "📊 Data Management: http://localhost:3001/data-management"
        
        # Get IP address
        IP=$(ip route get 1 | awk '{print $7; exit}')
        echo "🌐 Network Access: http://$IP:3001"
        
        # Check ports
        echo ""
        echo "🔌 Port Status:"
        netstat -tulpn | grep -E ":3001|:3003|:3004" || echo "No ports found"
    else
        echo "❌ Server is not running (stale PID file)"
        rm -f "$HOME/ohw-server.pid"
    fi
else
    echo "❌ Server is not running"
fi

echo ""
echo "📁 Project Directory: $HOME/ohwmobi"
echo "📄 Log File: $HOME/ohw-server.log"
EOF

# Stop script
cat > ~/ohw-stop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "🛑 Stopping OHW Mobile Parser..."

if [ -f "$HOME/ohw-server.pid" ]; then
    PID=$(cat "$HOME/ohw-server.pid")
    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo "✅ Server stopped (PID: $PID)"
    else
        echo "⚠️  Server was not running"
    fi
    rm -f "$HOME/ohw-server.pid"
else
    echo "⚠️  No PID file found"
fi

# Kill any remaining node processes
pkill -f "termux-enhanced-backend.js" || true
pkill -f "enhanced-backend.js" || true
pkill -f "server.js" || true

echo "✅ Cleanup complete"
EOF

# Restart script
cat > ~/ohw-restart.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "🔄 Restarting OHW Mobile Parser..."

~/ohw-stop.sh
sleep 2
~/ohw-start.sh
EOF

# Make scripts executable
chmod +x ~/ohw-*.sh

print_success "Management scripts created"

# Optional: Setup Termux widgets
echo ""
print_info "🎯 Optional: Setting up Termux widgets for easy management..."
read -p "Do you want to setup Termux widgets? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setting up Termux widgets..."
    if [ -f "setup-widgets-working.sh" ]; then
        chmod +x setup-widgets-working.sh
        ./setup-widgets-working.sh
        print_success "Termux widgets configured!"
        echo ""
        echo "📱 Widget Setup Complete!"
        echo "1. Install 'Termux:Widget' from Google Play Store"
        echo "2. Add widgets to your home screen"
        echo "3. Use widgets to manage your server"
        echo ""
    else
        print_warning "Widget setup script not found, skipping..."
    fi
else
    print_info "Skipping widget setup. You can run it later with:"
    echo "  chmod +x setup-widgets-working.sh"
    echo "  ./setup-widgets-working.sh"
fi

# Final instructions
echo ""
print_success "🎉 Installation Complete!"
echo ""
echo "📱 Quick Start Commands:"
echo "  Start server:    ~/ohw-start.sh"
echo "  Check status:    ~/ohw-status.sh"
echo "  Stop server:     ~/ohw-stop.sh"
echo "  Restart server:  ~/ohw-restart.sh"
echo ""
echo "🌐 Access URLs:"
echo "  Main Interface:  http://localhost:3001"
echo "  Mobile Interface: http://localhost:3001/mobile"
echo "  Peer Sync:       http://localhost:3001/peer-sync"
echo "  Data Management: http://localhost:3001/data-management"
echo ""
echo "📋 Next Steps:"
echo "1. Run: ~/ohw-start.sh"
echo "2. Open browser and go to: http://localhost:3001"
echo "3. Configure your Galileosky devices"
echo ""
print_info "Need help? Check the documentation in the project directory"
