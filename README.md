# VPN Media Server with Kill Switch

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

A complete, VPN-protected media automation server with **kill switch protection** to prevent IP leaks. Routes all torrent traffic through Private Internet Access VPN.

## 🚀 Quick Start

### One-Line Install

```bash
git clone https://github.com/YOUR_USERNAME/vpn-media-server.git
cd vpn-media-server
chmod +x install.sh && ./install.sh
```

**That's it!** The installer handles everything automatically.

---

## 📦 What's Included

| Service | Port | Purpose |
|---------|------|---------|
| **PIA VPN** | - | Routes all traffic through VPN |
| **Kill Switch** | - | Blocks traffic if VPN disconnects |
| **qBittorrent** | 8080 | Torrent download client |
| **Radarr** | 7878 | Movie management |
| **Sonarr** | 8989 | TV show management |
| **Lidarr** | 8686 | Music management |
| **Jackett** | 9117 | Indexer proxy (optional) |
| **Prowlarr** | 9696 | Modern indexer manager |

---

## 🔒 Security Features

- ✅ **VPN Protection**: All torrent traffic through PIA VPN
- ✅ **Kill Switch**: Automatic traffic blocking if VPN fails
- ✅ **No IP Leaks**: Architecture prevents bypass
- ✅ **Local Access Only**: Services only on your network
- ✅ **Tested Security**: Includes kill switch test script

---

## ⚡ Installation Methods

### Method 1: Automated (Recommended)
```bash
./install.sh
```
- Installs Docker if needed
- Asks for your PIA credentials
- Creates all directories
- Starts all services
- **Time: ~10 minutes**

### Method 2: Quick Manual
```bash
cp .env.example .env
nano .env  # Add PIA credentials
mkdir -p {gluetun,qbittorrent,radarr,sonarr,lidarr,jackett,prowlarr}/config
mkdir -p downloads media/{movies,tv,music,adult}
docker compose up -d
```
- For users with Docker already installed
- **Time: ~5 minutes**

---

## 🔧 Prerequisites

- Linux server (Ubuntu/Debian recommended)
- Docker & Docker Compose
- PIA VPN subscription
- 4GB+ RAM recommended
- 50GB+ disk space

The installer will handle Docker installation automatically.

---

## 🎯 Quick Commands

```bash
# View status
docker ps

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Update everything
docker compose pull && docker compose up -d

# Test kill switch
./test-killswitch.sh

# Check VPN IP
docker exec gluetun wget -qO- ifconfig.me
```

---

## 📊 System Architecture

```
Your Computer → Local Network → Docker Server
                                     ↓
                                [Gluetun VPN]
                                     ↓
                        ┌────────────┴────────────┐
                        ↓                         ↓
                   Kill Switch              All Services
                        ↓                         ↓
                  [PIA VPN] ←─── qBittorrent ────┘
                        ↓         Radarr
                   Internet       Sonarr
                                 Lidarr
                                 Jackett
                                 Prowlarr
```

All services share the VPN connection. If VPN fails, kill switch blocks all traffic.

---

## 🛡️ Security Verification

After installation, test the kill switch:

```bash
./test-killswitch.sh
```

This script will:
1. Verify VPN is connected
2. Stop the VPN temporarily
3. Confirm no traffic leaks (should timeout)
4. Restart VPN
5. Verify reconnection

**Expected result**: `✓✓✓ KILL SWITCH IS WORKING! ✓✓✓`

---

## 🌐 Access Services

After installation, access services at:

```
http://YOUR_SERVER_IP:8080  # qBittorrent (admin/adminadmin)
http://YOUR_SERVER_IP:7878  # Radarr
http://YOUR_SERVER_IP:8989  # Sonarr
http://YOUR_SERVER_IP:8686  # Lidarr
http://YOUR_SERVER_IP:9117  # Jackett
http://YOUR_SERVER_IP:9696  # Prowlarr
```

⚠️ **Change qBittorrent password immediately!**

---

## 🔄 Updates

Keep your system updated:

```bash
cd ~/vpn-media-server
git pull                    # Update configs
docker compose pull         # Update images
docker compose up -d       # Restart with updates
```

---

## 🐛 Troubleshooting

### VPN Won't Connect
```bash
docker logs gluetun
# Check PIA credentials in .env
# Try different VPN region
```

### Can't Access Services
```bash
docker ps              # Check containers running
hostname -I           # Get your server IP
sudo ufw status       # Check firewall
```

### Traffic Leaking
```bash
./test-killswitch.sh  # Verify kill switch
# Should show: KILL SWITCH IS WORKING
```

### Container Failed
```bash
docker logs [container_name]  # Check error messages
docker compose restart        # Try restarting
```

---

## 📋 Configuration

### Basic Configuration

Edit `.env` file:

```bash
PIA_USERNAME=your_username
PIA_PASSWORD=your_password
LOCAL_NETWORK=192.168.1.0/24
VPN_SERVER_REGION=US New York
TZ=America/New_York
```

### Advanced Options

- **Port Forwarding**: Better torrent performance
- **WireGuard**: Faster than OpenVPN
- **Multiple Regions**: Automatic failover
- **Custom Indexers**: Via Prowlarr/Jackett

See [README.md](README.md) for details.

---

## 🤝 Contributing

This is a personal setup, but feel free to:
- Fork for your own use
- Submit issues for bugs
- Suggest improvements
- Share your configurations

---

## ⚠️ Important Notes

### Security
- **Never commit `.env` file** to Git (contains passwords!)
- **Change default passwords** on all services
- **Test kill switch** regularly
- **Keep containers updated** monthly

### Legal
- This tool is for legal content only
- Respect copyright laws in your jurisdiction
- VPN use may be restricted in some countries
- Private Internet Access subscription required

### Privacy
- All torrent traffic goes through VPN
- Your real IP is never exposed
- Kill switch prevents accidental leaks
- Services only accessible on local network

---

## 📄 License

This configuration is provided as-is for personal use. Individual components (Docker images) have their own licenses.

---

## 🙏 Credits

Built using:
- [Gluetun](https://github.com/qdm12/gluetun) - VPN client with kill switch
- [LinuxServer.io](https://www.linuxserver.io/) - Docker images
- [Private Internet Access](https://www.privateinternetaccess.com/) - VPN service
- [qBittorrent](https://www.qbittorrent.org/) - Torrent client
- [Radarr](https://radarr.video/) - Movie management
- [Sonarr](https://sonarr.tv/) - TV management
- [Lidarr](https://lidarr.audio/) - Music management
- [Prowlarr](https://prowlarr.com/) - Indexer manager
- [Jackett](https://github.com/Jackett/Jackett) - Indexer proxy

---

## 📞 Support

### Documentation
- All guides in repository .md files
- Start with [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)

### Common Issues
- Check logs: `docker compose logs -f`
- Test VPN: `docker exec gluetun wget -qO- ifconfig.me`
- Verify kill switch: `./test-killswitch.sh`

### Still Stuck?
- Check container logs
- Verify network settings
- Ensure PIA credentials are correct
- Try different VPN region

---

## 🎉 Getting Started

1. **Clone this repository**
2. **Run the installer**: `./install.sh`
3. **Change passwords** on all services
4. **Test kill switch**: `./test-killswitch.sh`
5. **Configure Prowlarr** with indexers
6. **Start adding content!**

---

**Ready to begin?** → [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)

---

Made with ❤️ for secure, automated media management
