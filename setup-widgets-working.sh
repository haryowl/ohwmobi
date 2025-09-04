#!/bin/bash

# 🚀 OHW Mobile Parser - Working Widget Setup
# This script creates widgets that actually execute commands

set -e

echo "========================================"
echo "  OHW Mobile Parser - Widget Setup"
echo "  Creating Working Widgets"
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

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "This script must be run in Termux!"
    exit 1
fi

print_info "Setting up working Termux widgets..."

# Create shortcuts directory
mkdir -p ~/.shortcuts
print_status "Created ~/.shortcuts directory"

# Copy widget scripts
cp termux-widget-start-fixed.sh ~/.shortcuts/ohw-start.sh
cp termux-widget-stop-fixed.sh ~/.shortcuts/ohw-stop.sh
cp termux-widget-status-fixed.sh ~/.shortcuts/ohw-status.sh

# Make scripts executable
chmod +x ~/.shortcuts/ohw-*.sh
print_status "Made widget scripts executable"

# Create a simple restart script
cat > ~/.shortcuts/ohw-restart.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# OHW Parser Restart Widget
export PATH="/data/data/com.termux/files/usr/bin:$PATH"
cd /data/data/com.termux/files/home

# Find project directory
PROJECT_DIR=""
if [ -d "ohw-mobs" ]; then
    PROJECT_DIR="ohw-mobs"
elif [ -d "ohwmobi" ]; then
    PROJECT_DIR="ohwmobi"
else
    echo "❌ Project directory not found!"
    exit 1
fi

cd "$PROJECT_DIR"

echo "🔄 Restarting OHW Parser Server..."

# Stop server
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo "✅ Server stopped"
    fi
    rm -f ~/ohw-server.pid
fi

# Kill any remaining processes
pkill -f "node.*termux" 2>/dev/null || true

# Wait a moment
sleep 2

# Start server
if [ -f "termux-enhanced-backend.js" ]; then
    nohup node termux-enhanced-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Enhanced server restarted!"
elif [ -f "termux-simple-backend.js" ]; then
    nohup node termux-simple-backend.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Simple server restarted!"
elif [ -f "backend/src/server.js" ]; then
    nohup node backend/src/server.js > ~/ohw-server.log 2>&1 &
    echo $! > ~/ohw-server.pid
    echo "✅ Backend server restarted!"
else
    echo "❌ No backend found!"
    exit 1
fi

# Wait and check
sleep 3
if [ -f ~/ohw-server.pid ]; then
    PID=$(cat ~/ohw-server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "✅ Server running! Access: localhost:3001"
    else
        echo "❌ Server failed to start"
    fi
fi
EOF

chmod +x ~/.shortcuts/ohw-restart.sh
print_status "Created restart widget"

# Create a README for widgets
cat > ~/.shortcuts/README-WIDGETS.md << 'EOF'
# 📱 OHW Mobile Parser - Widget Guide

## 🎯 Available Widgets

| Widget | Script | Description |
|--------|--------|-------------|
| 🚀 **Start Server** | `ohw-start.sh` | Starts the OHW Parser server |
| 🛑 **Stop Server** | `ohw-stop.sh` | Stops the OHW Parser server |
| 🔄 **Restart Server** | `ohw-restart.sh` | Restarts the OHW Parser server |
| 📊 **Status Check** | `ohw-status.sh` | Shows server status and info |

## 🔧 How to Add Widgets to Home Screen

### Step 1: Install Termux:Widget
1. Open **Google Play Store**
2. Search for **"Termux:Widget"**
3. Install the app

### Step 2: Add Widgets to Home Screen
1. **Long press** on your Android home screen
2. Select **"Widgets"** from the menu
3. Find **"Termux:Widget"** in the widget list
4. **Drag** it to your home screen
5. **Select** the script you want to run:
   - `ohw-start.sh` - Start server
   - `ohw-stop.sh` - Stop server
   - `ohw-restart.sh` - Restart server
   - `ohw-status.sh` - Check status

### Step 3: Customize Widget Appearance
- **Long press** the widget to resize
- **Tap** the widget to configure its appearance
- You can change the widget label and icon

## 🎮 Widget Usage

### Starting the Server
1. Tap the **"Start Server"** widget
2. Widget will execute the start command
3. Server starts in background
4. Access at: http://localhost:3001

### Checking Status
1. Tap the **"Status Check"** widget
2. Widget shows:
   - ✅ Server is RUNNING (if active)
   - ❌ Server is NOT RUNNING (if stopped)
   - Process ID, ports, and access URLs

## 🔧 Troubleshooting

### Widget Not Working
**Problem**: Widget doesn't respond or shows error
**Solutions**:
```bash
# Check if Termux:Widget is installed
# Verify script permissions
ls -la ~/.shortcuts/ohw-*

# Make scripts executable
chmod +x ~/.shortcuts/ohw-*.sh

# Check script content
cat ~/.shortcuts/ohw-start.sh
```

### Server Won't Start
**Problem**: "Start Server" widget fails
**Solutions**:
```bash
# Check if Node.js is installed
node --version

# Check project directory
ls -la ~/ohw-mobs/

# Check logs
tail -f ~/ohw-server.log

# Check if port is in use
netstat -tlnp | grep :3001
```

## 📱 Mobile-Specific Tips

### Battery Optimization
- Add **Termux** to battery optimization exceptions
- Disable battery optimization for **Termux:Widget** app
- Keep Termux running in background for widgets to work

### Network Access
- Ensure Termux has network permissions
- Check firewall settings if using mobile hotspot
- Use "Status Check" widget to get correct IP addresses

---

**Widget Setup Guide** - OHW Mobile Parser v1.0.0
**Last Updated**: $(date)
**Compatible with**: Termux 0.118+, Android 7.0+
EOF

print_status "Created widget documentation"

# Show available widgets
echo ""
print_info "Available widgets:"
ls -la ~/.shortcuts/ohw-*.sh

echo ""
print_success "🎉 Widget setup complete!"
echo ""
print_info "📱 Next steps:"
echo "1. Install 'Termux:Widget' from Google Play Store"
echo "2. Add widgets to your home screen"
echo "3. Select the ohw-*.sh scripts"
echo "4. Test the widgets!"
echo ""
print_info "📋 Available widgets:"
echo "   - ohw-start.sh (Start Server)"
echo "   - ohw-stop.sh (Stop Server)"
echo "   - ohw-restart.sh (Restart Server)"
echo "   - ohw-status.sh (Check Status)"
echo ""
print_info "📖 Widget guide: ~/.shortcuts/README-WIDGETS.md"
