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
CYAN='\033[0;36m'
NC='\033[0m'

# Arrays to track selected services
SELECTED_MEDIA_SERVERS=()
SELECTED_OPTIONAL_SERVICES=()

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
    
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}✓ Docker installed${NC}"
    echo -e "${YELLOW}Note: You may need to log out and back in for Docker group permissions${NC}"
else
    echo -e "${GREEN}✓ Docker is already installed${NC}"
fi

# Check Docker Compose
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose not found. Installing...${NC}"
    
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose is already installed${NC}"
fi

echo ""
echo -e "${BLUE}Step 2: Creating project directory...${NC}"
echo "=========================================="

read -p "Enter installation directory [~/vpn-media-server]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-~/vpn-media-server}
INSTALL_DIR=$(eval echo $INSTALL_DIR)

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo -e "${GREEN}✓ Created directory: $INSTALL_DIR${NC}"
echo ""

echo -e "${BLUE}Step 3: Selecting Media Servers...${NC}"
echo "=========================================="
echo ""
echo -e "${CYAN}Choose which media server(s) to install:${NC}"
echo "You can select multiple or none (press Enter to skip each)"
echo ""

# Plex selection
read -p "Install Plex? (y/N): " INSTALL_PLEX
if [[ $INSTALL_PLEX =~ ^[Yy]$ ]]; then
    SELECTED_MEDIA_SERVERS+=("plex")
    echo -e "${GREEN}✓ Plex will be installed${NC}"
fi

# Emby selection
read -p "Install Emby? (y/N): " INSTALL_EMBY
if [[ $INSTALL_EMBY =~ ^[Yy]$ ]]; then
    SELECTED_MEDIA_SERVERS+=("emby")
    echo -e "${GREEN}✓ Emby will be installed${NC}"
fi

# Jellyfin selection
read -p "Install Jellyfin? (y/N): " INSTALL_JELLYFIN
if [[ $INSTALL_JELLYFIN =~ ^[Yy]$ ]]; then
    SELECTED_MEDIA_SERVERS+=("jellyfin")
    echo -e "${GREEN}✓ Jellyfin will be installed${NC}"
fi

# Channels DVR selection
read -p "Install Channels DVR? (y/N): " INSTALL_CHANNELS
if [[ $INSTALL_CHANNELS =~ ^[Yy]$ ]]; then
    SELECTED_MEDIA_SERVERS+=("channels-dvr")
    echo -e "${GREEN}✓ Channels DVR will be installed${NC}"
fi

if [ ${#SELECTED_MEDIA_SERVERS[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠ No media servers selected. You can add them later if needed.${NC}"
fi

echo ""
echo -e "${BLUE}Step 4: Selecting Optional Services...${NC}"
echo "=========================================="
echo ""
echo -e "${CYAN}Choose optional services to install:${NC}"
echo ""

# Readarr (Books)
read -p "Install Readarr (Book management)? (y/N): " INSTALL_READARR
if [[ $INSTALL_READARR =~ ^[Yy]$ ]]; then
    SELECTED_OPTIONAL_SERVICES+=("readarr")
    echo -e "${GREEN}✓ Readarr will be installed${NC}"
fi

# Bazarr (Subtitles)
read -p "Install Bazarr (Subtitle management)? (y/N): " INSTALL_BAZARR
if [[ $INSTALL_BAZARR =~ ^[Yy]$ ]]; then
    SELECTED_OPTIONAL_SERVICES+=("bazarr")
    echo -e "${GREEN}✓ Bazarr will be installed${NC}"
fi

# FlareSolverr
read -p "Install FlareSolverr (Cloudflare bypass for indexers)? (y/N): " INSTALL_FLARESOLVERR
if [[ $INSTALL_FLARESOLVERR =~ ^[Yy]$ ]]; then
    SELECTED_OPTIONAL_SERVICES+=("flaresolverr")
    echo -e "${GREEN}✓ FlareSolverr will be installed${NC}"
fi

# Tautulli (Plex monitoring)
if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " plex " ]]; then
    read -p "Install Tautulli (Plex monitoring & statistics)? (y/N): " INSTALL_TAUTULLI
    if [[ $INSTALL_TAUTULLI =~ ^[Yy]$ ]]; then
        SELECTED_OPTIONAL_SERVICES+=("tautulli")
        echo -e "${GREEN}✓ Tautulli will be installed${NC}"
    fi
fi

# Overseerr (Plex request management)
if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " plex " ]]; then
    read -p "Install Overseerr (Plex request management)? (y/N): " INSTALL_OVERSEERR
    if [[ $INSTALL_OVERSEERR =~ ^[Yy]$ ]]; then
        SELECTED_OPTIONAL_SERVICES+=("overseerr")
        echo -e "${GREEN}✓ Overseerr will be installed${NC}"
    fi
fi

# Jellyseerr (Jellyfin request management)
if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " jellyfin " ]]; then
    read -p "Install Jellyseerr (Jellyfin request management)? (y/N): " INSTALL_JELLYSEERR
    if [[ $INSTALL_JELLYSEERR =~ ^[Yy]$ ]]; then
        SELECTED_OPTIONAL_SERVICES+=("jellyseerr")
        echo -e "${GREEN}✓ Jellyseerr will be installed${NC}"
    fi
fi

echo ""
echo -e "${BLUE}Step 5: Selecting VPN Provider...${NC}"
echo "=========================================="
echo ""
echo "Supported VPN Providers:"
echo "  1) Private Internet Access (PIA)"
echo "  2) NordVPN"
echo "  3) ExpressVPN"
echo "  4) Surfshark"
echo "  5) Mullvad"
echo "  6) ProtonVPN"
echo "  7) Other (Custom - requires manual configuration)"
echo ""
read -p "Select your VPN provider [1]: " VPN_CHOICE
VPN_CHOICE=${VPN_CHOICE:-1}

case $VPN_CHOICE in
    1)
        VPN_PROVIDER="private internet access"
        VPN_TYPE="openvpn"
        echo ""
        echo "Selected: Private Internet Access (PIA)"
        echo "Enter your PIA credentials:"
        read -p "PIA Username: " VPN_USER
        read -s -p "PIA Password: " VPN_PASS
        echo ""
        VPN_AUTH_TYPE="userpass"
        ;;
    2)
        VPN_PROVIDER="nordvpn"
        VPN_TYPE="openvpn"
        echo ""
        echo "Selected: NordVPN"
        echo "You need an access token from: https://my.nordaccount.com/dashboard/nordvpn/"
        echo "Go to Services → NordVPN → Manual Setup → Generate Token"
        read -p "Access Token: " VPN_TOKEN
        VPN_AUTH_TYPE="token"
        ;;
    3)
        VPN_PROVIDER="expressvpn"
        VPN_TYPE="openvpn"
        echo ""
        echo "Selected: ExpressVPN"
        echo "Enter your ExpressVPN credentials:"
        read -p "ExpressVPN Username: " VPN_USER
        read -s -p "ExpressVPN Password: " VPN_PASS
        echo ""
        VPN_AUTH_TYPE="userpass"
        ;;
    4)
        VPN_PROVIDER="surfshark"
        VPN_TYPE="openvpn"
        echo ""
        echo "Selected: Surfshark"
        echo "Enter your Surfshark credentials:"
        read -p "Surfshark Username: " VPN_USER
        read -s -p "Surfshark Password: " VPN_PASS
        echo ""
        VPN_AUTH_TYPE="userpass"
        ;;
    5)
        VPN_PROVIDER="mullvad"
        VPN_TYPE="wireguard"
        echo ""
        echo "Selected: Mullvad (WireGuard)"
        echo "Get your WireGuard config from: https://mullvad.net/en/account/#/wireguard-config"
        read -p "WireGuard Private Key: " WG_PRIVATE_KEY
        read -p "WireGuard Addresses (e.g., 10.x.x.x/32): " WG_ADDRESSES
        VPN_AUTH_TYPE="wireguard"
        ;;
    6)
        VPN_PROVIDER="protonvpn"
        VPN_TYPE="openvpn"
        echo ""
        echo "Selected: ProtonVPN"
        echo "Enter your ProtonVPN OpenVPN credentials (not your account credentials!):"
        echo "Get them from: https://account.protonvpn.com/account#openvpn"
        read -p "OpenVPN Username: " VPN_USER
        read -s -p "OpenVPN Password: " VPN_PASS
        echo ""
        VPN_AUTH_TYPE="userpass"
        ;;
    7)
        echo ""
        echo "Selected: Custom Provider"
        echo "See Gluetun documentation for supported providers:"
        echo "https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers"
        read -p "Enter VPN provider name (lowercase): " VPN_PROVIDER
        read -p "Enter VPN type (openvpn/wireguard) [openvpn]: " VPN_TYPE
        VPN_TYPE=${VPN_TYPE:-openvpn}
        read -p "Username (or leave blank): " VPN_USER
        if [ ! -z "$VPN_USER" ]; then
            read -s -p "Password: " VPN_PASS
            echo ""
            VPN_AUTH_TYPE="userpass"
        else
            VPN_AUTH_TYPE="custom"
        fi
        ;;
    *)
        echo -e "${RED}Invalid selection. Defaulting to PIA.${NC}"
        VPN_PROVIDER="private internet access"
        VPN_TYPE="openvpn"
        read -p "PIA Username: " VPN_USER
        read -s -p "PIA Password: " VPN_PASS
        echo ""
        VPN_AUTH_TYPE="userpass"
        ;;
esac

echo ""
echo -e "${BLUE}Step 6: Selecting VPN Server Region...${NC}"
echo "=========================================="

echo "Popular VPN regions:"
if [ "$VPN_PROVIDER" = "private internet access" ]; then
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
elif [ "$VPN_PROVIDER" = "nordvpn" ]; then
    echo "  1) United States"
    echo "  2) United Kingdom"
    echo "  3) Netherlands"
    echo "  4) Canada"
    echo "  5) Custom (enter manually)"
    read -p "Select region [1]: " REGION_CHOICE
    REGION_CHOICE=${REGION_CHOICE:-1}
    
    case $REGION_CHOICE in
        1) VPN_REGION="United States" ;;
        2) VPN_REGION="United Kingdom" ;;
        3) VPN_REGION="Netherlands" ;;
        4) VPN_REGION="Canada" ;;
        5) read -p "Enter region: " VPN_REGION ;;
        *) VPN_REGION="United States" ;;
    esac
else
    read -p "Enter your preferred region/country: " VPN_REGION
fi

echo "Using region: $VPN_REGION"
echo ""

echo -e "${BLUE}Step 7: Configuring system settings...${NC}"
echo "=========================================="

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

# Timezone
read -p "Enter your timezone [America/New_York]: " TIMEZONE
TIMEZONE=${TIMEZONE:-America/New_York}
echo ""

# Plex Claim Token (optional, only if Plex selected)
PLEX_CLAIM=""
if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " plex " ]]; then
    echo "Plex Configuration (optional):"
    echo "To claim your Plex server, get a token from: https://plex.tv/claim"
    read -p "Plex claim token (or press Enter to skip): " PLEX_CLAIM
    echo ""
fi

echo -e "${BLUE}Step 8: Generating docker-compose.yml...${NC}"
echo "=========================================="

# Start building docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: "3.8"

services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - "${QBITTORRENT_PORT:-8080}:8080"
      - "${TORRENT_PORT:-6881}:6881"
      - "${TORRENT_PORT:-6881}:6881/udp"
      - "${RADARR_PORT:-7878}:7878"
      - "${SONARR_PORT:-8989}:8989"
      - "${LIDARR_PORT:-8686}:8686"
      - "${JACKETT_PORT:-9117}:9117"
      - "${PROWLARR_PORT:-9696}:9696"
EOF

# Add optional service ports
if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " readarr " ]]; then
    echo '      - "${READARR_PORT:-8787}:8787"' >> docker-compose.yml
fi
if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " bazarr " ]]; then
    echo '      - "${BAZARR_PORT:-6767}:6767"' >> docker-compose.yml
fi
if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " flaresolverr " ]]; then
    echo '      - "${FLARESOLVERR_PORT:-8191}:8191"' >> docker-compose.yml
fi

# Continue with gluetun environment
cat >> docker-compose.yml << 'EOF'
    environment:
      - VPN_SERVICE_PROVIDER=${VPN_SERVICE_PROVIDER}
      - VPN_TYPE=${VPN_TYPE:-openvpn}
      - OPENVPN_USER=${VPN_USERNAME}
      - OPENVPN_PASSWORD=${VPN_PASSWORD}
      - OPENVPN_ACCESS_TOKEN=${VPN_TOKEN}
      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
      - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
      - SERVER_REGIONS=${VPN_SERVER_REGION}
      - FIREWALL_OUTBOUND_SUBNETS=${LOCAL_NETWORK}
      - FIREWALL_VPN_INPUT_PORTS=${TORRENT_PORT:-6881}
      - TZ=${TZ}
    volumes:
      - ./gluetun:/gluetun
    restart: unless-stopped

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=8080
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
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
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
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
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
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
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
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - AUTO_UPDATE=true
    volumes:
      - ./jackett/config:/config
    depends_on:
      - gluetun
    restart: unless-stopped

  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./prowlarr/config:/config
    depends_on:
      - gluetun
    restart: unless-stopped
EOF

# Add optional services
if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " readarr " ]]; then
    cat >> docker-compose.yml << 'EOF'

  readarr:
    image: lscr.io/linuxserver/readarr:develop
    container_name: readarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./readarr/config:/config
      - ./downloads:/downloads
      - ./media/books:/books
    depends_on:
      - gluetun
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " bazarr " ]]; then
    cat >> docker-compose.yml << 'EOF'

  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./bazarr/config:/config
      - ./media/movies:/movies
      - ./media/tv:/tv
    depends_on:
      - gluetun
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " flaresolverr " ]]; then
    cat >> docker-compose.yml << 'EOF'

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    network_mode: "service:gluetun"
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ}
    depends_on:
      - gluetun
    restart: unless-stopped
EOF
fi

# Add media servers
if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " plex " ]]; then
    cat >> docker-compose.yml << 'EOF'

  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    network_mode: host
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - VERSION=docker
      - PLEX_CLAIM=${PLEX_CLAIM}
    volumes:
      - ./plex/config:/config
      - ./media/tv:/tv
      - ./media/movies:/movies
      - ./media/music:/music
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " emby " ]]; then
    cat >> docker-compose.yml << 'EOF'

  emby:
    image: lscr.io/linuxserver/emby:latest
    container_name: emby
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./emby/config:/config
      - ./media/tv:/data/tvshows
      - ./media/movies:/data/movies
      - ./media/music:/data/music
    ports:
      - "${EMBY_PORT:-8096}:8096"
      - "${EMBY_PORT_HTTPS:-8920}:8920"
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " jellyfin " ]]; then
    cat >> docker-compose.yml << 'EOF'

  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./jellyfin/config:/config
      - ./media/tv:/data/tvshows
      - ./media/movies:/data/movies
      - ./media/music:/data/music
    ports:
      - "${JELLYFIN_PORT:-8096}:8096"
      - "${JELLYFIN_PORT_HTTPS:-8920}:8920"
      - "7359:7359/udp"
      - "1900:1900/udp"
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " channels-dvr " ]]; then
    cat >> docker-compose.yml << 'EOF'

  channels-dvr:
    image: fancybits/channels-dvr:latest
    container_name: channels-dvr
    environment:
      - TZ=${TZ}
    volumes:
      - ./channels-dvr/config:/channels-dvr
      - ./media/recordings:/shares/DVR
    ports:
      - "${CHANNELS_PORT:-8089}:8089"
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " tautulli " ]]; then
    cat >> docker-compose.yml << 'EOF'

  tautulli:
    image: lscr.io/linuxserver/tautulli:latest
    container_name: tautulli
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./tautulli/config:/config
    ports:
      - "${TAUTULLI_PORT:-8181}:8181"
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " overseerr " ]]; then
    cat >> docker-compose.yml << 'EOF'

  overseerr:
    image: lscr.io/linuxserver/overseerr:latest
    container_name: overseerr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./overseerr/config:/config
    ports:
      - "${OVERSEERR_PORT:-5055}:5055"
    restart: unless-stopped
EOF
fi

if [[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " jellyseerr " ]]; then
    cat >> docker-compose.yml << 'EOF'

  jellyseerr:
    image: fallenbagel/jellyseerr:latest
    container_name: jellyseerr
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ}
    volumes:
      - ./jellyseerr/config:/app/config
    ports:
      - "${JELLYSEERR_PORT:-5056}:5055"
    restart: unless-stopped
EOF
fi

echo -e "${GREEN}✓ Created docker-compose.yml${NC}"

# Create .env file
cat > .env << EOF
# VPN Provider Configuration
VPN_SERVICE_PROVIDER=$VPN_PROVIDER
VPN_TYPE=$VPN_TYPE
VPN_SERVER_REGION=$VPN_REGION

EOF

# Add auth credentials
if [ "$VPN_AUTH_TYPE" = "userpass" ]; then
    cat >> .env << EOF
# VPN Credentials
VPN_USERNAME=$VPN_USER
VPN_PASSWORD=$VPN_PASS

EOF
elif [ "$VPN_AUTH_TYPE" = "token" ]; then
    cat >> .env << EOF
# VPN Token
VPN_TOKEN=$VPN_TOKEN

EOF
elif [ "$VPN_AUTH_TYPE" = "wireguard" ]; then
    cat >> .env << EOF
# WireGuard Configuration
WIREGUARD_PRIVATE_KEY=$WG_PRIVATE_KEY
WIREGUARD_ADDRESSES=$WG_ADDRESSES

EOF
fi

# Common settings
cat >> .env << EOF
# Network Configuration
LOCAL_NETWORK=$LOCAL_NET

# User Configuration
PUID=$USER_ID
PGID=$GROUP_ID

# Timezone
TZ=$TIMEZONE

EOF

if [[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " plex " ]]; then
    cat >> .env << EOF
# Plex
PLEX_CLAIM=$PLEX_CLAIM

EOF
fi

# Ports
cat >> .env << EOF
# Ports
QBITTORRENT_PORT=8080
RADARR_PORT=7878
SONARR_PORT=8989
LIDARR_PORT=8686
JACKETT_PORT=9117
PROWLARR_PORT=9696
TORRENT_PORT=6881
EOF

[[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " readarr " ]] && echo "READARR_PORT=8787" >> .env
[[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " bazarr " ]] && echo "BAZARR_PORT=6767" >> .env
[[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " flaresolverr " ]] && echo "FLARESOLVERR_PORT=8191" >> .env
[[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " emby " ]] && echo -e "EMBY_PORT=8096\nEMBY_PORT_HTTPS=8920" >> .env
[[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " jellyfin " ]] && echo -e "JELLYFIN_PORT=8096\nJELLYFIN_PORT_HTTPS=8920" >> .env
[[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " channels-dvr " ]] && echo "CHANNELS_PORT=8089" >> .env
[[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " tautulli " ]] && echo "TAUTULLI_PORT=8181" >> .env
[[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " overseerr " ]] && echo "OVERSEERR_PORT=5055" >> .env
[[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " jellyseerr " ]] && echo "JELLYSEERR_PORT=5056" >> .env

echo -e "${GREEN}✓ Created .env file${NC}"
echo ""

echo -e "${BLUE}Step 9: Creating directories...${NC}"
echo "=========================================="

mkdir -p gluetun qbittorrent/config radarr/config sonarr/config lidarr/config jackett/config prowlarr/config
mkdir -p downloads/{incomplete,complete} media/{movies,tv,music}

for service in "${SELECTED_MEDIA_SERVERS[@]}"; do
    mkdir -p ${service}/config
done

for service in "${SELECTED_OPTIONAL_SERVICES[@]}"; do
    mkdir -p ${service}/config
done

[[ " ${SELECTED_OPTIONAL_SERVICES[@]} " =~ " readarr " ]] && mkdir -p media/books
[[ " ${SELECTED_MEDIA_SERVERS[@]} " =~ " channels-dvr " ]] && mkdir -p media/recordings

chmod -R 755 ./*
echo -e "${GREEN}✓ Created all directories${NC}"
echo ""

echo -e "${BLUE}Step 10: Pulling Docker images...${NC}"
echo "=========================================="
docker compose pull
echo -e "${GREEN}✓ All images downloaded${NC}"
echo ""

echo -e "${BLUE}Step 11: Starting services...${NC}"
echo "=========================================="
docker compose up -d
echo -e "${GREEN}✓ All services started${NC}"
echo ""

echo "Waiting 30 seconds for initialization..."
sleep 30

echo ""
echo -e "${BLUE}Step 12: Checking VPN...${NC}"
echo "=========================================="

if docker ps | grep -q gluetun; then
    echo -e "${GREEN}✓ Gluetun running${NC}"
    sleep 5
    VPN_IP=$(docker exec gluetun wget -qO- ifconfig.me 2>/dev/null || echo "connecting...")
    
    if [ "$VPN_IP" != "connecting..." ]; then
        echo -e "${GREEN}✓ VPN connected! IP: $VPN_IP${NC}"
    else
        echo -e "${YELLOW}⚠ VPN still connecting...${NC}"
    fi
else
    echo -e "${RED}✗ Gluetun failed to start${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=========================================="
echo ""
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Access your services:"
echo "  - qBittorrent:  http://${SERVER_IP}:8080"
echo "  - Radarr:       http://${SERVER_IP}:7878"
echo "  - Sonarr:       http://${SERVER_IP}:8989"
echo "  - Lidarr:       http://${SERVER_IP}:8686"
echo "  - Prowlarr:     http://${SERVER_IP}:9696"

for server in "${SELECTED_MEDIA_SERVERS[@]}"; do
    case $server in
        plex) echo "  - Plex:         http://${SERVER_IP}:32400/web" ;;
        emby) echo "  - Emby:         http://${SERVER_IP}:8096" ;;
        jellyfin) echo "  - Jellyfin:     http://${SERVER_IP}:8096" ;;
        channels-dvr) echo "  - Channels DVR: http://${SERVER_IP}:8089" ;;
    esac
done

for service in "${SELECTED_OPTIONAL_SERVICES[@]}"; do
    case $service in
        readarr) echo "  - Readarr:      http://${SERVER_IP}:8787" ;;
        bazarr) echo "  - Bazarr:       http://${SERVER_IP}:6767" ;;
        tautulli) echo "  - Tautulli:     http://${SERVER_IP}:8181" ;;
        overseerr) echo "  - Overseerr:    http://${SERVER_IP}:5055" ;;
        jellyseerr) echo "  - Jellyseerr:   http://${SERVER_IP}:5056" ;;
    esac
done

echo ""
echo "VPN: $VPN_PROVIDER ($VPN_REGION)"
echo "Install: $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "  1. Change qBittorrent password"
echo "  2. Configure media server libraries"
echo "  3. Set up Prowlarr indexers"
echo "  4. Test kill switch: ./test-killswitch.sh"
echo ""
