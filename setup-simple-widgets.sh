#!/bin/bash

# Simple Widget Setup for OHW Parser
# This creates basic, reliable widgets

echo "========================================"
echo "  Simple Widget Setup for OHW Parser"
echo "========================================"

# Create shortcuts directory
mkdir -p ~/.shortcuts

# Copy simple widgets
cp termux-widget-start-simple.sh ~/.shortcuts/ohw-start.sh
cp termux-widget-stop-simple.sh ~/.shortcuts/ohw-stop.sh
cp termux-widget-status-simple.sh ~/.shortcuts/ohw-status.sh

# Make executable
chmod +x ~/.shortcuts/ohw-*.sh

echo "✅ Simple widgets created!"
echo ""
echo "📱 Widgets created:"
echo "  • ohw-start.sh - Start server"
echo "  • ohw-stop.sh - Stop server"
echo "  • ohw-status.sh - Check status"
echo ""
echo "🔧 Next steps:"
echo "1. Install 'Termux:Widget' from Google Play Store"
echo "2. Add widgets to home screen"
echo "3. Select the ohw-*.sh scripts"
echo ""
echo "📖 These widgets use termux-toast for notifications"
echo "   and are designed to work reliably in Termux"
