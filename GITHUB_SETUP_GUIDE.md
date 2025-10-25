# GitHub Setup and Installation Guide

This guide walks you through uploading your VPN Media Server files to GitHub and installing from there.

---

## Part 1: Upload Files to GitHub

### Step 1: Create a GitHub Account (if needed)

1. Go to https://github.com
2. Click "Sign up"
3. Follow the registration process
4. Verify your email

### Step 2: Create a New Repository

1. **Log in to GitHub**
2. **Click the "+" icon** in the top-right corner
3. **Select "New repository"**
4. **Fill in repository details:**
   - **Repository name**: `vpn-media-server` (or your preferred name)
   - **Description**: "VPN-protected media automation server with Radarr, Sonarr, Lidarr, and more"
   - **Visibility**: Choose one:
     - ⚠️ **Public**: Anyone can see (do NOT commit your .env file!)
     - 🔒 **Private**: Only you can see (recommended if you'll commit .env)
   - **Initialize**: ✅ Check "Add a README file"
   - **License**: Optional - choose MIT or None
5. **Click "Create repository"**

### Step 3: Upload Files via Web Interface

**Option A: Web Upload (Easiest)**

1. **On your repository page**, click "Add file" → "Upload files"
2. **Drag and drop** OR **click "choose your files"**
3. **Select these files** from the outputs folder:
   ```
   ├── docker-compose.yml
   ├── .env.example          (NOT .env with your passwords!)
   ├── install.sh
   ├── setup.sh
   ├── test-killswitch.sh
   ├── README.md
   ├── GETTING_STARTED.md
   ├── QUICK_INSTALL.md
   ├── QUICK_REFERENCE.md
   ├── COMMAND_LINE_INSTALL.md
   ├── INSTALLATION_OVERVIEW.md
   ├── ARCHITECTURE.md
   ├── ABOUT_PROWLARR_WHISPARR.md
   └── CHANGELOG.md
   ```
4. **IMPORTANT**: Upload `.env.example` NOT `.env` (keep your credentials private!)
5. **Add commit message**: "Initial commit - VPN media server setup"
6. **Click "Commit changes"**

**Option B: Git Command Line (Advanced)**

If you prefer using git from your local machine:

```bash
# Navigate to where you downloaded the files
cd ~/Downloads/vpn-media-server-files

# Initialize git repository
git init

# Add GitHub repository as remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/vpn-media-server.git

# Add all files EXCEPT .env (if it exists)
git add .

# If .env exists, remove it from staging
git rm --cached .env

# Commit
git commit -m "Initial commit - VPN media server setup"

# Push to GitHub
git push -u origin main
```

### Step 4: Verify Upload

1. Go to your repository: `https://github.com/YOUR_USERNAME/vpn-media-server`
2. You should see all files listed
3. Click on a few files to verify they uploaded correctly

---

## Part 2: Install from GitHub

### Method 1: One-Line Install (Easiest)

```bash
# Download and run the installer directly from GitHub
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/vpn-media-server/main/install.sh | bash
```

⚠️ **Replace YOUR_USERNAME with your actual GitHub username**

### Method 2: Clone and Install (Recommended)

This method gives you more control:

```bash
# 1. Install git if needed
sudo apt-get update
sudo apt-get install -y git

# 2. Clone the repository (replace YOUR_USERNAME)
git clone https://github.com/YOUR_USERNAME/vpn-media-server.git

# 3. Navigate to directory
cd vpn-media-server

# 4. Make scripts executable
chmod +x install.sh setup.sh test-killswitch.sh

# 5. Run the installer
./install.sh
```

The installer will:
- Check for Docker and install if needed
- Ask for your PIA credentials
- Detect network settings
- Create all directories
- Download Docker images
- Start all services
- Verify VPN connection

### Method 3: Manual Installation

If you want to do it manually:

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/vpn-media-server.git
cd vpn-media-server

# 2. Create .env from template
cp .env.example .env

# 3. Edit .env with your settings
nano .env
# Update: PIA_USERNAME, PIA_PASSWORD, LOCAL_NETWORK

# 4. Create directories
mkdir -p {gluetun,qbittorrent,radarr,sonarr,lidarr,jackett,prowlarr,whisparr}/config
mkdir -p downloads media/{movies,tv,music,adult}

# 5. Start services
docker compose up -d

# 6. Verify VPN
docker exec gluetun wget -qO- ifconfig.me

# 7. Test kill switch
./test-killswitch.sh
```

---

## Complete Step-by-Step Example

Here's a complete walkthrough with real commands:

### On Your Local Computer (where you have the files):

**If using Web Upload:**
1. Go to https://github.com
2. Click "+" → "New repository"
3. Name it `vpn-media-server`
4. Make it Private (recommended)
5. Click "Create repository"
6. Click "uploading an existing file"
7. Drag all files EXCEPT .env
8. Click "Commit changes"

### On Your Server (where you want to install):

```bash
# 1. SSH into your server
ssh your-user@your-server-ip

# 2. Clone your repository (replace YOUR_USERNAME)
git clone https://github.com/YOUR_USERNAME/vpn-media-server.git

# 3. Enter directory
cd vpn-media-server

# 4. Make scripts executable
chmod +x *.sh

# 5. Run installer
./install.sh
```

The installer will now guide you through:
- Entering PIA credentials
- Choosing VPN region
- Setting timezone
- Starting services

**That's it!** ✅

---

## Important Security Notes

### ⚠️ NEVER Commit These Files:

```
.env                    # Contains your PIA password!
*.log                   # May contain sensitive info
qbittorrent/config/     # Contains passwords
*/config/               # Contains API keys
```

### ✅ Safe to Commit:

```
docker-compose.yml
.env.example            # Template without real credentials
*.sh                    # Scripts
*.md                    # Documentation
```

### Create a .gitignore File

To prevent accidentally committing sensitive files:

```bash
# On your repository, create .gitignore
cat > .gitignore << 'EOF'
# Sensitive files
.env

# Config directories (contain passwords/API keys)
*/config/
gluetun/
downloads/
media/

# Logs
*.log

# Temporary files
*.tmp
*.swp
*~
EOF

# Add and commit .gitignore
git add .gitignore
git commit -m "Add .gitignore"
git push
```

---

## Updating from GitHub

After making changes to your repository:

```bash
# On your server, navigate to installation directory
cd ~/vpn-media-server

# Pull latest changes
git pull

# Restart services to apply changes
docker compose down
docker compose up -d
```

---

## Quick Reference URLs

After creating your repository, you'll use these URLs:

**Repository URL:**
```
https://github.com/YOUR_USERNAME/vpn-media-server
```

**Clone URL:**
```
https://github.com/YOUR_USERNAME/vpn-media-server.git
```

**Raw file URLs (for direct download):**
```
https://raw.githubusercontent.com/YOUR_USERNAME/vpn-media-server/main/install.sh
https://raw.githubusercontent.com/YOUR_USERNAME/vpn-media-server/main/docker-compose.yml
```

**One-line installer:**
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/vpn-media-server/main/install.sh | bash
```

---

## Troubleshooting

### "Permission denied" when cloning

```bash
# Make sure git is installed
sudo apt-get install git

# If private repo, you may need to authenticate
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### "Repository not found"

- Check the URL is correct
- If private repo, make sure you're logged in
- Try using HTTPS URL instead of SSH

### Can't run install.sh

```bash
# Make sure it's executable
chmod +x install.sh

# Run with bash explicitly
bash install.sh
```

### Git clone is slow

```bash
# Clone only latest commit (faster)
git clone --depth 1 https://github.com/YOUR_USERNAME/vpn-media-server.git
```

---

## Alternative: Using GitHub Releases

For easier version management, you can create releases:

### Create a Release

1. On GitHub, go to your repository
2. Click "Releases" (right sidebar)
3. Click "Create a new release"
4. Tag version: `v1.0.0`
5. Title: "Initial Release"
6. Description: Add changelog
7. Click "Publish release"

### Install from Release

```bash
# Download latest release
wget https://github.com/YOUR_USERNAME/vpn-media-server/archive/refs/tags/v1.0.0.zip

# Extract
unzip v1.0.0.zip
cd vpn-media-server-1.0.0

# Run installer
chmod +x install.sh
./install.sh
```

---

## Making Your Repo Private vs Public

### Public Repository:
✅ Easy to share
✅ Can use one-line installer
⚠️ NEVER commit .env file
⚠️ No API keys or passwords

### Private Repository:
✅ Can commit anything
✅ Complete privacy
❌ Requires GitHub authentication to clone
❌ Can't use simple one-line installer

**Recommendation**: Use Private repo, and create .gitignore to exclude sensitive directories.

---

## Complete Example with Your Username

Let's say your GitHub username is `johnsmith`:

**1. Create repo on GitHub:** `vpn-media-server`

**2. On your server:**
```bash
# Clone
git clone https://github.com/johnsmith/vpn-media-server.git

# Enter directory
cd vpn-media-server

# Run installer
chmod +x install.sh
./install.sh
```

**3. Access services:**
```
http://YOUR_SERVER_IP:8080  (qBittorrent)
http://YOUR_SERVER_IP:7878  (Radarr)
http://YOUR_SERVER_IP:8989  (Sonarr)
# etc...
```

---

## Next Steps After Installation

1. **Test VPN**: `./test-killswitch.sh`
2. **Change passwords**: qBittorrent, all *arr apps
3. **Configure Prowlarr**: Add indexers
4. **Connect apps**: Link *arr apps to Prowlarr
5. **Add content**: Start adding movies/shows

---

## Summary

**Quick Steps:**
1. ✅ Create GitHub account
2. ✅ Create new repository (private recommended)
3. ✅ Upload all files EXCEPT .env
4. ✅ Clone on your server
5. ✅ Run install.sh
6. ✅ Done!

**Time to complete:** 
- GitHub upload: 5 minutes
- Server installation: 10 minutes
- **Total: ~15 minutes**

---

You now have a version-controlled, easily deployable VPN media server! 🎉
