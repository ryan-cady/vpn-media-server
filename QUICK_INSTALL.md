# Quick Install - TL;DR

## The Fastest Way to Install

### 1. Download and run the automated installer:

```bash
# Download all files to a directory
mkdir ~/vpn-media-server && cd ~/vpn-media-server

# Download the install script (you have this file - upload it to your server)
# Then run:
chmod +x install.sh
./install.sh
```

The script will:
- ✅ Install Docker & Docker Compose automatically
- ✅ Ask for your PIA credentials
- ✅ Detect your network settings
- ✅ Create all directories
- ✅ Download and start all services
- ✅ Verify VPN connection

**Time to complete: ~10 minutes**

---

## Alternative: Manual 5-Command Install

If you already have Docker installed:

```bash
# 1. Create directory
mkdir ~/vpn-media-server && cd ~/vpn-media-server

# 2. Copy your docker-compose.yml and .env files here

# 3. Edit .env with your PIA credentials
nano .env

# 4. Create directories
mkdir -p {gluetun,qbittorrent,radarr,sonarr,lidarr,jackett,prowlarr,whisparr}/config downloads media/{movies,tv,music,adult}

# 5. Start everything
docker compose up -d
```

**Time to complete: ~5 minutes**

---

## What You Need Before Starting

- [x] Ubuntu/Debian Linux system
- [x] Sudo/root access
- [x] PIA VPN account (username & password)
- [x] Internet connection

---

## Access Services After Install

Replace `YOUR_IP` with your server's IP (find with: `hostname -I`)

| Service | URL | Default Password |
|---------|-----|------------------|
| qBittorrent | http://YOUR_IP:8080 | admin / adminadmin |
| Radarr | http://YOUR_IP:7878 | Set on first login |
| Sonarr | http://YOUR_IP:8989 | Set on first login |
| Lidarr | http://YOUR_IP:8686 | Set on first login |
| Jackett | http://YOUR_IP:9117 | None |
| Prowlarr | http://YOUR_IP:9696 | Set on first login |
| Whisparr | http://YOUR_IP:6969 | Set on first login |

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

1. **Change qBittorrent password** (default: admin/adminadmin)
2. **Test kill switch**: Run `./test-killswitch.sh`
3. **Configure Prowlarr**: Add indexers at http://YOUR_IP:9696
4. **Connect apps to Prowlarr**: Settings → Apps in each *arr service
5. **Done!** Start adding movies/shows

---

## If Something Goes Wrong

```bash
# Check what failed
docker compose logs -f

# Check specific service
docker logs gluetun

# Restart everything
docker compose restart

# Nuclear option (restart from scratch)
docker compose down
docker compose up -d
```

---

## Files You Received

Upload these to your server:

- **install.sh** - Automated installer (EASIEST)
- **docker-compose.yml** - Service definitions
- **.env.example** - Configuration template (rename to .env)
- **setup.sh** - Alternative setup helper
- **test-killswitch.sh** - VPN test script
- **README.md** - Full documentation
- **COMMAND_LINE_INSTALL.md** - Detailed manual steps

---

## Installation Location

Default: `~/vpn-media-server`

All your files will be here:
```
~/vpn-media-server/
├── docker-compose.yml
├── .env
├── downloads/
├── media/
└── [service]/config/
```

---

## Support

- **VPN Issues**: `docker logs gluetun`
- **Service Issues**: `docker logs [service_name]`
- **General Help**: See README.md for detailed docs
- **Kill Switch Test**: `./test-killswitch.sh`

---

**That's it! You're 5 commands away from a fully VPN-protected media server.**

Choose either:
1. **Easy**: Run `./install.sh` (handles everything)
2. **Quick**: Run the 5 manual commands above
3. **Detailed**: Follow COMMAND_LINE_INSTALL.md

All options give you the same result - a secure, automated media server!
