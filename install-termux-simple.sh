#!/bin/bash

# 🚀 OHW Mobile Parser - Simple Termux Installation with Widgets
# Focuses on Simple Unified Interface Access
# Run this in Termux: curl -sSL https://raw.githubusercontent.com/haryowl/ohwmobi/main/install-termux-simple.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

print_header() {
    echo -e "${BLUE}"
    echo "========================================"
    echo "  OHW Mobile Parser - Simple Setup"
    echo "  With Termux Widgets"
    echo "========================================"
    echo -e "${NC}"
}

print_header

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "This script must be run in Termux!"
    print_info "Please install Termux first:"
    print_info "1. Download from F-Droid: https://f-droid.org/"
    print_info "2. Or from Google Play Store"
    exit 1
fi

print_info "Running in Termux environment ✅"

# Step 1: Update packages
echo ""
print_step "Step 1: Updating package list..."
pkg update -y
print_status "Package list updated"

# Step 2: Install required packages
echo ""
print_step "Step 2: Installing required packages..."
pkg install -y nodejs git wget curl
print_status "Required packages installed"

# Step 3: Verify installations
echo ""
print_step "Step 3: Verifying installations..."
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Git version: $(git --version)"
print_status "All packages verified"

# Step 4: Clone or update repository
echo ""
print_step "Step 4: Setting up project..."
if [ -d "ohw-mobs" ]; then
    print_warning "Project directory exists, updating..."
    cd ohw-mobs
    git pull origin main
    print_status "Project updated"
else
    print_info "Cloning project repository..."
    git clone https://github.com/haryowl/ohwmobi.git ohw-mobs
    cd ohw-mobs
    print_status "Project cloned"
fi

# Step 5: Install dependencies
echo ""
print_step "Step 5: Installing project dependencies..."
npm install --no-optional
print_status "Dependencies installed"

# Step 6: Setup Termux widgets
echo ""
print_step "Step 6: Setting up Termux widgets..."
chmod +x setup-termux-widgets.sh
./setup-termux-widgets.sh
print_status "Termux widgets configured"

# Step 7: Create simplified startup scripts
echo ""
print_step "Step 7: Creating startup scripts..."

# Create main startup script
cat > ~/ohw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/ohw-mobs
echo "🚀 Starting OHW Parser Server..."
echo "📱 Simple Unified Interface will be available at:"
echo "   http://localhost:3001/simple-unified-interface.html"
echo ""
if [ -f "termux-enhanced-backend.js" ]; then
    echo "Starting enhanced backend..."
    node termux-enhanced-backend.js
elif [ -f "termux-simple-backend.js" ]; then
    echo "Starting simple backend..."
    node termux-simple-backend.js
else
    echo "❌ No backend found!"
    exit 1
fi
EOF

# Create status script
cat > ~/ohw-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/ohw-mobs
echo "=== OHW Parser Status ==="
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    echo "✅ Server is running"
    echo ""
    echo "📱 Access Your Simple Unified Interface:"
    echo "   http://localhost:3001/simple-unified-interface.html"
    echo ""
    # Get network IP
    LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "Not available")
    if [ "$LOCAL_IP" != "Not available" ]; then
        echo "🌍 Network Access:"
        echo "   http://$LOCAL_IP:3001/simple-unified-interface.html"
    fi
else
    echo "❌ Server is not running"
    echo "Start with: ~/ohw-start.sh"
fi
EOF

# Create stop script
cat > ~/ohw-stop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🛑 Stopping OHW Parser Server..."
pkill -f "node.*termux-enhanced-backend.js" 2>/dev/null
pkill -f "node.*termux-simple-backend.js" 2>/dev/null
rm -f ~/ohw-server.pid
echo "✅ Server stopped"
EOF

# Make scripts executable
chmod +x ~/ohw-*.sh
print_status "Startup scripts created"

# Step 8: Create simplified widget for interface access
echo ""
print_step "Step 8: Creating simplified interface widget..."

# Create a simplified interface widget
cat > ~/.shortcuts/ohw-open-simple-interface.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Open OHW Parser Simple Unified Interface Widget
echo "🌐 Opening OHW Parser Simple Unified Interface..."

# Check if server is running
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    # Get local IP address
    LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "localhost")
    
    # Show interface URLs
    echo "📱 Simple Unified Interface:"
    echo "Local: http://localhost:3001/simple-unified-interface.html"
    echo "Network: http://$LOCAL_IP:3001/simple-unified-interface.html"
    
    # Try to open in browser (if termux-open-url is available)
    if command -v termux-open-url &> /dev/null; then
        termux-open-url "http://localhost:3001/simple-unified-interface.html"
    else
        echo "Install termux-api for browser opening: pkg install termux-api"
    fi
else
    echo "❌ Server is not running!"
    echo "Start the server first using the 'Start Server' widget"
fi
EOF

# Make the simplified widget executable
chmod +x ~/.shortcuts/ohw-open-simple-interface.sh
print_status "Simplified interface widget created"

# Step 9: Create installation summary
echo ""
print_step "Step 9: Creating installation summary..."

cat > ~/OHW-SIMPLE-INSTALLATION-SUMMARY.md << 'EOF'
# 🎉 OHW Mobile Parser - Simple Installation Complete!

## 📱 What's Installed

### Core Application
- ✅ OHW Mobile Parser server
- ✅ Enhanced backend (full features)
- ✅ Simple backend (lightweight)
- ✅ **Simple Unified Interface** (main access point)

### Termux Widgets
- ✅ Start Server widget
- ✅ Stop Server widget
- ✅ Restart Server widget
- ✅ Status Check widget
- ✅ **Open Simple Interface** widget (main access)
- ✅ View Logs widget
- ✅ Network Info widget

## 🚀 Quick Start

### Method 1: Use Widgets (Recommended)
1. Install **Termux:Widget** from Google Play Store
2. Add widgets to your home screen
3. Tap "Start Server" widget to begin
4. Tap "Open Simple Interface" widget to access the interface

### Method 2: Use Commands
```bash
# Start server
~/ohw-start.sh

# Check status
~/ohw-status.sh

# Stop server
~/ohw-stop.sh
```

## 🌐 Access Your Simple Unified Interface

### Main Access Point
- **Simple Unified Interface**: http://localhost:3001/simple-unified-interface.html

### Network Access
- **Network Access**: http://[YOUR_IP]:3001/simple-unified-interface.html

## 📱 Widget Setup Instructions

1. **Install Termux:Widget**:
   - Open Google Play Store
   - Search "Termux:Widget"
   - Install the app

2. **Add Widgets to Home Screen**:
   - Long press on home screen
   - Select "Widgets"
   - Find "Termux:Widget"
   - Drag to home screen
   - Select widget script

3. **Key Widgets**:
   - `ohw-start-server.sh` - Start server
   - `ohw-open-simple-interface.sh` - **Open Simple Interface**
   - `ohw-status.sh` - Check status
   - `ohw-stop-server.sh` - Stop server

## 🔧 Configuration

### For Galileosky Devices
Configure your devices to send data to:
- **IP Address**: Your phone's IP address
- **Port**: 3003
- **Protocol**: TCP

## 📋 Useful Commands

```bash
# Start server and show interface URL
~/ohw-start.sh

# Check status and show interface URL
~/ohw-status.sh

# Open simple interface directly
~/.shortcuts/ohw-open-simple-interface.sh

# View server logs
tail -f ~/ohw-server.log
```

## 🆘 Troubleshooting

### Server Won't Start
- Check logs: `tail -f ~/ohw-server.log`
- Verify Node.js: `node --version`
- Check port: `netstat -tlnp | grep :3001`

### Can't Access Interface
- Use "Status Check" widget to get correct URL
- Check if server is running
- Try: http://localhost:3001/simple-unified-interface.html

### Widgets Not Working
- Install Termux:Widget app
- Check script permissions: `ls -la ~/.shortcuts/`
- Verify project directory in scripts

## 📞 Support

- **Project Directory**: ~/ohw-mobs
- **Logs**: ~/ohw-server.log
- **Status**: Use "Status Check" widget or `~/ohw-status.sh`
- **Main Interface**: http://localhost:3001/simple-unified-interface.html

---

**Installation completed on**: $(date)
**Project version**: OHW Mobile Parser v1.0.0
**Main Interface**: Simple Unified Interface
**Termux widgets**: Configured and ready to use
EOF

print_status "Installation summary created"

# Final summary
echo ""
echo "========================================"
echo "  🎉 Simple Installation Complete!"
echo "========================================"
echo ""
print_status "OHW Mobile Parser installed successfully!"
print_status "Termux widgets configured and ready!"
echo ""
echo "📱 Main Access Point:"
echo "   Simple Unified Interface: http://localhost:3001/simple-unified-interface.html"
echo ""
echo "🚀 Quick Start:"
echo "  1. Install 'Termux:Widget' from Google Play Store"
echo "  2. Add 'Start Server' widget to home screen"
echo "  3. Add 'Open Simple Interface' widget to home screen"
echo "  4. Tap 'Start Server' widget"
echo "  5. Tap 'Open Simple Interface' widget"
echo ""
echo "📖 Documentation:"
echo "  ~/OHW-SIMPLE-INSTALLATION-SUMMARY.md"
echo ""
print_info "Your OHW Mobile Parser is ready to use!"
print_info "Main interface: Simple Unified Interface"
