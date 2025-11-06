# VPN Media Server with Multiple Streaming Options

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Plex](https://img.shields.io/badge/plex-%23E5A00D.svg?style=for-the-badge&logo=plex&logoColor=white)

A **complete, customizable, VPN-protected media automation server** with your choice of Plex, Emby, Jellyfin, or Channels DVR for streaming, plus **kill switch protection** to prevent IP leaks. Routes all torrent traffic through your VPN provider while keeping media streaming fast and direct.

## ✨ What Makes This Special

- 🎯 **Interactive Installer**: Choose exactly what you want to install
- 🔒 **VPN Kill Switch**: Prevents IP leaks if VPN disconnects
- 📺 **Multiple Media Servers**: Plex, Emby, Jellyfin, AND/OR Channels DVR
- 🌐 **Multi-VPN Support**: Works with 7+ VPN providers
- 🎬 **Complete Automation**: Movies, TV, music, books all automated
- ⚡ **Optimized Performance**: Media streaming bypasses VPN for speed
- 🛠️ **Modular Design**: Install only what you need

## 🚀 Quick Start

### One Command Installation

```bash
git clone https://github.com/YOUR_USERNAME/vpn-media-server.git
cd vpn-media-server
chmod +x install.sh && ./install.sh
```

The installer will guide you through selecting:
- Which media server(s) to install
- Which optional services you want
- Your VPN provider
- Network configuration

**Installation time: 10-15 minutes**

---

## 📦 Services Available

### Core Services (Always Installed)

| Service | Port | Purpose | VPN Routed |
|---------|------|---------|------------|
| **Gluetun VPN** | - | VPN client with kill switch | - |
| **qBittorrent** | 8080 | Torrent download client | ✅ Yes |
| **Radarr** | 7878 | Movie management & automation | ✅ Yes |
| **Sonarr** | 8989 | TV show management & automation | ✅ Yes |
| **Lidarr** | 8686 | Music management & automation | ✅ Yes |
| **Prowlarr** | 9696 | Modern indexer manager | ✅ Yes |
| **Jackett** | 9117 | Alternative indexer proxy | ✅ Yes |

### Media Servers (Choose During Install)

| Service | Port | Purpose | VPN Routed | Best For |
|---------|------|---------|------------|----------|
| **Plex** | 32400 | Media streaming server | ❌ No | Easiest setup, best apps |
| **Emby** | 8096 | Alternative media server | ❌ No | More privacy, customizable |
| **Jellyfin** | 8096 | Open-source media server | ❌ No | 100% free, no tracking |
| **Channels DVR** | 8089 | Live TV & DVR | ❌ No | TV tuners, live TV |

### Optional Services (Choose During Install)

| Service | Port | Purpose | VPN Routed |
|---------|------|---------|------------|
| **Readarr** | 8787 | Book/audiobook management | ✅ Yes |
| **Bazarr** | 6767 | Automatic subtitle downloads | ✅ Yes |
| **FlareSolverr** | 8191 | Cloudflare bypass for indexers | ✅ Yes |
| **Tautulli** | 8181 | Plex monitoring & statistics | ❌ No |
| **Overseerr** | 5055 | Plex request management | ❌ No |
| **Jellyseerr** | 5056 | Jellyfin request management | ❌ No |

**Note:** Media servers and companion tools run outside VPN for optimal streaming performance and device discovery.

---

## 🌐 Supported VPN Providers

The installer supports these VPN providers with guided setup:

| Provider | Auth Type | Tested |
|----------|-----------|--------|
| **Private Internet Access (PIA)** | Username/Password | ⭐⭐⭐ |
| **NordVPN** | Access Token | ⭐⭐⭐ |
| **ExpressVPN** | Username/Password | ⭐⭐ |
| **Surfshark** | Username/Password | ⭐⭐ |
| **Mullvad** | WireGuard Config | ⭐⭐ |
| **ProtonVPN** | OpenVPN Credentials | ⭐⭐ |
| **Custom** | Various | - |

Don't see yours? Gluetun supports **50+ VPN providers** - select "Custom" during installation.

---

## 🔒 Security Features

- ✅ **VPN Protection**: All torrent traffic through your chosen VPN
- ✅ **Kill Switch**: Automatic traffic blocking if VPN fails
- ✅ **No IP Leaks**: Architecture prevents bypass
- ✅ **Tested Security**: Includes kill switch test script
- ✅ **Split Tunneling**: Media servers accessible without VPN for fast streaming
- ✅ **Local Network Access**: Services only accessible on your network
- ✅ **Container Isolation**: Each service in its own Docker container

---

## 📊 System Architecture

```
                    Users / Mobile Devices / Smart TVs
                                │
                                │ (Local Network)
                                ▼
                    ┌───────────────────────┐
                    │   Your Docker Server  │
                    └───────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
    [Media Servers: Direct]         [Gluetun VPN Container]
    - Plex/Emby/Jellyfin                      │
    - Channels DVR                    ┌───────┴───────┐
    - Tautulli                        │               │
    - Overseerr/Jellyseerr      Kill Switch    All Torrent
                                      │          Services
                                 [VPN Tunnel]      │
                                      │            │
                                  Internet    - qBittorrent
                                             - Radarr
                                             - Sonarr
                                             - Lidarr
                                             - Readarr
                                             - Bazarr
                                             - Prowlarr
                                             - Jackett
                                             - FlareSolverr

```

**Key Points:**
- All torrenting services share the VPN connection
- If VPN fails, kill switch blocks ALL torrent traffic
- Media servers run outside VPN for best streaming performance
- All services access the same media folders

---

## 🎬 Media Server Comparison

### Which Media Server Should You Choose?

| Feature | Plex | Emby | Jellyfin | Channels DVR |
|---------|------|------|----------|--------------|
| **Setup Difficulty** | ⭐⭐⭐⭐⭐ Easiest | ⭐⭐⭐⭐ Easy | ⭐⭐⭐ Moderate | ⭐⭐⭐⭐ Easy |
| **Mobile Apps** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐ Good | ⭐⭐⭐ Good | ⭐⭐⭐ Good |
| **Smart TV Support** | ⭐⭐⭐⭐⭐ Best | ⭐⭐⭐⭐ Great | ⭐⭐⭐ Good | ⭐⭐⭐ Good |
| **Privacy** | ⭐⭐ Requires account | ⭐⭐⭐⭐ Better | ⭐⭐⭐⭐⭐ Best | ⭐⭐⭐ Good |
| **Cost** | Free + $5/mo | Free + $54/yr | 100% Free | Paid only |
| **Transcoding** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐ Very Good | ⭐⭐⭐ Good |
| **Live TV/DVR** | Plex Pass | Premiere | Built-in | ⭐⭐⭐⭐⭐ Best |
| **Community** | ⭐⭐⭐⭐⭐ Largest | ⭐⭐⭐ Growing | ⭐⭐⭐⭐ Active | ⭐⭐⭐ Niche |
| **Content Discovery** | ⭐⭐⭐⭐⭐ Best | ⭐⭐⭐⭐ Good | ⭐⭐⭐ Basic | ⭐⭐ Limited |
| **Customization** | ⭐⭐⭐ Limited | ⭐⭐⭐⭐ Good | ⭐⭐⭐⭐⭐ Extensive | ⭐⭐ Limited |

### Recommendations:

- **Choose Plex if**: You want the easiest setup and best mobile/TV apps
- **Choose Emby if**: You want more privacy and customization than Plex
- **Choose Jellyfin if**: You want 100% free and open source
- **Choose Channels DVR if**: You primarily watch live TV and recordings
- **Install Multiple**: They're lightweight and all use the same media files!

---

## ⚡ Installation Guide

### Prerequisites

- Linux server (Ubuntu 20.04+ or Debian 10+ recommended)
- Sudo/root access
- VPN subscription (any supported provider)
- **Hardware Requirements:**
  - CPU: 2+ cores recommended
  - RAM: 4GB minimum, 8GB+ recommended for multiple media servers
  - Storage: 100GB+ (more for large media libraries)
  - (Optional) GPU for hardware transcoding

### Method 1: Interactive Installer (Recommended)

```bash
git clone https://github.com/YOUR_USERNAME/vpn-media-server.git
cd vpn-media-server
chmod +x install.sh
./install.sh
```

The installer will:
1. Install Docker if needed
2. Ask which media servers to install
3. Ask which optional services to install
4. Guide you through VPN provider selection
5. Configure network settings
6. Create all necessary directories
7. Start all selected services
8. Verify VPN connection

### Method 2: Manual Installation

```bash
# Create directory
mkdir ~/vpn-media-server && cd ~/vpn-media-server

# Copy docker-compose-full.yml
cp docker-compose-full.yml docker-compose.yml

# Remove unwanted services from docker-compose.yml
nano docker-compose.yml

# Create .env file
nano .env
# Add your VPN credentials and settings

# Create directories
mkdir -p {gluetun,qbittorrent,radarr,sonarr,lidarr,prowlarr,jackett}/config
mkdir -p downloads media/{movies,tv,music}

# Start services
docker compose up -d
```

---

## 🛡️ Security Testing

After installation, **test the kill switch**:

```bash
cd ~/vpn-media-server
./test-killswitch.sh
```

**Expected output:**
```
✔✔✔ KILL SWITCH IS WORKING! ✔✔✔
```

This confirms:
- VPN is connected
- Traffic is routed through VPN
- No leaks occur when VPN disconnects

**Run this test monthly** to ensure ongoing protection.

---

## 🎯 Post-Installation Setup

### 1. Secure qBittorrent

```
1. Go to http://YOUR_IP:8080
2. Login: admin / adminadmin
3. Tools → Options → Web UI → Authentication
4. Change password immediately!
5. Set download paths:
   - Default Save Path: /downloads/complete
   - Keep incomplete torrents in: /downloads/incomplete
```

### 2. Set Up Your Media Server(s)

#### Plex
```
1. Go to http://YOUR_IP:32400/web
2. Sign in with Plex account (or create one)
3. Claim your server (use token from plex.tv/claim if provided)
4. Add libraries:
   - Movies: /movies
   - TV Shows: /tv
   - Music: /music
5. Settings → Server → Transcoder → Configure hardware transcoding (if available)
```

#### Emby
```
1. Go to http://YOUR_IP:8096
2. Complete initial setup wizard
3. Create admin account
4. Add libraries:
   - Movies: /data/movies
   - TV Shows: /data/tvshows
   - Music: /data/music
5. Dashboard → Playback → Configure transcoding
```

#### Jellyfin
```
1. Go to http://YOUR_IP:8096
2. Complete initial setup wizard
3. Create admin account
4. Add libraries:
   - Movies: /data/movies
   - TV Shows: /data/tvshows
   - Music: /data/music
5. Dashboard → Playback → Configure transcoding and hardware acceleration
```

#### Channels DVR
```
1. Go to http://YOUR_IP:8089
2. Complete setup wizard
3. Add TV sources (HDHomeRun, cable boxes, etc.)
4. Configure recording settings
5. DVR recordings will be saved to /shares/DVR
```

### 3. Configure Prowlarr (Indexer Manager)

```
1. Go to http://YOUR_IP:9696
2. Complete initial setup
3. Add indexers:
   - Click "Add Indexer"
   - Search for popular indexers (1337x, RARBG, etc.)
   - Add your preferred indexers
4. Settings → Apps:
   - Add Radarr (http://gluetun:7878)
   - Add Sonarr (http://gluetun:8989)
   - Add Lidarr (http://gluetun:8686)
   - Add Readarr (http://gluetun:8787) if installed
5. Sync indexers to all apps
```

### 4. Connect *arr Apps to qBittorrent

In each *arr app (Radarr, Sonarr, Lidarr, Readarr):

```
1. Settings → Download Clients
2. Add → qBittorrent
3. Configure:
   - Name: qBittorrent
   - Host: gluetun (NOT localhost!)
   - Port: 8080
   - Username: admin
   - Password: [your new password]
4. Test and Save
```

### 5. Configure Media Paths

In each *arr app:

```
Settings → Media Management → Root Folders:
- Radarr: /movies
- Sonarr: /tv
- Lidarr: /music
- Readarr: /books
```

### 6. Optional: Set Up Request Management

#### Overseerr (for Plex)
```
1. Go to http://YOUR_IP:5055
2. Sign in with Plex account
3. Connect to Plex server
4. Add Radarr and Sonarr
5. Configure request rules
```

#### Jellyseerr (for Jellyfin)
```
1. Go to http://YOUR_IP:5056
2. Complete setup wizard
3. Connect to Jellyfin server
4. Add Radarr and Sonarr
5. Configure request rules
```

---

## 🔄 Daily Usage

### Adding Content

**Method 1: Direct in *arr Apps**
```
1. Go to Radarr/Sonarr
2. Click "Add Movie" or "Add Series"
3. Search for title
4. Select quality profile
5. Click "Add"
6. Wait for automatic download
7. Watch in your media server when complete
```

**Method 2: Through Request System**
```
1. Users go to Overseerr or Jellyseerr
2. Search for movie/show
3. Click "Request"
4. Automatically added to Radarr/Sonarr
5. Downloads and appears in media server
```

### Monitoring

```bash
# View all containers
docker ps

# View logs for all services
docker compose logs -f

# View specific service logs
docker logs gluetun
docker logs radarr
docker logs plex

# Check VPN IP
docker exec gluetun wget -qO- ifconfig.me

# Check VPN status
docker logs gluetun | tail -20
```

---

## 🔧 Maintenance

### Updates

```bash
cd ~/vpn-media-server

# Pull latest images
docker compose pull

# Restart with updates
docker compose up -d

# View logs to check for issues
docker compose logs -f
```

**Recommendation**: Update monthly

### Backups

**What to backup:**
```
~/vpn-media-server/
├── .env                    # VPN credentials and settings
├── docker-compose.yml      # Service configuration
├── */config/              # All service configurations
└── media/                 # Your media files (large!)
```

**Backup script:**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf ~/backup-vpn-media-$DATE.tar.gz \
  ~/vpn-media-server/.env \
  ~/vpn-media-server/docker-compose.yml \
  ~/vpn-media-server/*/config/

# Optional: backup media (very large!)
# rsync -av ~/vpn-media-server/media/ /backup/media/
```

### Troubleshooting

#### VPN Won't Connect
```bash
# Check credentials
cat .env | grep VPN

# Check gluetun logs
docker logs gluetun -f

# Try different region
nano .env  # Change VPN_SERVER_REGION
docker compose restart gluetun
```

#### Can't Access Services
```bash
# Check containers running
docker ps

# Get server IP
hostname -I

# Check firewall
sudo ufw status
sudo ufw allow 8080  # Example for qBittorrent
```

#### Downloads Not Starting
```bash
# Check qBittorrent
docker logs qbittorrent

# Check *arr apps can reach qBittorrent
# In *arr app → Settings → Download Clients → Test

# Verify host is set to "gluetun" not "localhost"
```

#### Media Server Not Finding Files
```bash
# Check permissions
ls -la ~/vpn-media-server/media/

# Fix permissions
cd ~/vpn-media-server
chmod -R 755 media/
chown -R $USER:$USER media/

# Scan libraries in media server
```

---

## 📋 Configuration Reference

### Environment Variables (.env)

```bash
# VPN Configuration
VPN_SERVICE_PROVIDER=private internet access
VPN_TYPE=openvpn
VPN_USERNAME=your_username
VPN_PASSWORD=your_password
VPN_SERVER_REGION=US New York

# Network
LOCAL_NETWORK=192.168.1.0/24

# User/Group IDs
PUID=1000
PGID=1000

# Timezone
TZ=America/New_York

# Plex (optional)
PLEX_CLAIM=claim-xxxxx

# Ports (customizable)
QBITTORRENT_PORT=8080
RADARR_PORT=7878
SONARR_PORT=8989
# ... etc
```

### Port Forwarding (Optional)

For better torrent performance:

```bash
# In .env, add:
VPN_PORT_FORWARDING=on
```

Then configure the forwarded port in qBittorrent.

### Hardware Transcoding

For Plex/Emby/Jellyfin with GPU:

```yaml
# Add to media server service in docker-compose.yml:
devices:
  - /dev/dri:/dev/dri  # Intel/AMD GPU
# or
  - /dev/nvidia0:/dev/nvidia0  # NVIDIA GPU (requires nvidia-docker)
```

---

## 🤝 Contributing

This is a personal project, but feel free to:
- Fork for your own use
- Submit issues for bugs
- Suggest improvements
- Share your configurations

---

## ⚠️ Important Legal & Security Notes

### Legal
- This tool is for **legal content only**
- Respect copyright laws in your jurisdiction
- VPN use may be restricted in some countries
- You are responsible for your content usage
- VPN subscription required

### Security
- **Never commit `.env` file** to Git (contains passwords!)
- **Change ALL default passwords** immediately
- **Test kill switch regularly** (monthly recommended)
- **Keep containers updated** (monthly recommended)
- **Use strong passwords** on all services
- **Limit network access** (firewall, VPN, etc.)

### Privacy
- All torrent traffic goes through VPN
- Your real IP is never exposed to torrent peers
- Kill switch prevents accidental leaks
- Media streaming is NOT through VPN (by design for performance)
- Consider: Privacy modes in media servers

---

## 📖 Additional Documentation

- **[QUICK_INSTALL.md](QUICK_INSTALL.md)** - TL;DR installation guide
- **test-killswitch.sh** - VPN kill switch test script
- **docker-compose-full.yml** - Complete service reference

---

## 🙏 Credits

This project uses excellent open-source software:

- [Gluetun](https://github.com/qdm12/gluetun) - VPN client with kill switch
- [LinuxServer.io](https://www.linuxserver.io/) - Docker images
- [Plex](https://www.plex.tv/) - Media streaming server
- [Emby](https://emby.media/) - Media streaming server
- [Jellyfin](https://jellyfin.org/) - Open-source media server
- [Channels DVR](https://getchannels.com/) - Live TV & DVR
- [qBittorrent](https://www.qbittorrent.org/) - Torrent client
- [Radarr](https://radarr.video/) - Movie management
- [Sonarr](https://sonarr.tv/) - TV management
- [Lidarr](https://lidarr.audio/) - Music management
- [Readarr](https://readarr.com/) - Book management
- [Prowlarr](https://prowlarr.com/) - Indexer manager
- [Bazarr](https://www.bazarr.media/) - Subtitle management
- [Overseerr](https://overseerr.dev/) - Request management for Plex
- [Jellyseerr](https://github.com/Fallenbagel/jellyseerr) - Request management for Jellyfin
- [Tautulli](https://tautulli.com/) - Plex monitoring

---

## 📞 Support

### Documentation
- Start with [QUICK_INSTALL.md](QUICK_INSTALL.md) for quickstart
- This README for comprehensive information
- Check service-specific documentation for detailed configs

### Common Issues
- Check `docker compose logs -f` for errors
- Test VPN: `docker exec gluetun wget -qO- ifconfig.me`
- Verify kill switch: `./test-killswitch.sh`
- Check network: `hostname -I` and `sudo ufw status`

### Still Stuck?
1. Check container logs: `docker logs [container-name]`
2. Verify credentials in `.env`
3. Ensure VPN subscription is active
4. Try different VPN region/server
5. Check available disk space: `df -h`
6. Verify ports aren't in use: `sudo netstat -tulpn`

---

## 🎉 Getting Started Checklist

- [ ] Clone repository
- [ ] Run `./install.sh`
- [ ] Choose media server(s)
- [ ] Choose optional services
- [ ] Select VPN provider
- [ ] Enter VPN credentials
- [ ] Wait for installation
- [ ] Test kill switch: `./test-killswitch.sh`
- [ ] Change qBittorrent password
- [ ] Set up media server libraries
- [ ] Configure Prowlarr indexers
- [ ] Connect *arr apps to qBittorrent
- [ ] Test by adding a movie/show
- [ ] Set up request management (optional)
- [ ] Configure transcoding (optional)
- [ ] Enjoy automated media!

---

**Ready to begin?** → [QUICK_INSTALL.md](QUICK_INSTALL.md)

---

Made with ❤️ for automated, secure, private media management

**Questions?** Check the [Wiki](../../wiki) | **Issues?** Open an [Issue](../../issues)
