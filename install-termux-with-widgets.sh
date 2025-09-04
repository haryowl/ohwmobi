#!/bin/bash

# 🚀 OHW Mobile Parser - Complete Termux Installation with Widgets
# This script installs the OHW Parser and sets up Termux widgets for easy management

set -e

echo "========================================"
echo "  OHW Mobile Parser - Complete Setup"
echo "  Including Termux Widgets"
echo "========================================"

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
pkg install -y nodejs git wget curl python build-essential
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
chmod +x setup-widgets-working.sh
./setup-widgets-working.sh
print_status "Termux widgets configured"

# Step 7: Create startup scripts
echo ""
print_step "Step 7: Creating startup scripts..."

# Create main startup script
cat > ~/ohw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/ohw-mobs
echo "🚀 Starting OHW Parser Server..."
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
    echo "Access: http://localhost:3001"
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

# Step 8: Create installation summary
echo ""
print_step "Step 8: Creating installation summary..."

cat > ~/OHW-INSTALLATION-SUMMARY.md << 'EOF'
# 🎉 OHW Mobile Parser - Installation Complete!

## 📱 What's Installed

### Core Application
- ✅ OHW Mobile Parser server
- ✅ Enhanced backend (full features)
- ✅ Simple backend (lightweight)
- ✅ Web interfaces
- ✅ TCP server for Galileosky devices

### Termux Widgets
- ✅ Start Server widget
- ✅ Stop Server widget
- ✅ Restart Server widget
- ✅ Status Check widget
- ✅ Open Interface widget
- ✅ View Logs widget
- ✅ Network Info widget

## 🚀 Quick Start

### Method 1: Use Widgets (Recommended)
1. Install **Termux:Widget** from Google Play Store
2. Add widgets to your home screen
3. Tap "Start Server" widget to begin

### Method 2: Use Commands
```bash
# Start server
~/ohw-start.sh

# Check status
~/ohw-status.sh

# Stop server
~/ohw-stop.sh
```

### Method 3: Direct Commands
```bash
cd ~/ohw-mobs
node termux-enhanced-backend.js  # Full features
# OR
node termux-simple-backend.js    # Simple version
```

## 🌐 Access Your Server

- **Web Interface**: http://localhost:3001
- **API Endpoint**: http://localhost:3001/api
- **TCP Server**: localhost:3003 (for Galileosky devices)

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
   - Select widget script (e.g., "ohw-start-server.sh")

3. **Available Widgets**:
   - `ohw-start-server.sh` - Start server
   - `ohw-stop-server.sh` - Stop server
   - `ohw-restart-server.sh` - Restart server
   - `ohw-status.sh` - Check status
   - `ohw-open-interface.sh` - Open web interface
   - `ohw-view-logs.sh` - View server logs
   - `ohw-network-info.sh` - Network information

## 🔧 Configuration

### For Galileosky Devices
Configure your devices to send data to:
- **IP Address**: Your phone's IP address
- **Port**: 3003
- **Protocol**: TCP

### Network Access
- **Local**: http://localhost:3001
- **Network**: http://[YOUR_IP]:3001

## 📋 Useful Commands

```bash
# View server logs
tail -f ~/ohw-server.log

# Check running processes
ps aux | grep node

# Check network ports
netstat -tlnp | grep :3001

# View widget scripts
ls -la ~/.shortcuts/ohw-*

# Read widget guide
cat ~/.shortcuts/README-WIDGETS.md
```

## 🆘 Troubleshooting

### Server Won't Start
- Check logs: `tail -f ~/ohw-server.log`
- Verify Node.js: `node --version`
- Check port: `netstat -tlnp | grep :3001`

### Widgets Not Working
- Install Termux:Widget app
- Check script permissions: `ls -la ~/.shortcuts/`
- Verify project directory in scripts

### Can't Access Interface
- Use "Network Info" widget to get correct IP
- Check firewall settings
- Verify server is running

## 📞 Support

- **Widget Guide**: ~/.shortcuts/README-WIDGETS.md
- **Project Directory**: ~/ohw-mobs
- **Logs**: ~/ohw-server.log
- **Status**: Use "Status" widget or `~/ohw-status.sh`

---

**Installation completed on**: $(date)
**Project version**: OHW Mobile Parser v1.0.0
**Termux widgets**: Configured and ready to use
EOF

print_status "Installation summary created"

# Final summary
echo ""
echo "========================================"
echo "  🎉 Installation Complete!"
echo "========================================"
echo ""
print_status "OHW Mobile Parser installed successfully!"
print_status "Termux widgets configured and ready!"
echo ""
echo "📱 Next Steps:"
echo "  1. Install 'Termux:Widget' from Google Play Store"
echo "  2. Add widgets to your home screen"
echo "  3. Start the server using widgets or commands"
echo ""
echo "🚀 Quick Start:"
echo "  ~/ohw-start.sh          # Start server"
echo "  ~/ohw-status.sh         # Check status"
echo "  ~/ohw-stop.sh           # Stop server"
echo ""
echo "📖 Documentation:"
echo "  ~/OHW-INSTALLATION-SUMMARY.md"
echo "  ~/.shortcuts/README-WIDGETS.md"
echo ""
print_info "Installation completed successfully!"
print_info "Your OHW Mobile Parser is ready to use!"


