# Quick Install - TL;DR

## The Fastest Way to Install

### 1. Download and run the automated installer:

```bash
mkdir ~/vpn-media-server && cd ~/vpn-media-server
chmod +x install.sh
./install.sh
```

The installer is **fully interactive** and will guide you through:
- ✅ Installing Docker & Docker Compose automatically
- ✅ Choosing which media servers to install (Plex, Emby, Jellyfin, Channels DVR)
- ✅ Choosing optional services (Readarr, Bazarr, Tautulli, Overseerr, Jellyseerr, FlareSolverr)
- ✅ Selecting your VPN provider (PIA, NordVPN, ExpressVPN, Surfshark, Mullvad, ProtonVPN, or custom)
- ✅ Entering your VPN credentials
- ✅ Detecting your network settings
- ✅ Creating only the directories you need
- ✅ Starting your selected services
- ✅ Verifying VPN connection

**Time to complete: ~10-15 minutes**

---

## 📺 Media Servers (Choose One or More)

During installation, you'll be asked which media servers to install:

| Server | Best For | Free/Paid |
|--------|----------|-----------|
| **Plex** | Best apps, largest community, easiest setup | Free + Plex Pass ($5/mo optional) |
| **Emby** | More privacy, no required account | Free + Premiere ($54/year optional) |
| **Jellyfin** | 100% free & open source, no tracking | Completely free |
| **Channels DVR** | Live TV & DVR recording | Paid subscription |

**You can install multiple or none!** All selected servers will access the same media files.

---

## 🎯 Optional Services (Pick What You Need)

| Service | Purpose | When to Use |
|---------|---------|-------------|
| **Readarr** | Book & audiobook management | If you want ebooks/audiobooks |
| **Bazarr** | Automatic subtitle downloads | If you need subtitles |
| **FlareSolverr** | Bypass Cloudflare on indexers | If indexers get blocked |
| **Tautulli** | Plex monitoring & statistics | If you installed Plex |
| **Overseerr** | User requests for Plex | If you want request management for Plex |
| **Jellyseerr** | User requests for Jellyfin | If you want request management for Jellyfin |

The installer will only ask about relevant services (e.g., Tautulli only appears if you chose Plex).

---

## 🌐 Supported VPN Providers

Choose your provider during installation:

1. **Private Internet Access (PIA)** ⭐ Most tested
2. **NordVPN** - Token-based authentication
3. **ExpressVPN** - Username/Password
4. **Surfshark** - Username/Password
5. **Mullvad** - WireGuard configuration
6. **ProtonVPN** - OpenVPN credentials
7. **Custom** - Any Gluetun-supported provider (50+ options)

---

## 📦 What's ALWAYS Installed

These core services are included automatically:

- **Gluetun VPN** - Routes torrent traffic through VPN
- **Kill Switch** - Blocks traffic if VPN fails
- **qBittorrent** - Torrent client
- **Radarr** - Movie management
- **Sonarr** - TV show management  
- **Lidarr** - Music management
- **Prowlarr** - Indexer manager (recommended)
- **Jackett** - Alternative indexer proxy

---

## Access Services After Install

Replace `YOUR_IP` with your server's IP (find with: `hostname -I`)

### Core Services (Always Installed)

| Service | URL | VPN Protected |
|---------|-----|---------------|
| qBittorrent | http://YOUR_IP:8080 | ✅ Yes |
| Radarr | http://YOUR_IP:7878 | ✅ Yes |
| Sonarr | http://YOUR_IP:8989 | ✅ Yes |
| Lidarr | http://YOUR_IP:8686 | ✅ Yes |
| Prowlarr | http://YOUR_IP:9696 | ✅ Yes |
| Jackett | http://YOUR_IP:9117 | ✅ Yes |

### Media Servers (If Installed)

| Service | URL | VPN Protected |
|---------|-----|---------------|
| Plex | http://YOUR_IP:32400/web | ❌ No (Direct) |
| Emby | http://YOUR_IP:8096 | ❌ No (Direct) |
| Jellyfin | http://YOUR_IP:8096 | ❌ No (Direct) |
| Channels DVR | http://YOUR_IP:8089 | ❌ No (Direct) |

### Optional Services (If Installed)

| Service | URL | VPN Protected |
|---------|-----|---------------|
| Readarr | http://YOUR_IP:8787 | ✅ Yes |
| Bazarr | http://YOUR_IP:6767 | ✅ Yes |
| Tautulli | http://YOUR_IP:8181 | ❌ No |
| Overseerr | http://YOUR_IP:5055 | ❌ No |
| Jellyseerr | http://YOUR_IP:5056 | ❌ No |

**Note:** Media servers and monitoring tools run outside VPN for best performance. Only torrenting is VPN-protected.

---

## Essential Commands

```bash
# View status
docker ps

# View logs
docker compose logs -f

# Restart everything
docker compose restart

# Stop everything
docker compose down

# Update everything
docker compose pull && docker compose up -d

# Test VPN/kill switch
./test-killswitch.sh

# Check VPN IP
docker exec gluetun wget -qO- ifconfig.me
```

---

## First Steps After Install

1. **Test Security**:
   ```bash
   ./test-killswitch.sh
   ```
   Should show: `✔✔✔ KILL SWITCH IS WORKING! ✔✔✔`

2. **Change qBittorrent password**:
   - Login at http://YOUR_IP:8080 (admin/adminadmin)
   - Tools → Options → Web UI → Change password

3. **Set up your media server(s)**:
   - **Plex**: Go to http://YOUR_IP:32400/web → Add libraries
   - **Emby**: Go to http://YOUR_IP:8096 → Complete setup wizard
   - **Jellyfin**: Go to http://YOUR_IP:8096 → Complete setup wizard
   - **Channels DVR**: Go to http://YOUR_IP:8089 → Add TV sources

4. **Configure Prowlarr**:
   - Go to http://YOUR_IP:9696
   - Add indexers (search for popular ones)
   - Settings → Apps → Add Radarr, Sonarr, Lidarr, Readarr (if installed)

5. **Connect apps to qBittorrent**:
   - In each *arr app: Settings → Download Clients → Add qBittorrent
   - Host: `gluetun` (NOT localhost!)
   - Port: `8080`

6. **Test with a movie**:
   - Add a movie in Radarr
   - Watch it download in qBittorrent
   - See it appear in your media server

---

## VPN Provider Setup Notes

### Private Internet Access (PIA)
- Use your PIA username and password directly
- Any region works

### NordVPN
- Get token from: https://my.nordaccount.com/dashboard/nordvpn/
- Go to: Services → NordVPN → Manual Setup → Generate Token

### ExpressVPN
- Use service credentials (not your account email)
- Find in your account dashboard

### Surfshark
- Use Surfshark service credentials
- Available in account dashboard

### Mullvad
- Get WireGuard config from: https://mullvad.net/en/account/#/wireguard-config
- Need: Private Key and IP Address

### ProtonVPN
- Use OpenVPN credentials (NOT your account login!)
- Get from: https://account.protonvpn.com/account#openvpn

---

## Media Server Comparison

### Plex
**Pros:**
- 🎯 Easiest to set up
- 📱 Best mobile apps
- 📺 Best smart TV support
- 👥 Largest community
- 🎬 Great content discovery

**Cons:**
- 🔐 Requires Plex account
- 💰 Some features need Plex Pass ($5/mo)

### Emby
**Pros:**
- 🔒 More privacy-focused
- 💾 Better offline access
- 🎨 More customizable
- 💵 One-time purchase option

**Cons:**
- 📱 Smaller app ecosystem
- 👥 Smaller community

### Jellyfin
**Pros:**
- 🆓 Completely free forever
- 🔓 100% open source
- 🔒 No accounts or tracking
- 🛠️ Very customizable

**Cons:**
- 📱 Fewer app options
- 🎨 Less polished UI
- 👥 Smaller community

### Channels DVR
**Pros:**
- 📡 Best for live TV
- 📼 Professional DVR features
- 📺 Works with TV tuners

**Cons:**
- 💰 Requires subscription
- 🎯 Focused only on TV

**Pro Tip:** You can run multiple! They all use the same media files.

---

## Troubleshooting

### Installation Issues
```bash
# Check Docker
docker --version
docker compose version

# Check if containers are running
docker ps

# View specific service logs
docker logs gluetun
docker logs plex
```

### VPN Won't Connect
```bash
# Check credentials in .env file
cat .env | grep VPN

# View gluetun logs
docker logs gluetun -f

# Try different region
# Edit .env and change VPN_SERVER_REGION
nano .env
docker compose restart gluetun
```

### Can't Access Services
```bash
# Get your server IP
hostname -I

# Check if ports are in use
sudo netstat -tulpn | grep :8080
sudo netstat -tulpn | grep :32400

# Check firewall
sudo ufw status
```

### Kill Switch Not Working
```bash
# Run test
./test-killswitch.sh

# If it fails, check LOCAL_NETWORK setting
nano .env
# Change LOCAL_NETWORK to match your network
# Example: 192.168.1.0/24 or 10.0.0.0/24
```

---

## Adding Services Later

Want to add a service you didn't install initially?

1. **Edit docker-compose.yml** and add the service from docker-compose-full.yml
2. **Edit .env** and add any needed ports
3. **Create config directory**: `mkdir -p service-name/config`
4. **Pull and start**: `docker compose pull && docker compose up -d`

Or just re-run the installer - it will detect existing services.

---

## Port Reference

| Service | Port | Protocol |
|---------|------|----------|
| qBittorrent | 8080 | HTTP |
| qBittorrent Torrents | 6881 | TCP/UDP |
| Radarr | 7878 | HTTP |
| Sonarr | 8989 | HTTP |
| Lidarr | 8686 | HTTP |
| Readarr | 8787 | HTTP |
| Bazarr | 6767 | HTTP |
| Prowlarr | 9696 | HTTP |
| Jackett | 9117 | HTTP |
| Plex | 32400 | HTTP |
| Emby | 8096 | HTTP |
| Jellyfin | 8096 | HTTP |
| Channels DVR | 8089 | HTTP |
| Tautulli | 8181 | HTTP |
| Overseerr | 5055 | HTTP |
| Jellyseerr | 5056 | HTTP |
| FlareSolverr | 8191 | HTTP |

---

## What You Need

- [x] Linux server (Ubuntu/Debian recommended)
- [x] Sudo/root access
- [x] VPN subscription (any supported provider)
- [x] 4GB+ RAM (8GB+ recommended for multiple media servers)
- [x] 100GB+ disk space (more for large media libraries)
- [x] (Optional) Plex claim token from plex.tv/claim
- [x] (Optional) GPU for hardware transcoding

---

## Pro Tips

1. **Start Simple**: Install just Plex or Jellyfin first, add others later
2. **Use Prowlarr**: It's better than Jackett for most users
3. **Enable Hardware Transcoding**: Huge performance boost for streaming
4. **Test Kill Switch Monthly**: Ensure VPN protection is working
5. **Backup Configs**: The config directories contain all your settings
6. **Monitor with Tautulli**: Great for Plex statistics and notifications
7. **Use Overseerr/Jellyseerr**: Let users request content easily
8. **Try Multiple Media Servers**: See which you prefer before settling

---

## Getting Help

- **Installation Issues**: Check install.sh output for errors
- **VPN Issues**: `docker logs gluetun`
- **Media Server Issues**: Check respective logs
- **General Docker Issues**: `docker compose logs -f`
- **Network Issues**: Verify firewall settings

---

**That's it! Run `./install.sh` and answer a few questions to get started.**

The installer is smart and only asks about relevant options based on your choices!
