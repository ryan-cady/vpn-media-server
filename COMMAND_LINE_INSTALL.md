# Manual Command-Line Installation Guide

This guide walks you through installing the VPN Media Server step-by-step from the command line.

## Prerequisites

- Ubuntu/Debian-based Linux system (or compatible)
- Sudo access
- Internet connection
- PIA VPN subscription

---

## Method 1: Automated Installation (Recommended)

### Quick Install - One Command

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_REPO/install.sh | bash
```

Or download and run locally:

```bash
# Download the install script
wget https://raw.githubusercontent.com/YOUR_REPO/install.sh

# Make it executable
chmod +x install.sh

# Run it
./install.sh
```

The script will:
- Install Docker and Docker Compose if needed
- Create all directories
- Download configuration files
- Ask for your PIA credentials
- Start all services

---

## Method 2: Manual Installation (Step by Step)

### Step 1: Install Docker

```bash
# Update package index
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

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER

# Activate the changes (or log out and back in)
newgrp docker
```

### Step 2: Install Docker Compose (if not included)

```bash
# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker compose version
```

### Step 3: Create Project Directory

```bash
# Create and navigate to project directory
mkdir -p ~/vpn-media-server
cd ~/vpn-media-server
```

### Step 4: Download Configuration Files

**Option A: Download from releases (if available)**

```bash
# Download all files
wget https://github.com/YOUR_REPO/releases/latest/download/vpn-media-server.zip
unzip vpn-media-server.zip
```

**Option B: Create files manually**

Download the following files from the outputs you received earlier:
- docker-compose.yml
- .env.example
- setup.sh
- test-killswitch.sh
- README.md

Place them in `~/vpn-media-server/`

### Step 5: Configure Environment

```bash
# Copy example env file
cp .env.example .env

# Edit with your favorite editor
nano .env
# or
vim .env
```

**Required changes in .env:**

```bash
# Your PIA credentials
PIA_USERNAME=your_pia_username
PIA_PASSWORD=your_pia_password

# Your local network (check with: ip route | grep default)
LOCAL_NETWORK=192.168.1.0/24

# Your user/group ID (check with: id)
PUID=1000
PGID=1000

# Your timezone (check with: timedatectl)
TZ=America/New_York

# VPN region (optional, default is US New York)
VPN_SERVER_REGION=US New York
```

### Step 6: Create Directory Structure

```bash
# Create all required directories
mkdir -p gluetun
mkdir -p qbittorrent/config
mkdir -p radarr/config
mkdir -p sonarr/config
mkdir -p lidarr/config
mkdir -p jackett/config
mkdir -p prowlarr/config
mkdir -p whisparr/config
mkdir -p downloads/{incomplete,complete}
mkdir -p media/{movies,tv,music,adult}

# Set proper permissions
chmod -R 755 ./*
```

### Step 7: Pull Docker Images

```bash
# Download all container images (this may take a while)
docker compose pull
```

### Step 8: Start Services

```bash
# Start all services in detached mode
docker compose up -d
```

### Step 9: Verify Everything is Running

```bash
# Check container status
docker ps

# You should see these containers running:
# - gluetun
# - qbittorrent
# - radarr
# - sonarr
# - lidarr
# - jackett
# - prowlarr
# - whisparr
```

### Step 10: Check VPN Connection

```bash
# View gluetun logs
docker logs gluetun

# Check VPN IP address
docker exec gluetun wget -qO- ifconfig.me

# This should show a PIA IP, NOT your real IP
```

### Step 11: Test Kill Switch

```bash
# Make test script executable
chmod +x test-killswitch.sh

# Run the kill switch test
./test-killswitch.sh
```

---

## Quick Reference Commands

### Container Management

```bash
# View all containers
docker ps

# View all containers (including stopped)
docker ps -a

# View logs for all services
docker compose logs -f

# View logs for specific service
docker logs -f gluetun
docker logs -f qbittorrent

# Restart all services
docker compose restart

# Restart specific service
docker restart gluetun

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Update all containers
docker compose pull
docker compose up -d
```

### Service Access

Get your server's IP:
```bash
hostname -I | awk '{print $1}'
```

Access services (replace YOUR_IP):
- qBittorrent: http://YOUR_IP:8080
- Radarr: http://YOUR_IP:7878
- Sonarr: http://YOUR_IP:8989
- Lidarr: http://YOUR_IP:8686
- Jackett: http://YOUR_IP:9117
- Prowlarr: http://YOUR_IP:9696
- Whisparr: http://YOUR_IP:6969

### VPN Management

```bash
# Check VPN status
docker logs gluetun | grep -i "connected"

# Get current VPN IP
docker exec gluetun wget -qO- ifconfig.me

# Get your real IP (for comparison)
curl ifconfig.me

# Restart VPN
docker restart gluetun

# Change VPN region
# Edit .env file, change VPN_SERVER_REGION, then:
docker compose up -d
```

### Troubleshooting

```bash
# Check why a container failed
docker logs container_name

# Check container resource usage
docker stats

# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune

# Full system cleanup (careful!)
docker system prune -a
```

---

## Post-Installation Setup

### 1. Change qBittorrent Password

```bash
# Access qBittorrent WebUI
# Default credentials: admin / adminadmin
# Go to Tools → Options → Web UI
# Change password immediately!
```

### 2. Configure Prowlarr (Recommended)

```bash
# 1. Access Prowlarr at http://YOUR_IP:9696
# 2. Add indexers
# 3. Go to Settings → Apps
# 4. Add each *arr service:
#    - Get API keys from each app's Settings → General
#    - Use localhost URLs (localhost:7878, localhost:8989, etc.)
# 5. Indexers will auto-sync to all apps!
```

### 3. Configure Download Client in *arr Apps

For each service (Radarr, Sonarr, Lidarr, Whisparr):

```bash
# 1. Access the service WebUI
# 2. Settings → Download Clients → Add → qBittorrent
# 3. Configure:
#    Host: localhost
#    Port: 8080
#    Username: admin
#    Password: (your qBittorrent password)
# 4. Test and Save
```

---

## Advanced Configuration

### Enable Port Forwarding (Better Performance)

Edit docker-compose.yml, add to gluetun environment:
```yaml
- VPN_PORT_FORWARDING=on
```

Then restart:
```bash
docker compose up -d
```

Get forwarded port:
```bash
docker exec gluetun cat /tmp/gluetun/forwarded_port
```

Configure this port in qBittorrent.

### Use WireGuard Instead of OpenVPN

Edit .env:
```bash
VPN_TYPE=wireguard
```

Then restart:
```bash
docker compose up -d
```

### Change VPN Region

Edit .env:
```bash
VPN_SERVER_REGION=US California
# or UK London, or Netherlands, etc.
```

Restart:
```bash
docker compose up -d
```

### Add Firewall Rules (Optional but Recommended)

```bash
# Allow Docker services
sudo ufw allow 8080/tcp  # qBittorrent
sudo ufw allow 7878/tcp  # Radarr
sudo ufw allow 8989/tcp  # Sonarr
sudo ufw allow 8686/tcp  # Lidarr
sudo ufw allow 9117/tcp  # Jackett
sudo ufw allow 9696/tcp  # Prowlarr
sudo ufw allow 6969/tcp  # Whisparr

# Enable firewall
sudo ufw enable
```

---

## Backup and Restore

### Backup Configuration

```bash
cd ~/vpn-media-server

# Backup all configs
tar -czf backup-$(date +%Y%m%d).tar.gz \
    .env \
    qbittorrent/config \
    radarr/config \
    sonarr/config \
    lidarr/config \
    jackett/config \
    prowlarr/config \
    whisparr/config

# Move backup to safe location
mv backup-*.tar.gz ~/backups/
```

### Restore from Backup

```bash
cd ~/vpn-media-server

# Stop services
docker compose down

# Extract backup
tar -xzf ~/backups/backup-20241025.tar.gz

# Start services
docker compose up -d
```

---

## Uninstallation

### Remove Everything

```bash
cd ~/vpn-media-server

# Stop and remove containers
docker compose down

# Remove all data (WARNING: This deletes everything!)
cd ~
rm -rf vpn-media-server

# Remove Docker images (optional)
docker image prune -a

# Remove Docker completely (optional)
sudo apt-get remove docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
```

---

## Getting Help

### Check Logs

```bash
# All services
docker compose logs -f

# Specific service
docker logs -f gluetun
docker logs -f qbittorrent

# Last 50 lines
docker logs --tail 50 gluetun
```

### Verify VPN Protection

```bash
# Test kill switch
./test-killswitch.sh

# Manual test
docker stop gluetun
docker exec qbittorrent wget -qO- ifconfig.me
# Should fail/timeout (good!)

docker start gluetun
```

### Common Issues

**Docker permission denied:**
```bash
sudo usermod -aG docker $USER
newgrp docker
# or log out and back in
```

**VPN won't connect:**
```bash
docker logs gluetun
# Check credentials in .env file
# Try different VPN_SERVER_REGION
```

**Can't access services:**
```bash
# Check containers are running
docker ps

# Check firewall
sudo ufw status

# Verify local network setting in .env
```

---

## System Requirements

- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum, 8GB recommended
- **Disk**: 50GB+ for downloads and media
- **Network**: 10+ Mbps for good performance
- **OS**: Ubuntu 20.04+, Debian 10+, or compatible

---

## Security Checklist

After installation:

- [ ] Changed qBittorrent password
- [ ] Tested kill switch (`./test-killswitch.sh`)
- [ ] Verified VPN IP is different from real IP
- [ ] Set strong passwords on all *arr apps
- [ ] Configured firewall (optional but recommended)
- [ ] Services only accessible on local network
- [ ] Regular backups scheduled

---

**You're all set! Your VPN-protected media server is ready to use.**

For detailed configuration of each service, see the README.md file.
