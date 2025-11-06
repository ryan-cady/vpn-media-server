# Create the test script
cat > test-killswitch.sh << 'EOF'
#!/bin/bash

# VPN Kill Switch Test Script
# This script tests that no traffic leaks when VPN is down

set -e

echo "=========================================="
echo "VPN Kill Switch Test"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if gluetun container exists
if ! docker ps -a --format '{{.Names}}' | grep -q '^gluetun$'; then
    echo -e "${RED}Error: gluetun container not found${NC}"
    echo "Please start the services first: docker compose up -d"
    exit 1
fi

echo "Test 1: Checking if VPN is connected..."
echo "=========================================="

# Check if gluetun is running
if ! docker ps --format '{{.Names}}' | grep -q '^gluetun$'; then
    echo -e "${RED}✗ gluetun container is not running${NC}"
    echo "Start it with: docker start gluetun"
    exit 1
fi

# Get VPN IP
echo "Getting current IP through VPN..."
VPN_IP=$(docker exec gluetun wget -qO- ifconfig.me 2>/dev/null || echo "failed")

if [ "$VPN_IP" = "failed" ]; then
    echo -e "${RED}✗ Could not get IP address${NC}"
    echo "Check gluetun logs: docker logs gluetun"
    exit 1
fi

echo -e "${GREEN}✓ VPN is connected${NC}"
echo "VPN IP: $VPN_IP"
echo ""

# Get real IP for comparison
echo "Getting your real IP (not through VPN)..."
REAL_IP=$(wget -qO- ifconfig.me 2>/dev/null || echo "unknown")
echo "Your real IP: $REAL_IP"
echo ""

if [ "$VPN_IP" = "$REAL_IP" ]; then
    echo -e "${RED}✗ WARNING: VPN IP matches your real IP!${NC}"
    echo "VPN may not be working correctly!"
else
    echo -e "${GREEN}✓ VPN IP is different from real IP (good!)${NC}"
fi
echo ""

echo "Test 2: Testing kill switch..."
echo "=========================================="
echo "This will temporarily stop the VPN to test if traffic is blocked."
read -p "Press Enter to continue (or Ctrl+C to cancel)..."
echo ""

# Stop VPN
echo "Stopping gluetun container..."
docker stop gluetun > /dev/null
echo -e "${YELLOW}VPN stopped${NC}"
echo ""

# Wait a moment
sleep 2

# Try to get IP through qBittorrent container (should fail)
echo "Attempting to access internet from qBittorrent..."
echo "(This should timeout/fail - that means kill switch is working)"
echo ""

timeout 10 docker exec qbittorrent wget -qO- ifconfig.me 2>/dev/null && LEAK_STATUS="LEAKED" || LEAK_STATUS="BLOCKED"

echo ""
if [ "$LEAK_STATUS" = "LEAKED" ]; then
    echo -e "${RED}✗✗✗ CRITICAL: TRAFFIC IS LEAKING! ✗✗✗${NC}"
    echo -e "${RED}Kill switch is NOT working properly!${NC}"
    echo ""
    echo "This means your real IP could be exposed when VPN disconnects."
    echo "Check your LOCAL_NETWORK setting in .env file"
    echo ""
else
    echo -e "${GREEN}✓✓✓ KILL SWITCH IS WORKING! ✓✓✓${NC}"
    echo -e "${GREEN}No traffic leak detected.${NC}"
    echo ""
    echo "Your IP is protected even when VPN is down."
    echo ""
fi

# Restart VPN
echo "Restarting gluetun container..."
docker start gluetun > /dev/null
echo -e "${GREEN}✓ VPN restarted${NC}"
echo ""

echo "Waiting for VPN to reconnect..."
sleep 5

# Verify VPN is back
NEW_IP=$(docker exec gluetun wget -qO- ifconfig.me 2>/dev/null || echo "failed")
if [ "$NEW_IP" != "failed" ]; then
    echo -e "${GREEN}✓ VPN reconnected successfully${NC}"
    echo "New VPN IP: $NEW_IP"
else
    echo -e "${YELLOW}Warning: Could not verify VPN reconnection${NC}"
    echo "Check logs: docker logs gluetun"
fi

echo ""
echo "=========================================="
echo "Test Complete!"
echo "=========================================="

if [ "$LEAK_STATUS" = "BLOCKED" ]; then
    echo -e "${GREEN}Your setup is secure! ✓${NC}"
else
    echo -e "${RED}Please fix the configuration before use!${NC}"
fi
echo ""
EOF

# Make it executable
chmod +x test-killswitch.sh

# Run it
./test-killswitch.sh