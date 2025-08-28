# 🛰️ OHW Mobile Parser

**Galileosky GPS Tracking Parser for Mobile Devices**

A complete IoT tracking and telemetry system designed specifically for mobile deployment, particularly on Android devices using Termux. This project implements a comprehensive GPS tracking parser for Galileosky devices with real-time monitoring, peer-to-peer synchronization, and data management capabilities.

## 🚀 Quick Start

### One-Command Installation (Termux)

```bash
# Install in Termux with one command
curl -sSL https://raw.githubusercontent.com/haryowl/ohwmob/main/install-termux.sh | bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/haryowl/ohwmob.git
cd ohwmob

# Install dependencies
npm install
cd backend && npm install && cd ..

# Start the server
node termux-enhanced-backend.js
```

## 📱 Features

### 🎯 Core Functionality
- **Real-time GPS Tracking** - Live device monitoring and location tracking
- **TCP Data Reception** - Receives raw GPS data from Galileosky devices
- **WebSocket Support** - Real-time data streaming to web interfaces
- **SQLite Database** - Local data storage optimized for mobile devices

### 🔄 Advanced Features
- **Peer-to-Peer Sync** - Device-to-device data synchronization
- **Data Management** - Export, import, and backup capabilities
- **Mobile-Optimized UI** - Responsive web interface for mobile devices
- **Offline Support** - Works without internet connection
- **Hotspot Integration** - Easy setup for mobile hotspot scenarios

### 🌐 Network Services
- **HTTP Server** (Port 3001) - Web interface and API
- **TCP Server** (Port 3003) - Device data reception
- **Peer Sync** (Port 3004) - Device synchronization
- **WebSocket** - Real-time data streaming

## 📋 Prerequisites

- **Android 7.0+** with Termux installed
- **2GB+ free storage**
- **Internet connection** (for initial setup)
- **Galileosky GPS devices** (for tracking functionality)

## 🔧 Installation Options

### Method 1: Termux (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/haryowl/ohwmob/main/install-termux.sh | bash
```

### Method 2: Manual Setup
```bash
# Install Termux from F-Droid or Google Play Store
# Open Termux and run:
pkg update -y
pkg install -y nodejs git sqlite wget curl
git clone https://github.com/haryowl/ohwmob.git
cd ohwmob
npm install
cd backend && npm install && cd ..
```

### Method 3: Docker
```bash
docker pull haryowl/ohwmob:latest
docker run -d \
  --name ohw-parser \
  -p 3001:3001 \
  -p 3003:3003 \
  -p 3004:3004 \
  -v /data/ohw:/app/data \
  haryowl/ohwmob:latest
```

## 🎮 Usage

### Starting the Server
```bash
# After installation, start the server:
~/ohw-start.sh

# Or manually:
node termux-enhanced-backend.js
```

### Accessing the Interface
- **Main Interface**: http://localhost:3001
- **🎯 Unified Interface**: http://localhost:3001/unified
- **Mobile Interface**: http://localhost:3001/mobile
- **Peer Sync**: http://localhost:3001/peer-sync
- **Data Management**: http://localhost:3001/data-management

### Management Commands
```bash
~/ohw-start.sh    # Start server
~/ohw-status.sh   # Check status
~/ohw-stop.sh     # Stop server
~/ohw-restart.sh  # Restart server
```

## 🔄 Peer-to-Peer Sync Setup

### Hotspot Phone (Primary)
1. **Enable mobile hotspot**
2. **Start server**: `~/ohw-start.sh`
3. **Note your IP address** from status output

### Client Phone (Secondary)
1. **Connect to hotspot WiFi**
2. **Open browser**: `http://[HOTSPOT_IP]:3001/peer-sync`
3. **Click "Connect to Peer"** and enter hotspot IP

## 📊 Project Structure

```
ohwmob/
├── termux-enhanced-backend.js    # Main mobile server
├── unified-mobile-interface.html # Unified web interface
├── backend/                      # Backend services
│   ├── src/
│   │   ├── server.js
│   │   └── services/
│   └── data/                     # Data storage
├── frontend/                     # Frontend components
├── install-termux.sh            # One-command installer
└── docs/                        # Documentation
```

## 🔧 Configuration

### Environment Variables
```bash
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
```

### Galileosky Device Configuration
1. **Set device IP** to your server's IP address
2. **Configure port** to 3003 (TCP)
3. **Set data format** to Galileosky protocol
4. **Enable data transmission**

## 🛠️ Development

### Local Development
```bash
# Clone repository
git clone https://github.com/haryowl/ohwmob.git
cd ohwmob

# Install dependencies
npm install
cd backend && npm install && cd ..

# Start development server
npm run dev
```

### Building for Production
```bash
# Build frontend
cd frontend && npm run build && cd ..

# Start production server
NODE_ENV=production node termux-enhanced-backend.js
```

## 📚 Documentation

- **[Mobile Setup Guide](MOBILE_SETUP.md)** - Detailed mobile installation
- **[Quick Reference](MOBILE_QUICK_REFERENCE.md)** - Command reference
- **[Installation Guide](MOBILE_INSTALLATION_GUIDE.md)** - Step-by-step setup
- **[PWA Setup](PWA_SETUP_GUIDE.md)** - Progressive Web App configuration
- **[Peer Sync Guide](PEER_SYNC_README.md)** - Device synchronization

## 🐛 Troubleshooting

### Common Issues

#### Server Won't Start
```bash
# Check if port is in use
netstat -tulpn | grep :3001

# Kill conflicting process
kill -9 [PID]

# Restart server
~/ohw-restart.sh
```

#### Permission Denied
```bash
# Fix script permissions
chmod +x ~/ohw-*.sh

# Fix project permissions
chmod -R 755 ~/ohwmob
```

#### Can't Access Web Interface
```bash
# Check server status
~/ohw-status.sh

# Check logs
tail -f ~/ohw-server.log

# Verify IP address
ip route get 1
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature-name`
3. **Commit your changes**: `git commit -am 'Add feature'`
4. **Push to the branch**: `git push origin feature-name`
5. **Submit a pull request**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GitHub Issues**: [Report problems](https://github.com/haryowl/ohwmob/issues)
- **Documentation**: Check the guides in the `docs/` directory
- **Community**: Join OHW community forums

## 🔗 Links

- **GitHub Repository**: https://github.com/haryowl/ohwmob
- **PWA Demo**: https://haryowl.github.io/ohwmob/
- **Documentation**: Check README files in project

---

**Made with ❤️ for the IoT tracking community** 
