#!/bin/bash

# 🎯 Termux Widget Setup Script for OHW Mobile Parser - Simple Version
# Focuses on Simple Unified Interface Access

set -e

echo "========================================"
echo "  Termux Widget Setup - Simple Version"
echo "  Focus: Simple Unified Interface"
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
print_info "Main interface: Simple Unified Interface"

# Create shortcuts directory
echo ""
print_info "Creating shortcuts directory..."
mkdir -p ~/.shortcuts
print_status "Shortcuts directory created"

# Copy and modify widget scripts for simple interface focus
echo ""
print_info "Setting up simplified widget scripts..."

# Start server widget (modified to show simple interface)
sed "s|PROJECT_DIR=\"/data/data/com.termux/files/home/ohw-mobs\"|PROJECT_DIR=\"$CURRENT_DIR\"|g" termux-widget-start-server.sh > ~/.shortcuts/ohw-start-server.sh

# Add simple interface info to start script
cat >> ~/.shortcuts/ohw-start-server.sh << 'EOF'

# Show simple interface access info
echo ""
echo "📱 Simple Unified Interface will be available at:"
echo "   http://localhost:3001/simple-unified-interface.html"
LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "Not available")
if [ "$LOCAL_IP" != "Not available" ]; then
    echo "   http://$LOCAL_IP:3001/simple-unified-interface.html"
fi
EOF

# Copy other core widgets
sed "s|PROJECT_DIR=\"/data/data/com.termux/files/home/ohw-mobs\"|PROJECT_DIR=\"$CURRENT_DIR\"|g" termux-widget-stop-server.sh > ~/.shortcuts/ohw-stop-server.sh
sed "s|PROJECT_DIR=\"/data/data/com.termux/files/home/ohw-mobs\"|PROJECT_DIR=\"$CURRENT_DIR\"|g" termux-widget-restart-server.sh > ~/.shortcuts/ohw-restart-server.sh

# Create simplified status widget
cat > ~/.shortcuts/ohw-status.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Status Widget - Simple Version
PROJECT_DIR="$CURRENT_DIR"
cd "\$PROJECT_DIR"

echo "=== OHW Parser Status ==="

# Check if server is running
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    echo "✅ Server is RUNNING"
    echo ""
    echo "📱 Simple Unified Interface:"
    echo "   http://localhost:3001/simple-unified-interface.html"
    
    # Get network IP
    LOCAL_IP=\$(ip route get 1.1.1.1 | awk '{print \$7; exit}' 2>/dev/null || echo "Not available")
    if [ "\$LOCAL_IP" != "Not available" ]; then
        echo "   http://\$LOCAL_IP:3001/simple-unified-interface.html"
    fi
else
    echo "❌ Server is NOT RUNNING"
    echo ""
    echo "Start server using the 'Start Server' widget"
fi
EOF

# Create main interface access widget
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

# Create simplified logs widget
cat > ~/.shortcuts/ohw-view-logs.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# View OHW Parser Logs Widget - Simple Version
echo "=== OHW Parser Server Logs ==="
echo ""

if [ -f ~/ohw-server.log ]; then
    echo "📋 Recent server logs (last 10 lines):"
    echo "----------------------------------------"
    tail -10 ~/ohw-server.log
    echo ""
    echo "📁 Full log file: ~/ohw-server.log"
else
    echo "❌ No log file found"
    echo "Start the server first to generate logs"
fi

echo ""
echo "=== Server Status ==="
if pgrep -f "node.*termux-enhanced-backend.js" > /dev/null || pgrep -f "node.*termux-simple-backend.js" > /dev/null; then
    echo "✅ Server is running"
    echo "📱 Interface: http://localhost:3001/simple-unified-interface.html"
else
    echo "❌ Server is not running"
fi
EOF

# Create simplified network info widget
cat > ~/.shortcuts/ohw-network-info.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# OHW Parser Network Info Widget - Simple Version
echo "=== OHW Parser Network Information ==="
echo ""

# Get local IP
LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "Not available")

echo "🌐 Simple Unified Interface Access:"
echo "----------------------------------------"
echo "Local Access: http://localhost:3001/simple-unified-interface.html"

if [ "$LOCAL_IP" != "Not available" ]; then
    echo "Network Access: http://$LOCAL_IP:3001/simple-unified-interface.html"
    echo ""
    echo "📋 For other devices on same network:"
    echo "Use: http://$LOCAL_IP:3001/simple-unified-interface.html"
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

# Make all scripts executable
chmod +x ~/.shortcuts/ohw-*.sh

print_status "Simplified widget scripts created and made executable"

# Create simplified widget guide
echo ""
print_info "Creating simplified widget guide..."

cat > ~/.shortcuts/README-SIMPLE-WIDGETS.md << 'EOF'
# 🎯 OHW Parser Termux Widgets - Simple Version

## 📱 Main Access Point
**Simple Unified Interface**: http://localhost:3001/simple-unified-interface.html

## 🎯 Key Widgets

### Essential Widgets
- **ohw-start-server.sh** - Start the OHW Parser server
- **ohw-open-simple-interface.sh** - **Open Simple Unified Interface**
- **ohw-status.sh** - Check server status and show interface URL
- **ohw-stop-server.sh** - Stop the server

### Utility Widgets
- **ohw-view-logs.sh** - View recent server logs
- **ohw-network-info.sh** - Show network access information
- **ohw-restart-server.sh** - Restart the server

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
5. Select the script you want to run

## 🚀 Quick Start Workflow

### First Time Setup
1. **Start Server** - Tap "Start Server" widget
2. **Open Interface** - Tap "Open Simple Interface" widget
3. **Check Status** - Tap "Status Check" widget (optional)

### Daily Usage
1. **Start Server** - Tap "Start Server" widget
2. **Open Interface** - Tap "Open Simple Interface" widget
3. **Stop Server** - Tap "Stop Server" widget (when done)

## 📱 Main Interface Access

### Local Access
- **Simple Unified Interface**: http://localhost:3001/simple-unified-interface.html

### Network Access
- **Network Access**: http://[YOUR_IP]:3001/simple-unified-interface.html
- Use "Network Info" widget to get your IP address

## 🔧 Troubleshooting

### Widget Not Working
- Make sure Termux:Widget app is installed
- Check script permissions: `ls -la ~/.shortcuts/`
- Verify project directory in scripts

### Server Won't Start
- Check logs: `tail -f ~/ohw-server.log`
- Verify Node.js: `node --version`
- Check port: `netstat -tlnp | grep :3001`

### Can't Access Interface
- Use "Status Check" widget to get correct URL
- Check if server is running
- Try: http://localhost:3001/simple-unified-interface.html

## 📞 Support

- **Main Interface**: http://localhost:3001/simple-unified-interface.html
- **Project Directory**: ~/ohw-mobs
- **Logs**: ~/ohw-server.log
- **Status**: Use "Status Check" widget
EOF

print_status "Simplified widget guide created"

# Summary
echo ""
echo "========================================"
echo "  Simple Widget Setup Complete!"
echo "========================================"
echo ""
print_status "Simplified widgets created in: ~/.shortcuts/"
echo ""
echo "📱 Main Access Point:"
echo "  Simple Unified Interface: http://localhost:3001/simple-unified-interface.html"
echo ""
echo "🎯 Key Widgets:"
echo "  • ohw-start-server.sh - Start server"
echo "  • ohw-open-simple-interface.sh - **Open Simple Interface**"
echo "  • ohw-status.sh - Check status"
echo "  • ohw-stop-server.sh - Stop server"
echo ""
echo "📋 Next Steps:"
echo "  1. Install 'Termux:Widget' from Google Play Store"
echo "  2. Add 'Start Server' widget to home screen"
echo "  3. Add 'Open Simple Interface' widget to home screen"
echo "  4. Use widgets to manage your server"
echo ""
echo "📖 Read the guide: ~/.shortcuts/README-SIMPLE-WIDGETS.md"
echo ""
print_info "Simple widget setup completed successfully!"
print_info "Focus: Simple Unified Interface access"
