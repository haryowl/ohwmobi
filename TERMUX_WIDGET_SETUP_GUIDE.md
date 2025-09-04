# 📱 Termux Widget Setup Guide for OHW Mobile Parser

## 🎯 Overview

This guide shows you how to create and use Termux widgets for easy management of your OHW Mobile Parser server directly from your Android home screen.

## 🚀 Quick Setup

### One-Command Installation (Includes Widgets)
```bash
# Download and run the complete installer with widgets
curl -sSL https://raw.githubusercontent.com/haryowl/ohwmobi/main/install-termux-with-widgets.sh | bash
```

### Manual Widget Setup
```bash
# If you already have the project installed
cd ~/ohw-mobs
chmod +x setup-termux-widgets.sh
./setup-termux-widgets.sh
```

## 📱 Prerequisites

### Required Apps
1. **Termux** - Main terminal app
   - Download from F-Droid: https://f-droid.org/
   - Or from Google Play Store

2. **Termux:Widget** - Widget support
   - Download from Google Play Store
   - Search: "Termux:Widget"

### Required Packages
```bash
# Install in Termux
pkg update -y
pkg install -y nodejs git wget curl
```

## 🎯 Available Widgets

### Core Server Management
| Widget | Script | Description |
|--------|--------|-------------|
| 🚀 **Start Server** | `ohw-start-server.sh` | Starts the OHW Parser server |
| 🛑 **Stop Server** | `ohw-stop-server.sh` | Stops the OHW Parser server |
| 🔄 **Restart Server** | `ohw-restart-server.sh` | Restarts the OHW Parser server |
| 📊 **Status Check** | `ohw-status.sh` | Shows server status and info |

### Utility Widgets
| Widget | Script | Description |
|--------|--------|-------------|
| 🌐 **Open Interface** | `ohw-open-interface.sh` | Opens web interface in browser |
| 📋 **View Logs** | `ohw-view-logs.sh` | Shows recent server logs |
| 🔗 **Network Info** | `ohw-network-info.sh` | Displays network access info |

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
   - `ohw-start-server.sh` - Start server
   - `ohw-stop-server.sh` - Stop server
   - `ohw-restart-server.sh` - Restart server
   - `ohw-status.sh` - Check status
   - `ohw-open-interface.sh` - Open interface
   - `ohw-view-logs.sh` - View logs
   - `ohw-network-info.sh` - Network info

### Step 3: Customize Widget Appearance
- **Long press** the widget to resize
- **Tap** the widget to configure its appearance
- You can change the widget label and icon

## 🎮 Widget Usage Examples

### Starting the Server
1. Tap the **"Start Server"** widget
2. Widget will show: "Starting OHW Parser Server..."
3. Server starts in background
4. Access at: http://localhost:3001

### Checking Status
1. Tap the **"Status Check"** widget
2. Widget shows:
   - ✅ Server is RUNNING (if active)
   - ❌ Server is NOT RUNNING (if stopped)
   - Process ID, ports, and access URLs

### Opening Web Interface
1. Tap the **"Open Interface"** widget
2. Automatically opens browser to http://localhost:3001
3. Shows network access URLs for other devices

### Viewing Logs
1. Tap the **"View Logs"** widget
2. Shows recent server activity
3. Displays last 20 lines of server log

## 🔧 Widget Script Details

### Start Server Widget (`ohw-start-server.sh`)
```bash
#!/data/data/com.termux/files/usr/bin/bash
# Starts the OHW Parser server
# Tries enhanced backend first, falls back to simple
# Creates PID file for process tracking
# Shows success/failure status
```

### Stop Server Widget (`ohw-stop-server.sh`)
```bash
#!/data/data/com.termux/files/usr/bin/bash
# Stops all OHW Parser processes
# Kills Node.js processes
# Stops PM2 if running
# Removes PID file
```

### Restart Server Widget (`ohw-restart-server.sh`)
```bash
#!/data/data/com.termux/files/usr/bin/bash
# Stops existing server
# Waits for processes to stop
# Starts server again
# Verifies successful restart
```

### Status Widget (`ohw-status.sh`)
```bash
#!/data/data/com.termux/files/usr/bin/bash
# Checks if server is running
# Shows process information
# Displays port usage
# Shows access URLs
# Gets network IP for remote access
```

## 📋 Widget File Locations

### Scripts Location
```bash
~/.shortcuts/ohw-*.sh
```

### Available Scripts
```bash
ls -la ~/.shortcuts/ohw-*
```

### Widget Guide
```bash
cat ~/.shortcuts/README-WIDGETS.md
```

## 🚀 Quick Start Workflow

### First Time Setup
1. **Install Termux** and **Termux:Widget**
2. **Run installation script** with widgets
3. **Add widgets** to home screen
4. **Start server** using "Start Server" widget
5. **Check status** using "Status Check" widget
6. **Open interface** using "Open Interface" widget

### Daily Usage
1. **Start Server** - Tap "Start Server" widget
2. **Check Status** - Tap "Status Check" widget
3. **Access Interface** - Tap "Open Interface" widget
4. **View Logs** - Tap "View Logs" widget (if needed)
5. **Stop Server** - Tap "Stop Server" widget (when done)

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
cat ~/.shortcuts/ohw-start-server.sh
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

### Can't Access Interface
**Problem**: "Open Interface" widget doesn't work
**Solutions**:
```bash
# Use "Network Info" widget to get correct IP
# Check if server is running with "Status Check" widget
# Verify firewall settings
# Try manual access: http://localhost:3001
```

### Widget Scripts Missing
**Problem**: Widget scripts not found
**Solutions**:
```bash
# Re-run widget setup
cd ~/ohw-mobs
./setup-termux-widgets.sh

# Or create manually
mkdir -p ~/.shortcuts
# Copy scripts from project directory
```

## 📱 Mobile-Specific Tips

### Battery Optimization
- Add **Termux** to battery optimization exceptions
- Disable battery optimization for **Termux:Widget** app
- Keep Termux running in background for widgets to work

### Network Access
- Ensure Termux has network permissions
- Check firewall settings if using mobile hotspot
- Use "Network Info" widget to get correct IP addresses

### Storage Management
- Monitor storage space: `df -h`
- Clean logs if needed: `rm ~/ohw-server.log`
- Widget scripts are small (~1KB each)

## 🔄 Alternative Methods

### Method 1: Direct Commands
```bash
# Start server
cd ~/ohw-mobs
node termux-enhanced-backend.js

# Check status
~/ohw-status.sh

# Stop server
~/ohw-stop.sh
```

### Method 2: Shortcut Apps
- Use **"Shortcut Maker"** from Play Store
- Create shortcuts to Termux commands
- Less convenient than widgets but works

### Method 3: Tasker Integration
- Install **Tasker** from Play Store
- Create tasks to run Termux commands
- More complex but very powerful

## 📊 Widget Performance

### Resource Usage
- **Widget scripts**: ~1KB each
- **Memory usage**: Minimal
- **CPU usage**: Only when tapped
- **Battery impact**: Negligible

### Response Time
- **Start server**: 2-5 seconds
- **Stop server**: 1-2 seconds
- **Status check**: <1 second
- **Open interface**: <1 second

## 🎯 Best Practices

### Widget Organization
- Group related widgets together
- Use descriptive names
- Place frequently used widgets on main screen
- Keep less used widgets on secondary screens

### Server Management
- Always check status before starting
- Use restart widget for troubleshooting
- Monitor logs regularly
- Stop server when not needed to save battery

### Network Security
- Be aware of network access when using mobile hotspot
- Use "Network Info" widget to check IP addresses
- Consider firewall settings for public networks

## 📞 Support

### Getting Help
1. **Check logs**: Use "View Logs" widget
2. **Check status**: Use "Status Check" widget
3. **Check network**: Use "Network Info" widget
4. **Read documentation**: `cat ~/.shortcuts/README-WIDGETS.md`

### Common Issues
- **Widget not responding**: Reinstall Termux:Widget
- **Server won't start**: Check Node.js installation
- **Can't access interface**: Check network settings
- **Scripts missing**: Re-run widget setup

---

**Widget Setup Guide** - OHW Mobile Parser v1.0.0
**Last Updated**: $(date)
**Compatible with**: Termux 0.118+, Android 7.0+
