#!/bin/bash

# VPN Media Server - Complete Installation Script
# This script will install and configure everything from scratch

set -e

echo "=========================================="
echo "VPN Media Server - Complete Installation"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root/sudo${NC}"
    echo "Run as your normal user. The script will ask for sudo when needed."
    exit 1
fi

echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"
echo "=========================================="

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    
    # Update package list
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}✓ Docker installed${NC}"
    echo -e "${YELLOW}Note: You may need to log out and back in for Docker group permissions${NC}"
else
    echo -e "${GREEN}✓ Docker is already installed${NC}"
fi

# Check Docker Compose
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose not found. Installing...${NC}"
    
    # Install docker-compose standalone
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose is already installed${NC}"
fi

echo ""
echo -e "${BLUE}Step 2: Creating project directory...${NC}"
echo "=========================================="

# Ask for installation directory
read -p "Enter installation directory [~/vpn-media-server]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-~/vpn-media-server}
INSTALL_DIR=$(eval echo $INSTALL_DIR)  # Expand ~ to home directory

# Create and navigate to directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo -e "${GREEN}✓ Created directory: $INSTALL_DIR${NC}"
echo ""

echo -e "${BLUE}Step 3: Downloading configuration files...${NC}"
echo "=========================================="

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: "3.8"

services:
  # VPN Container - All traffic routes through this
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      # qBittorrent
      - "${QBITTORRENT_PORT:-9090}:9090"
      - "${TORRENT_PORT:-6881}:6881"
      - "${TORRENT_PORT:-6881}:6881/udp"
      # Radarr
      - "${RADARR_PORT:-7878}:7878"
      # Sonarr
      - "${SONARR_PORT:-8989}:8989"
      # Lidarr
      - "${LIDARR_PORT:-8686}:8686"
      # Jackett
      - "${JACKETT_PORT:-9117}:9117"
      # Prowlarr
      - "${PROWLARR_PORT:-9696}:9696"
    environment:
      - VPN_SERVICE_PROVIDER=private internet access
      - VPN_TYPE=${VPN_TYPE:-openvpn}
      - OPENVPN_USER=${PIA_USERNAME}
      - OPENVPN_PASSWORD=${PIA_PASSWORD}
      - SERVER_REGIONS=${VPN_SERVER_REGION:-US New York}
      - FIREWALL_OUTBOUND_SUBNETS=${LOCAL_NETWORK:-192.168.1.0/24}
      - FIREWALL_VPN_INPUT_PORTS=${TORRENT_PORT:-6881}
      - TZ=${TZ:-America/New_York}
    volumes:
      - ./gluetun:/gluetun
    restart: unless-stopped

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/New_York}
      - WEBUI_PORT=9090
    volumes:
      - ./qbittorrent/config:/config
      - ./downloads:/downloads
    depends_on:
      - gluetun
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/New_York}
    volumes:
      - ./radarr/config:/config
      - ./downloads:/downloads
      - ./media/movies:/movies
    depends_on:
      - gluetun
    restart: unless-stopped

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/New_York}
    volumes:
      - ./sonarr/config:/config
      - ./downloads:/downloads
      - ./media/tv:/tv
    depends_on:
      - gluetun
    restart: unless-stopped

  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/New_York}
    volumes:
      - ./lidarr/config:/config
      - ./downloads:/downloads
      - ./media/music:/music
    depends_on:
      - gluetun
    restart: unless-stopped

  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/New_York}
      - AUTO_UPDATE=true
    volumes:
      - ./jackett/config:/config
      - ./downloads:/downloads
    depends_on:
      - gluetun
    restart: unless-stopped

  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/New_York}
    volumes:
      - ./prowlarr/config:/config
    depends_on:
      - gluetun
    restart: unless-stopped

EOF

echo -e "${GREEN}✓ Created docker-compose.yml${NC}"

echo ""
echo -e "${BLUE}Step 4: Configuring environment...${NC}"
echo "=========================================="

# Get user configuration
USER_ID=$(id -u)
GROUP_ID=$(id -g)
echo "Your PUID: $USER_ID"
echo "Your PGID: $GROUP_ID"
echo ""

# Detect local network
DEFAULT_GATEWAY=$(ip route | grep default | awk '{print $3}')
if [ ! -z "$DEFAULT_GATEWAY" ]; then
    LOCAL_NET=$(echo $DEFAULT_GATEWAY | cut -d'.' -f1-3).0/24
    echo "Detected local network: $LOCAL_NET"
else
    LOCAL_NET="192.168.1.0/24"
    echo "Could not detect network, using default: $LOCAL_NET"
fi
read -p "Press Enter to accept or type your network CIDR: " USER_NET
LOCAL_NET=${USER_NET:-$LOCAL_NET}
echo ""

# Get PIA credentials
echo "Enter your PIA (Private Internet Access) credentials:"
read -p "PIA Username: " PIA_USER
read -s -p "PIA Password: " PIA_PASS
echo ""
echo ""

# VPN Region
echo "Popular VPN regions:"
echo "  1) US New York"
echo "  2) US California"
echo "  3) UK London"
echo "  4) Netherlands"
echo "  5) Canada Toronto"
echo "  6) Custom (enter manually)"
read -p "Select region [1]: " REGION_CHOICE
REGION_CHOICE=${REGION_CHOICE:-1}

case $REGION_CHOICE in
    1) VPN_REGION="US New York" ;;
    2) VPN_REGION="US California" ;;
    3) VPN_REGION="UK London" ;;
    4) VPN_REGION="Netherlands" ;;
    5) VPN_REGION="Canada Toronto" ;;
    6) read -p "Enter region: " VPN_REGION ;;
    *) VPN_REGION="US New York" ;;
esac
echo "Using region: $VPN_REGION"
echo ""

# Timezone
read -p "Enter your timezone [America/New_York]: " TIMEZONE
TIMEZONE=${TIMEZONE:-America/New_York}
echo ""

# Create .env file
cat > .env << EOF
# PIA VPN Credentials
PIA_USERNAME=$PIA_USER
PIA_PASSWORD=$PIA_PASS

# VPN Configuration
VPN_SERVER_REGION=$VPN_REGION
VPN_TYPE=openvpn

# Network Configuration
LOCAL_NETWORK=$LOCAL_NET

# User Configuration
PUID=$USER_ID
PGID=$GROUP_ID

# Timezone
TZ=$TIMEZONE

# Ports
QBITTORRENT_PORT=9090
RADARR_PORT=7878
SONARR_PORT=8989
LIDARR_PORT=8686
JACKETT_PORT=9117
PROWLARR_PORT=9696
TORRENT_PORT=6881
EOF

echo -e "${GREEN}✓ Created .env file${NC}"
echo ""

echo -e "${BLUE}Step 5: Creating directory structure...${NC}"
echo "=========================================="

# Create all directories
mkdir -p gluetun
mkdir -p qbittorrent/config
mkdir -p radarr/config
mkdir -p sonarr/config
mkdir -p lidarr/config
mkdir -p jackett/config
mkdir -p prowlarr/config
mkdir -p downloads/{incomplete,complete}
mkdir -p media/{movies,tv,music,adult}

# Set permissions
chmod -R 755 ./*

echo -e "${GREEN}✓ Created all directories${NC}"
echo ""

echo -e "${BLUE}Step 6: Pulling Docker images...${NC}"
echo "=========================================="
echo "This may take a few minutes..."
echo ""

docker compose pull

echo -e "${GREEN}✓ All images downloaded${NC}"
echo ""

echo -e "${BLUE}Step 7: Starting services...${NC}"
echo "=========================================="

docker compose up -d

echo -e "${GREEN}✓ All services started${NC}"
echo ""

echo "Waiting for services to initialize (30 seconds)..."
sleep 30

echo ""
echo -e "${BLUE}Step 8: Checking VPN connection...${NC}"
echo "=========================================="

# Check if gluetun is running
if docker ps | grep -q gluetun; then
    echo -e "${GREEN}✓ Gluetun container is running${NC}"
    
    # Try to get VPN IP
    sleep 5
    VPN_IP=$(docker exec gluetun wget -qO- ifconfig.me 2>/dev/null || echo "connecting...")
    
    if [ "$VPN_IP" != "connecting..." ]; then
        echo -e "${GREEN}✓ VPN connected successfully!${NC}"
        echo "VPN IP: $VPN_IP"
    else
        echo -e "${YELLOW}⚠ VPN is still connecting...${NC}"
        echo "Check status with: docker logs gluetun"
    fi
else
    echo -e "${RED}✗ Gluetun container failed to start${NC}"
    echo "Check logs with: docker logs gluetun"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=========================================="
echo ""
echo "Your VPN Media Server is now running!"
echo ""
echo "Access your services at:"
echo "  - qBittorrent:  http://$(hostname -I | awk '{print $1}'):9090 (user: admin, pass: adminadmin)"
echo "  - Radarr:       http://$(hostname -I | awk '{print $1}'):7878"
echo "  - Sonarr:       http://$(hostname -I | awk '{print $1}'):8989"
echo "  - Lidarr:       http://$(hostname -I | awk '{print $1}'):8686"
echo "  - Jackett:      http://$(hostname -I | awk '{print $1}'):9117"
echo "  - Prowlarr:     http://$(hostname -I | awk '{print $1}'):9696"
echo ""
echo "Installation location: $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "  1. Change qBittorrent password immediately!"
echo "  2. Configure Prowlarr with your indexers"
echo "  3. Connect *arr apps to Prowlarr"
echo "  4. Test kill switch: cd $INSTALL_DIR && ./test-killswitch.sh"
echo ""
echo "Useful commands:"
echo "  - View logs:    docker compose logs -f"
echo "  - Restart all:  docker compose restart"
echo "  - Stop all:     docker compose down"
echo "  - Update all:   docker compose pull && docker compose up -d"
echo ""
echo "For detailed setup, see the README files in: $INSTALL_DIR"
echo ""
