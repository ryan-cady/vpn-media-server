# 📸 Visual Step-by-Step Guide: GitHub Upload & Installation

Follow these exact steps to upload your files to GitHub and install on your server.

---

## PART 1: Upload to GitHub (5 minutes)

### Step 1: Create GitHub Repository

1. **Go to**: https://github.com
2. **Click**: The **"+"** button (top-right corner)
3. **Select**: "New repository"

```
Screenshot location: Top-right corner → + icon → New repository
```

### Step 2: Configure Repository

Fill in these fields:

| Field | What to Enter |
|-------|---------------|
| **Repository name** | `vpn-media-server` |
| **Description** | "VPN-protected media server" |
| **Visibility** | 🔒 **Private** (recommended) |
| **Initialize** | ✅ Check "Add a README file" |

4. **Click**: Green **"Create repository"** button

### Step 3: Upload Files

5. **Click**: "Add file" button (blue button)
6. **Select**: "Upload files"
7. **Drag and drop** OR **Click "choose your files"**

**Select these 13 files to upload:**

```
✅ docker-compose.yml
✅ .env.example                    ⚠️ NOT .env!
✅ install.sh
✅ setup.sh
✅ test-killswitch.sh
✅ README.md
✅ GETTING_STARTED.md
✅ QUICK_INSTALL.md
✅ QUICK_REFERENCE.md
✅ COMMAND_LINE_INSTALL.md
✅ INSTALLATION_OVERVIEW.md
✅ ARCHITECTURE.md
✅ ABOUT_PROWLARR_WHISPARR.md
✅ CHANGELOG.md
✅ GITHUB_SETUP_GUIDE.md
```

8. **Scroll down**
9. **Click**: Green **"Commit changes"** button

### Step 4: Get Your Repository URL

Your repository URL is:
```
https://github.com/YOUR_USERNAME/vpn-media-server
```

**Find your username**: Look at the top-left of GitHub page

**Example**: If your username is `johnsmith`, your URL is:
```
https://github.com/johnsmith/vpn-media-server
```

✅ **GitHub upload complete!**

---

## PART 2: Install on Your Server (10 minutes)

### Step 5: Connect to Your Server

Open terminal and SSH to your server:

```bash
ssh your-username@your-server-ip
```

**Example:**
```bash
ssh ubuntu@192.168.1.100
```

### Step 6: Install Git (if needed)

```bash
sudo apt-get update
sudo apt-get install -y git
```

Type your password when prompted.

### Step 7: Clone Repository

**Replace YOUR_USERNAME with your actual GitHub username:**

```bash
git clone https://github.com/YOUR_USERNAME/vpn-media-server.git
```

**Example if your username is johnsmith:**
```bash
git clone https://github.com/johnsmith/vpn-media-server.git
```

**If private repository**, you may be asked to login:
- Username: Your GitHub username
- Password: Your GitHub password (or personal access token)

### Step 8: Enter Directory

```bash
cd vpn-media-server
```

### Step 9: Make Scripts Executable

```bash
chmod +x install.sh setup.sh test-killswitch.sh
```

### Step 10: Run Installer

```bash
./install.sh
```

The installer will now ask you questions:

---

## PART 3: Answer Installer Questions

### Question 1: Installation Directory

```
Enter installation directory [~/vpn-media-server]:
```

**Press Enter** to accept default

### Question 2: PIA Username

```
Enter your PIA username:
```

**Type**: Your Private Internet Access username
**Press Enter**

### Question 3: PIA Password

```
Enter your PIA password:
```

**Type**: Your Private Internet Access password (won't show on screen)
**Press Enter**

### Question 4: VPN Region

```
Popular VPN regions:
  1) US New York
  2) US California
  3) UK London
  4) Netherlands
  5) Canada Toronto
  6) Custom (enter manually)
Select region [1]:
```

**Type**: Number of your choice (or press Enter for default)

### Question 5: Timezone

```
Enter your timezone [America/New_York]:
```

**Examples**:
- `America/New_York`
- `America/Los_Angeles`
- `Europe/London`
- `America/Chicago`

**Type** your timezone or **Press Enter** for default

---

## PART 4: Wait for Installation

The installer will now:

1. ✅ Check for Docker (install if needed)
2. ✅ Create directories
3. ✅ Download Docker images (~5 minutes)
4. ✅ Start all services
5. ✅ Connect to VPN
6. ✅ Verify connection

**Watch the progress** - it will show green checkmarks ✅ as each step completes.

---

## PART 5: Access Your Services

When installation finishes, you'll see:

```
Installation Complete!
========================================

Access your services at:
  - qBittorrent:  http://192.168.1.100:8080
  - Radarr:       http://192.168.1.100:7878
  - Sonarr:       http://192.168.1.100:8989
  - Lidarr:       http://192.168.1.100:8686
  - Jackett:      http://192.168.1.100:9117
  - Prowlarr:     http://192.168.1.100:9696
  - Whisparr:     http://192.168.1.100:6969
```

### Step 11: Open qBittorrent

1. **Open browser**
2. **Type**: `http://YOUR_SERVER_IP:8080`
3. **Login**:
   - Username: `admin`
   - Password: `adminadmin`
4. **⚠️ IMMEDIATELY CHANGE PASSWORD**:
   - Tools → Options → Web UI
   - Set new password
   - Click Save

### Step 12: Test Kill Switch

Back in your SSH terminal:

```bash
./test-killswitch.sh
```

You should see:
```
✓✓✓ KILL SWITCH IS WORKING! ✓✓✓
No traffic leak detected.
```

If you see this, **you're fully protected!** ✅

---

## Quick Command Reference

### Check Status
```bash
cd ~/vpn-media-server
docker ps
```

### View Logs
```bash
docker compose logs -f
```

### Check VPN IP
```bash
docker exec gluetun wget -qO- ifconfig.me
```

### Restart Everything
```bash
docker compose restart
```

### Stop Everything
```bash
docker compose down
```

### Update Everything
```bash
git pull
docker compose pull
docker compose up -d
```

---

## Troubleshooting

### Problem: "git: command not found"

**Solution:**
```bash
sudo apt-get update
sudo apt-get install -y git
```

### Problem: "Permission denied" running install.sh

**Solution:**
```bash
chmod +x install.sh
./install.sh
```

### Problem: Can't clone private repository

**Solution:** Create Personal Access Token

1. GitHub → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token
4. Select `repo` scope
5. Use token as password when cloning

### Problem: VPN won't connect

**Solution:**
```bash
docker logs gluetun
```

Check for:
- Wrong username/password in .env
- Try different VPN region
- Check internet connection

### Problem: Can't access services

**Solution:**
```bash
# Check containers running
docker ps

# Get your server IP
hostname -I

# Check firewall
sudo ufw status
```

---

## Complete Example with Real Commands

Let's say:
- Your GitHub username: `johnsmith`
- Your server IP: `192.168.1.100`
- Your PIA username: `p1234567`
- You want US California server

### On GitHub:
1. Create repo named `vpn-media-server` (private)
2. Upload all files

### On Your Server:
```bash
# SSH to server
ssh ubuntu@192.168.1.100

# Install git
sudo apt-get update
sudo apt-get install -y git

# Clone repo
git clone https://github.com/johnsmith/vpn-media-server.git

# Enter directory
cd vpn-media-server

# Make executable
chmod +x *.sh

# Run installer
./install.sh

# When asked:
# - PIA username: p1234567
# - PIA password: (your password)
# - Region: 2 (for California)
# - Timezone: America/Los_Angeles

# Wait for installation...

# Test kill switch
./test-killswitch.sh

# Open browser to http://192.168.1.100:8080
```

**Done!** 🎉

---

## Checklist

Use this to track your progress:

### GitHub Upload
- [ ] Created GitHub account
- [ ] Created repository `vpn-media-server`
- [ ] Made it Private
- [ ] Uploaded all files
- [ ] Noted my repository URL

### Server Installation
- [ ] SSH'd to server
- [ ] Installed git
- [ ] Cloned repository
- [ ] Made scripts executable
- [ ] Ran install.sh
- [ ] Answered all questions
- [ ] Installation completed

### Post-Installation
- [ ] Accessed qBittorrent
- [ ] Changed qBittorrent password
- [ ] Tested kill switch
- [ ] Kill switch working ✅
- [ ] Accessed other services
- [ ] Configured Prowlarr

---

## Time Breakdown

| Step | Time |
|------|------|
| Create GitHub repo | 2 min |
| Upload files | 3 min |
| SSH to server | 1 min |
| Clone repository | 1 min |
| Run installer | 10 min |
| Configure services | 5 min |
| **Total** | **~20 min** |

---

## What's Next?

After installation:

1. **Configure Prowlarr** (http://YOUR_IP:9696)
   - Add indexers
   - Connect to *arr apps

2. **Set up *arr apps**
   - Add download client (qBittorrent)
   - Add root folders
   - Start adding content!

3. **Regular maintenance**
   - Update weekly: `git pull && docker compose pull && docker compose up -d`
   - Test kill switch monthly: `./test-killswitch.sh`
   - Backup configs monthly

---

## Need Help?

If you get stuck:

1. **Check logs**: `docker compose logs -f`
2. **Check specific service**: `docker logs gluetun`
3. **Test VPN**: `docker exec gluetun wget -qO- ifconfig.me`
4. **Read docs**: All the .md files in your repo

---

**You're all set! Follow these steps and you'll have everything running in about 20 minutes!** 🚀
