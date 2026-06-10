---
type: Research
status: Active
related_to: "[[reference_lapo_brain]]"
---

# Self-Hosted Dev Environment via Tailscale

Full setup guide: iPad coding + iPhone file access + Syncthing + iCloud/Google replacement on CATONE (EX44) + openclaw-n8n (CAX21).

**Research basis:** 106-agent deep research pass, 24 sources, 25 claims adversarially verified. Claims without 2/3 vote were killed.

---

## Architecture Overview

```
Mac (~/Developer) ←─ Syncthing ─→ CATONE (~/Developer)
                                        │
                        ┌───────────────┼────────────────┐
                        ↓               ↓                ↓
                  code-server      Samba/SMB         Nextcloud
                  (iPad/Safari)   (iPhone Files)   (iCloud/GDrive
                                                    replacement)
                                        │
                                  Syncthing Send Only
                                        ↓
                                  iPhone (Mobius Sync, Receive Only)
```

**Machines:**
| Host | Spec | Cost | Role |
|---|---|---|---|
| CATONE | EX44 Dedicated, ~64GB RAM, ~1TB NVMe | €49/mo | Primary: code-server, Syncthing, Samba, Nextcloud |
| openclaw-n8n | CAX21 ARM, 4 vCPU, 8GB RAM | €8.49/mo | Stays: n8n automations |

---

## Part 1 — iPad Coding (code-server + Caddy + Tailscale)

### Why this stack
Safari on iPad requires a **domain name** (not a bare IP) for WebSocket connections. Tailscale MagicDNS provides the hostname; Caddy fetches TLS certs from Tailscale's ACME proxy automatically. Verified 3-0.

### 1.1 Install code-server on CATONE

```bash
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER
```

Edit `~/.config/code-server/config.yaml`:
```yaml
bind-addr: 127.0.0.1:8080
auth: password
password: STRONG_PASSWORD_HERE
cert: false
```
Keep `auth: password` — disabling it even behind Tailscale was not verified as safe (1-2 vote against).

### 1.2 Install Caddy

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy
```

### 1.3 Grant Caddy permission to fetch Tailscale certs

```bash
echo 'TS_PERMIT_CERT_UID=caddy' | sudo tee -a /etc/default/tailscaled
sudo systemctl restart tailscaled
```

This is **required** — without it Caddy cannot fetch *.ts.net certificates. Verified 3-0.

### 1.4 Configure Caddyfile

Get your MagicDNS hostname: Tailscale admin → Machines → CATONE. It looks like `catone.your-tailnet.ts.net`.

Edit `/etc/caddy/Caddyfile`:
```caddy
catone.your-tailnet.ts.net {
    reverse_proxy 127.0.0.1:8080
}
```

```bash
sudo systemctl reload caddy
```

Caddy 2.5+ auto-detects `*.ts.net` site blocks and handles TLS with no additional config. Verified 3-0.

### 1.5 iPad access

1. Open Safari → `https://catone.your-tailnet.ts.net`
2. Enter password
3. Optional: Share → Add to Home Screen (PWA mode)

**Note on PWA:** The claim that PWA mode unlocks extra keyboard shortcuts was refuted (1-2). Treat it as a bookmarked tab.

---

## Part 2 — iPhone File Access

### Option A: Samba/SMB (recommended — native iOS Files app, no third-party needed)

iOS Files app natively supports **SMB only**. WebDAV, SFTP, FTP all require third-party apps. Verified 3-0.

```bash
sudo apt install samba
```

`/etc/samba/smb.conf` — add at the bottom:
```ini
[Developer]
   path = /home/YOUR_USER/Developer
   browseable = yes
   read only = no
   guest ok = no
   valid users = YOUR_USER
   force user = YOUR_USER
```

```bash
sudo smbpasswd -a YOUR_USER
sudo systemctl enable --now smbd nmbd
```

On iPhone: **Files → ... (top right) → Connect to Server** → enter `smb://100.x.y.z` (CATONE's Tailscale IP).

Works entirely within Tailscale network — never exposed to the internet.

### Option B: Taildrive (zero-config, built into Tailscale 1.56+)

```bash
# On CATONE
tailscale drive share developer /home/YOUR_USER/Developer
```

On iPhone: open Tailscale app → Drives. iPhone can browse shares from Linux/macOS/Windows but **cannot itself share**. Verified 3-0.

Caveat: exact WebDAV endpoint address for third-party apps is not documented — the Tailscale iOS app is the only verified access path.

### Option C: rclone WebDAV (for third-party apps like Documents by Readdle)

```bash
sudo apt install rclone

# Run as systemd service
sudo tee /etc/systemd/system/rclone-webdav.service > /dev/null <<EOF
[Unit]
Description=rclone WebDAV server
After=network.target

[Service]
User=YOUR_USER
ExecStart=/usr/bin/rclone serve webdav /home/YOUR_USER/Developer \
  --addr 100.x.y.z:8888 \
  --user lapo \
  --pass YOUR_PASSWORD \
  --log-level INFO
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now rclone-webdav
```

Replace `100.x.y.z` with CATONE's Tailscale IP. In Documents/FileBrowser: add WebDAV connection → `http://100.x.y.z:8888`.

---

## Part 3 — Syncthing: Mac ↔ CATONE ↔ iPhone

### Install on CATONE

```bash
sudo apt install syncthing
sudo systemctl enable --now syncthing@YOUR_USER
# Access UI via SSH tunnel:
# ssh -L 8385:127.0.0.1:8384 catone
# Then open http://127.0.0.1:8385
```

### Install on Mac

```bash
brew install syncthing
brew services start syncthing
# UI at http://127.0.0.1:8384
```

### Pair Mac ↔ CATONE

1. Mac UI → **Add Remote Device** → paste CATONE device ID (shown in CATONE's UI, top right)
2. Mac UI → **Add Folder** → path `~/Developer` → share with CATONE
3. Both devices: folder type = **Send & Receive**

### .stignore — critical for ~/Developer

Create `~/Developer/.stignore` **before** first sync. This applies to whichever device has the file. For CATONE and Mac, keep it light. For iPhone (Mobius Sync), use a heavy ignore list.

**Mac / CATONE `.stignore`** (keep git, keep build artifacts — full dev copy):
```
// Derived/generated only
.DS_Store
Thumbs.db
*.swp
*.swo
```

**iPhone `.stignore`** (set inside Mobius Sync app — exclude everything heavy):
```
node_modules
.git
dist
build
.next
.nuxt
__pycache__
*.pyc
.venv
venv
env
*.dmg
*.iso
*.zip
*.tar.gz
*.mov
*.mp4
target
vendor
.gradle
```

### iPhone sync (Mobius Sync)

- Install **Mobius Sync** (App Store, free tier available)
- Add CATONE as a device
- Share `~/Developer` → folder type on CATONE: **Send Only** (never applies mobile changes to server) → folder type on iPhone: **Receive Only**

**iOS background sync limitation:** Max 1-2h of sync activity/day, up to 24h before a sync starts. Verified 3-0 from Mobius Sync developer docs. This is an iOS architectural constraint. iPhone copy is a **soft offline cache**, not a real-time mirror.

For offline reading on iPhone, consider syncing only the `lapo-brain/` subfolder rather than all of `~/Developer`.

---

## Part 4 — Replace iCloud + Google (Nextcloud on CATONE)

CATONE's ~1TB NVMe is mostly unused — ideal for self-hosted cloud storage.

### Install Nextcloud (Docker)

```bash
sudo apt install docker.io docker-compose
mkdir -p /data/nextcloud

cat > /data/nextcloud/docker-compose.yml <<EOF
version: '3'
services:
  db:
    image: mariadb:10.11
    restart: always
    volumes:
      - db:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: CHANGE_ME
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: CHANGE_ME

  app:
    image: nextcloud:stable
    restart: always
    ports:
      - "127.0.0.1:8082:80"
    volumes:
      - nextcloud:/var/www/html
      - /data/nextcloud/data:/var/www/html/data
    environment:
      MYSQL_HOST: db
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: CHANGE_ME
    depends_on:
      - db

volumes:
  db:
  nextcloud:
EOF

cd /data/nextcloud && docker-compose up -d
```

Add to `/etc/caddy/Caddyfile`:
```caddy
cloud.catone.your-tailnet.ts.net {
    reverse_proxy 127.0.0.1:8082
    # Required for Nextcloud
    header Strict-Transport-Security max-age=15552000;
    redir /.well-known/carddav /remote.php/dav 301
    redir /.well-known/caldav /remote.php/dav 301
}
```

### What Nextcloud replaces

| Service | Nextcloud equivalent |
|---|---|
| iCloud Drive | Nextcloud Files + iOS app |
| Google Drive | Nextcloud Files |
| Google Photos | Nextcloud Photos or Immich (better) |
| Google Calendar | Nextcloud Calendar + CalDAV sync |
| Google Contacts | Nextcloud Contacts + CardDAV sync |
| iCloud Contacts/Cal | Same CalDAV/CardDAV |

### Immich (better than Nextcloud for photos)

For Google Photos replacement specifically, Immich has a much better UX:
```bash
# See immich.app for official docker-compose
```
Run on CATONE alongside Nextcloud on a different port, expose via Caddy.

---

## Cost Impact

| Item | Before | After |
|---|---|---|
| CATONE | €49/mo | €49/mo |
| openclaw-n8n | €8.49/mo | €8.49/mo |
| iCloud storage | ~€2.99-9.99/mo | €0 |
| Google One | ~€2.99-9.99/mo | €0 |
| **Total** | ~€63-77/mo | **€57.49/mo** |

Marginal monthly savings (~€7-20), but: full data sovereignty, no storage caps, no subscription creep.

**Potential future saving:** n8n could also run on CATONE (EX44 handles it easily), eliminating the CAX21 entirely for -€8.49/mo. Evaluate once Nextcloud/code-server are stable.

---

## Quick-Start Order

1. `code-server` + Caddy on CATONE → iPad coding working
2. Samba on CATONE → iPhone Files access working  
3. Syncthing on Mac + CATONE → bidirectional ~/Developer sync
4. Mobius Sync on iPhone → soft offline copy (lapo-brain subfolder only)
5. Nextcloud on CATONE → iCloud/Google migration
6. Immich on CATONE → Google Photos migration

---

## Open Questions (from research)

- Exact Taildrive WebDAV endpoint for third-party iOS apps — check latest Tailscale iOS changelog
- SMB exact `smb.conf` settings for reliable iOS negotiation — test empirically after install
- Whether `auth: none` in code-server is safe when behind Tailscale ACLs — check Tailscale guide directly
