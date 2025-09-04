#!/bin/bash

# 🎯 Termux Widget Setup Script for OHW Mobile Parser
# This script sets up Termux widgets for easy server management

set -e

echo "========================================"
echo "  Termux Widget Setup for OHW Parser"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Get current directory
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")

echo ""
print_info "Setting up Termux widgets for: $PROJECT_NAME"
print_info "Project directory: $CURRENT_DIR"

# Create shortcuts directory
echo ""
print_info "Creating shortcuts directory..."
mkdir -p ~/.shortcuts
print_status "Shortcuts directory created"

# Copy widget scripts
echo ""
print_info "Setting up widget scripts..."

# Update project directory in widget scripts
sed "s|PROJECT_DIR=\"/data/data/com.termux/files/home/gali-parse\"|PROJECT_DIR=\"$CURRENT_DIR\"|g" termux-widget-start-server.sh > ~/.shortcuts/ohw-start-server.sh
sed "s|PROJECT_DIR=\"/data/data/com.termux/files/home/gali-parse\"|PROJECT_DIR=\"$CURRENT_DIR\"|g" termux-widget-stop-server.sh > ~/.shortcuts/ohw-stop-server.sh
sed "s|PROJECT_DIR=\"/data/data/com.termux/files/home/gali-parse\"|PROJECT_DIR=\"$CURRENT_DIR\"|g" termux-widget-status.sh > ~/.shortcuts/ohw-status.sh
sed "s|PROJECT_DIR=\"/data/data/com.termux/files/home/gali-parse\"|PROJECT_DIR=\"$CURRENT_DIR\"|g" termux-widget-restart-server.sh > ~/.shortcuts/ohw-restart-server.sh

# Make scripts executable
chmod +x ~/.shortcuts/ohw-*.sh

print_status "Widget scripts created and made executable"

# Create additional utility widgets
echo ""
print_info "Creating additional utility widgets..."

# Quick access widget
cat > ~/.shortcuts/ohw-open-interface.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Open OHW Parser Interface Widget
# This widget opens the web interface in your default browser

# Get the project directory from the first widget script
PROJECT_DIR=$(grep "PROJECT_DIR=" ~/.shortcuts/ohw-start-server.sh | cut -d'"' -f2)

# Check if server is running
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    # Get local IP address
    LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "localhost")
    
    # Open interface URLs
    echo "🌐 Opening OHW Parser Interface..."
    echo "Local: http://localhost:3001"
    echo "Network: http://$LOCAL_IP:3001"
    
    # Try to open in browser (if termux-open-url is available)
    if command -v termux-open-url &> /dev/null; then
        termux-open-url "http://localhost:3001"
    else
        echo "Install termux-api for browser opening: pkg install termux-api"
    fi
else
    echo "❌ Server is not running!"
    echo "Start the server first using the 'Start Server' widget"
fi
EOF

# Log viewer widget
cat > ~/.shortcuts/ohw-view-logs.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# View OHW Parser Logs Widget
# This widget shows recent server logs

echo "=== OHW Parser Server Logs ==="
echo ""

if [ -f ~/ohw-server.log ]; then
    echo "📋 Recent server logs (last 20 lines):"
    echo "----------------------------------------"
    tail -20 ~/ohw-server.log
    echo ""
    echo "📁 Full log file: ~/ohw-server.log"
    echo "💡 To view live logs: tail -f ~/ohw-server.log"
else
    echo "❌ No log file found"
    echo "Start the server first to generate logs"
fi

echo ""
echo "=== Server Status ==="
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    echo "✅ Server is running"
    if [ -f ~/ohw-server.pid ]; then
        PID=$(cat ~/ohw-server.pid)
        echo "📊 Process ID: $PID"
    fi
else
    echo "❌ Server is not running"
fi
EOF

# Network info widget
cat > ~/.shortcuts/ohw-network-info.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Network Info Widget
# This widget shows network information for accessing the server

echo "=== OHW Parser Network Information ==="
echo ""

# Get local IP
LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "Not available")

# Get public IP (if internet available)
PUBLIC_IP=$(curl -s https://api.ipify.org 2>/dev/null || echo "Not available")

echo "🌐 Network Access Information:"
echo "----------------------------------------"
echo "Local IP: $LOCAL_IP"
echo "Public IP: $PUBLIC_IP"
echo ""

if [ "$LOCAL_IP" != "Not available" ]; then
    echo "📱 Access URLs:"
    echo "Local access: http://localhost:3001"
    echo "Network access: http://$LOCAL_IP:3001"
    echo ""
    echo "📋 For other devices on same network:"
    echo "Use: http://$LOCAL_IP:3001"
    echo ""
    echo "🔧 For Galileosky devices:"
    echo "Configure devices to send data to:"
    echo "IP: $LOCAL_IP"
    echo "Port: 3003"
else
    echo "❌ Network information not available"
fi

echo ""
echo "=== Server Status ==="
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    echo "✅ Server is running and accessible"
else
    echo "❌ Server is not running"
    echo "Start the server first using the 'Start Server' widget"
fi
EOF

# Make additional widgets executable
chmod +x ~/.shortcuts/ohw-open-interface.sh
chmod +x ~/.shortcuts/ohw-view-logs.sh
chmod +x ~/.shortcuts/ohw-network-info.sh

print_status "Additional utility widgets created"

# Create widget installation guide
echo ""
print_info "Creating widget installation guide..."

cat > ~/.shortcuts/README-WIDGETS.md << EOF
# 🎯 OHW Parser Termux Widgets

## 📱 Available Widgets

### Core Server Management
- **ohw-start-server.sh** - Start the OHW Parser server
- **ohw-stop-server.sh** - Stop the OHW Parser server  
- **ohw-restart-server.sh** - Restart the OHW Parser server
- **ohw-status.sh** - Check server status and information

### Utility Widgets
- **ohw-open-interface.sh** - Open web interface in browser
- **ohw-view-logs.sh** - View recent server logs
- **ohw-network-info.sh** - Show network access information

## 🔧 How to Add Widgets to Home Screen

### Step 1: Install Termux:Widget
1. Open **Google Play Store**
2. Search for **"Termux:Widget"**
3. Install the app

### Step 2: Add Widgets to Home Screen
1. Long press on your **Android home screen**
2. Select **"Widgets"**
3. Find **"Termux:Widget"** in the widget list
4. Drag it to your home screen
5. Select the script you want to run:
   - `ohw-start-server.sh` - Start server
   - `ohw-stop-server.sh` - Stop server
   - `ohw-restart-server.sh` - Restart server
   - `ohw-status.sh` - Check status
   - `ohw-open-interface.sh` - Open interface
   - `ohw-view-logs.sh` - View logs
   - `ohw-network-info.sh` - Network info

### Step 3: Customize Widget Appearance
- Long press the widget to resize
- Tap the widget to configure its appearance
- You can change the widget label and icon

## 🚀 Quick Start

1. **Start Server**: Tap the "Start Server" widget
2. **Check Status**: Tap the "Status" widget to verify it's running
3. **Open Interface**: Tap the "Open Interface" widget to access the web UI
4. **View Logs**: Tap the "View Logs" widget to see server activity

## 📋 Server Access URLs

- **Local Access**: http://localhost:3001
- **Network Access**: http://[YOUR_IP]:3001
- **API Endpoint**: http://localhost:3001/api
- **TCP Server**: [YOUR_IP]:3003 (for Galileosky devices)

## 🔧 Troubleshooting

### Widget Not Working
- Make sure Termux:Widget app is installed
- Check that scripts are executable: \`ls -la ~/.shortcuts/\`
- Verify project directory is correct in scripts

### Server Won't Start
- Check logs: \`tail -f ~/ohw-server.log\`
- Verify Node.js is installed: \`node --version\`
- Check if port is in use: \`netstat -tlnp | grep :3001\`

### Can't Access Interface
- Use the "Network Info" widget to get correct IP
- Check firewall settings
- Verify server is running with "Status" widget

## 📞 Support

For issues or questions:
1. Check the logs using the "View Logs" widget
2. Use the "Status" widget to verify server state
3. Use the "Network Info" widget to check connectivity
EOF

print_status "Widget installation guide created"

# Summary
echo ""
echo "========================================"
echo "  Widget Setup Complete!"
echo "========================================"
echo ""
print_status "Widgets created in: ~/.shortcuts/"
echo ""
echo "📱 Available Widgets:"
echo "  • ohw-start-server.sh - Start server"
echo "  • ohw-stop-server.sh - Stop server"
echo "  • ohw-restart-server.sh - Restart server"
echo "  • ohw-status.sh - Check status"
echo "  • ohw-open-interface.sh - Open web interface"
echo "  • ohw-view-logs.sh - View server logs"
echo "  • ohw-network-info.sh - Network information"
echo ""
echo "📋 Next Steps:"
echo "  1. Install 'Termux:Widget' from Google Play Store"
echo "  2. Add widgets to your home screen"
echo "  3. Use widgets to manage your OHW Parser server"
echo ""
echo "📖 Read the guide: ~/.shortcuts/README-WIDGETS.md"
echo ""
print_info "Widget setup completed successfully!"
