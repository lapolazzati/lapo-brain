---
title: "feat: AETHON Quick — internal static site hosting layer"
status: active
date: 2026-06-10
origin: inspired by https://shopify.engineering/quick
type: feat
---

# feat: AETHON Quick — internal static site hosting on Hetzner EX44

## Summary

Adapt Shopify's Quick concept to AETHON: a hosted layer where skill runners (warroom, marketresearch, proposal) drop HTML/assets into a folder and get back a URL — served from the Hetzner EX44 NVMe, routed by the existing Caddy instance, secured by Tailscale for internal access and Caddy basic-auth for client-shareable links. No gcsfuse, no cloud storage, no shared backend — just the filesystem and Caddy.

The plan also covers two adjacent concerns that depend on the same server setup: (a) a dedicated `aethon` Linux user so AETHON services are isolated from other projects on the same machine, and (b) a lightweight partner access layer so non-technical co-founders/partners can reach documentation, shared files, and self-hosted tools without needing SSH or a technical setup.

---

## Problem Frame

AETHON's skills (`/warroom`, `/marketresearch`, `/proposal`) produce HTML output today but have no standard serving path. Each dashboard is either a one-off Caddy vhost or lives only on disk. There is no way for Lapo or an agent to say "publish this output and send me a link" without manual server config per site.

Shopify Quick shows that 50k+ sites can run on a single $200/month VM with a trivial filesystem+NGINX pattern. The Hetzner EX44 (64GB RAM, 1TB NVMe) is significantly more capable; the same pattern works with Caddy instead of NGINX, local NVMe instead of GCS.

Two related gaps exist on the same server: the Hetzner EX44 is used for multiple projects (including Catone), so AETHON services need filesystem and process isolation via a dedicated system user. And non-technical partners currently have no self-service path to documentation, deliverables, or shared tools — they depend on Lapo to share things manually.

---

## Requirements

- R1: Any skill runner or agent can deploy an HTML folder and get back a URL with zero manual server config.
- R2: Internal sites (accessed over Tailscale) require no per-site auth setup — Tailscale handles it.
- R3: A site can be marked "shareable" and given a password-protected public URL to send to clients.
- R4: `/warroom`, `/marketresearch`, and future HTML-output skills write to Quick paths by default.
- R5: AETHON_Technical_Architecture.md is updated to reflect the new service.
- R6: All AETHON processes, files, and directories run under a dedicated `aethon` Linux user, isolated from other projects (Catone, etc.) on the same EX44.
- R7: Non-technical partners can access documentation, Google Drive, and published Quick sites via a browser and a single shared password — no VPN, no SSH, no technical setup required.

---

## Key Technical Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Storage root | `/srv/quick/<slug>/` on NVMe | Local filesystem — faster than any mount, avoids gcsfuse complexity. `/srv/` is conventional for served content. |
| Internal URL scheme | `http://quick.aethon.internal/<slug>/` via Tailscale MagicDNS | Path-based avoids wildcard subdomain cert. One Caddy vhost handles all internal sites. Tailscale provides the auth layer. |
| External shareable scheme | `https://share.<public-aethon-domain>/<slug>/` | Path-based on a single public domain = single Let's Encrypt cert, no wildcard DNS challenge needed. |
| Per-site external auth | Caddy `basicauth` with bcrypt hash, generated at deploy time | Simple, Caddy-native, no extra dependency. Credential stored in 1Password under `quick/<slug>`. |
| Deploy mechanism | `quick-deploy` bash script: rsync local folder → server, write Caddy snippet, `caddy reload` | Mirrors `quick deploy` from Shopify. Runs locally by architects or called by n8n on the server for agent deployments. |
| Backend | Static-only v1 | Covers the immediate use case. Shared API (DB, WebSockets) deferred — can be added if skill outputs need dynamic data. |
| Site registry | `/srv/quick/_registry.json` — slug → {title, type, public, created_at} | Enables a listing page (`quick.aethon.internal/`) and audit of what's deployed. |
| Linux user isolation | Dedicated `aethon` system user; all services, files, and cron jobs run as `aethon` | Separates AETHON from Catone and other projects on the same EX44; limits blast radius if a service is compromised. |
| Partner access model | Public HTTPS portal page served by Quick at `https://portal.<domain>/` with a single shared password (1Password `core` → `partner-portal`) | No Tailscale enrollment needed for partners. Portal links to Google Drive, vault HTML docs, and published war rooms. Technical access (n8n admin, SSH) stays Tailscale-only for architects. |

---

## High-Level Technical Design

```
Deploy flow:
  local/agent: quick-deploy <slug> [--public --password <pw>] <folder>/
    │
    ├─ rsync <folder>/ → hetzner:/srv/quick/<slug>/
    ├─ write /etc/caddy/quick/<slug>.caddy  (internal block + optional public block)
    ├─ caddy reload
    └─ update /srv/quick/_registry.json
    → print URL(s)

Serving (Caddy):
  Caddyfile imports /etc/caddy/quick/*.caddy

  Internal (Tailscale only):
    http://quick.aethon.internal {
      handle /<slug>/* {
        root * /srv/quick/<slug>
        file_server strip_prefix /<slug>
      }
    }

  External (per-slug, generated):
    https://share.<domain> {
      handle /<slug>/* {
        basicauth { <user> <bcrypt-hash> }
        root * /srv/quick/<slug>
        file_server strip_prefix /<slug>
      }
    }
```

```
Server filesystem layout:
  /srv/quick/
    _registry.json         ← site index
    warroom-acmecorp/      ← /warroom output
    research-acmecorp-br/  ← /marketresearch output
    <slug>/
      index.html
      assets/

  /etc/caddy/quick/
    <slug>.caddy           ← generated per deployment, imported by Caddyfile
```

---

## Scope Boundaries

### In scope
- `/srv/quick/` storage layout and Caddy serving config
- External shareable URLs with per-site basic auth
- `quick-deploy` bash script (local execution + server-side path for agent use)
- `/warroom` and `/marketresearch` output path integration
- `AETHON_Technical_Architecture.md` update
- Dedicated `aethon` Linux user with correct ownership of all AETHON directories
- Partner portal page (static HTML, served by Quick, password-protected)

### Deferred to Follow-Up Work
- Shared backend API (DB, WebSockets) — Quick v2 if skill outputs need dynamic data
- Subdomain-based URLs (`<slug>.quick.aethon.co`) — possible upgrade; requires wildcard cert
- Site expiry / TTL — auto-delete old deployments after N days
- A web UI listing page at `quick.aethon.internal/`

### Out of scope
- GCS/S3 or any cloud storage — unnecessary on a dedicated NVMe server
- Container-per-site isolation — overkill at AETHON's scale

---

## Implementation Units

### U1. Storage layout and Caddy internal config

**Goal:** `/srv/quick/` tree exists with correct permissions; Caddy serves `http://quick.aethon.internal/<slug>/` for any slug that has a directory.

**Requirements:** R1, R2

**Dependencies:** none

**Files:**
- `/srv/quick/` directory tree (server-side)
- `/etc/caddy/quick/` directory (server-side)
- `Caddyfile` — add `import /etc/caddy/quick/*.caddy`
- `infrastructure/quick/internal.caddy` — the internal vhost config (repo reference copy)

**Approach:** The internal vhost is a single Caddy block on `http://quick.aethon.internal`. It uses a wildcard `handle /{slug}/*` pattern with `file_server` rooted at `/srv/quick/{slug}/`. No HTTPS needed on the Tailscale network — Tailscale provides transport encryption and access control. The index at `http://quick.aethon.internal/` can 404 or show a simple listing of `_registry.json` for now.

**Patterns to follow:** Existing Caddy vhost pattern in `infrastructure/` (the `n8n.aethon.x` and `cal.aethon.x` blocks).

**Test scenarios:**
- Deploy a folder with `index.html` + CSS asset to slug `test-site`. Hit `http://quick.aethon.internal/test-site/` from a Tailscale-connected device → returns the HTML correctly.
- Hit `http://quick.aethon.internal/nonexistent/` → 404 (not a 500 or Caddy error page).
- Deploy two sites with the same slug → second deploy overwrites first, serving the new content after `caddy reload`.
- Hit the URL from outside Tailscale → connection refused (Tailscale DNS resolves only on the network).

**Verification:** URL returns content within 5s of `caddy reload` completing.

---

### U2. External shareable URLs with per-site basic auth

**Goal:** `quick-deploy --public --password <pw> <slug> <folder>` makes the site accessible at `https://share.<domain>/<slug>/` with a password.

**Requirements:** R3

**Dependencies:** U1

**Files:**
- `/etc/caddy/quick/<slug>.caddy` — generated snippet with `basicauth` block
- `infrastructure/quick/share-template.caddy` — template reference (repo copy)
- `quick-deploy` script (extended in U3)

**Approach:** When `--public` is passed, the deploy script bcrypt-hashes the password (`caddy hash-password`), writes a Caddy snippet adding a `handle /<slug>/*` block under `https://share.<domain>` with `basicauth`. The snippet is appended to or merged with the existing `share.<domain>` vhost (or generated as a standalone file and imported). Credentials are stored in 1Password under vault `core` → item `quick/<slug>`.

**Auth model note:** A single Caddy server block for `https://share.<domain>` with multiple `handle /<slug>/*` blocks, each with its own `basicauth`. Caddy evaluates handle blocks by specificity; this works correctly. Let's Encrypt auto-provisions the cert for `share.<domain>`.

**Test scenarios:**
- Deploy a shareable site with password `hunter2`. Hit `https://share.<domain>/<slug>/` without credentials → 401 Unauthorized.
- Hit with correct credentials → returns HTML content.
- Deploy a second shareable site with different password. Verify first site's password does not unlock second site.
- Deploy same slug without `--public` flag after a public deployment → re-deploy removes the public block; external URL returns 404.
- Access from outside Tailscale with correct password → works (public DNS + Let's Encrypt cert).

**Verification:** Client can open the URL on any browser without Tailscale, enter password, and view the dashboard.

---

### U3. `quick-deploy` CLI script

**Goal:** A single script usable by architects (locally) and by n8n/skill-runners (server-side) to deploy a site in one command.

**Requirements:** R1, R2, R3

**Dependencies:** U1, U2

**Files:**
- `scripts/quick-deploy` (bash, in vault repo or a standalone tool dir on the server)
- `scripts/quick-deploy.md` — usage doc embedded as comments + a short README

**Approach:**

```
Usage: quick-deploy <slug> <local-folder> [--public] [--password <pw>] [--title <title>]

Steps (directional, not final):
  1. Validate slug (alphanumeric + hyphens, max 50 chars)
  2. rsync <local-folder>/ → hetzner:/srv/quick/<slug>/
  3. If --public: hash password, write /etc/caddy/quick/<slug>.caddy with basicauth block
  4. caddy reload (via ssh or locally if running on server)
  5. Update /srv/quick/_registry.json (slug, title, public bool, timestamp)
  6. Print: internal URL + (if public) external URL + credential reminder
```

Server-side version (called by skill-runners/n8n): same script, skips the rsync step (files already written locally by the skill), only does steps 3-6.

**Patterns to follow:** Existing `scripts/` tooling in the vault repo (build-on-push wrappers).

**Test scenarios:**
- Run `quick-deploy test-slug ./my-site/` → rsync succeeds, Caddy reloads, internal URL printed.
- Run with a slug containing spaces or uppercase → script errors with a clear message before touching the server.
- Run `quick-deploy test-slug ./my-site/ --public` without `--password` → script prompts for password or errors if non-interactive.
- Run twice with the same slug → idempotent: second run updates content, does not create duplicate Caddy blocks.
- Dry-run flag (`--dry-run`) → prints what would happen without executing.
- Script called from n8n (non-interactive, server-side) with all args supplied → completes without prompts.

**Verification:** A skill runner calling `quick-deploy warroom-acmecorp /srv/agents/acmecorp/warroom-output/` produces a working internal URL in the Slack response.

---

### U4. Skill runner integration

**Goal:** `/warroom` and `/marketresearch` write HTML output to the Quick path and return the URL; `/debrief` and `/warroom` include the link in their Slack responses.

**Requirements:** R4

**Dependencies:** U3

**Files:**
- `skills/warroom.md` — update output path + add `quick-deploy` step
- `skills/marketresearch.md` — update output path + add `quick-deploy` step
- `infrastructure/skill-runner/` — any runner config that sets output directories

**Approach:** Skills currently write output to `/clients/<name>/01-research/` (vault) or a local tmp path. Add a final step to each HTML-producing skill:

1. Write HTML output to `/srv/quick/<skill>-<client>/`
2. Call `quick-deploy <skill>-<client> /srv/quick/<skill>-<client>/` (server-side, no rsync)
3. Append the internal URL to the Slack response

For `/warroom` specifically: flag `--public` with a per-engagement password from 1Password, so the client-facing war room link is always ready. Password generated once at engagement start, stored in 1Password `quick/<slug>`, never regenerated unless explicitly rotated.

**Test scenarios:**
- Run `/warroom acmecorp` → Slack response includes `http://quick.aethon.internal/warroom-acmecorp/` and (if flagged public) `https://share.<domain>/warroom-acmecorp/`.
- Run `/marketresearch acmecorp brazil` → Slack response includes internal URL; `/srv/quick/research-acmecorp-br/index.html` exists and is browsable.
- Run `/warroom` twice → second run updates the site content; URL remains the same.
- Skill runner fails mid-execution → no partial Caddy config written (validate rsync success before caddy reload).

**Verification:** After a `/warroom` run, Lapo can open the link from any Tailscale device and see the current dashboard, without any manual server steps.

---

### U5. Update AETHON Technical Architecture

**Goal:** `AETHON_Technical_Architecture.md` reflects the Quick service, URL scheme, and storage layout. The doc should serve as a complete source of truth for anyone joining or setting up the server.

**Requirements:** R5

**Dependencies:** U1 (can be done in parallel once design is settled)

**Files:**
- `10-projects/AETHON/AETHON_Technical_Architecture.md` (in lapo-brain vault)

**Approach:** Edit the following sections:
- **Section 2 (Stack at a glance):** Add `quick` row — tool: `quick (Caddy + /srv/quick/)`, why: internal static hosting for skill outputs and client dashboards, cost: €0 (runs on existing Hetzner).
- **Section 3 (Hetzner server layout):** Add `quick` to the Docker Compose service list with its paths and role.
- **Section 3 (or new subsection):** Add URL scheme table: internal Tailscale URLs vs. external shareable URLs.
- **Section 7 (Sync architecture):** Add `Dashboards / deliverables` row — source of truth: Quick (`/srv/quick/`); note that skills write here directly.
- **Section 8 (Zero-ops map):** Update "Dashboards (war room)" row — currently "Static per-client page generated by /warroom, served by Caddy with basic auth" → update to reflect Quick pattern.

**Test expectation:** none — this is a documentation update. Verification: a new team member reading the doc understands the Quick pattern without needing this plan.

---

### U6. Dedicated `aethon` Linux user

**Goal:** All AETHON services, files, and processes run under a dedicated `aethon` system user on the EX44, fully isolated from other projects on the same machine.

**Requirements:** R6

**Dependencies:** none (should be the first thing done on the server before any AETHON service is deployed)

**Files:**
- Server-side: `aethon` Linux user, home at `/home/aethon/`
- `/srv/quick/` — owned `aethon:aethon`, `755`
- `/etc/caddy/quick/` — owned `aethon:aethon` (Caddy reads this; check if Caddy runs as its own user and needs group access)
- `infrastructure/setup/create-aethon-user.sh` — idempotent setup script (repo reference copy)
- Systemd unit overrides for all AETHON services: `User=aethon`

**Approach:** Create `aethon` as a system user (no login shell, no password, SSH key-only via 1Password `core` → `aethon-ssh-key`). All directories that AETHON services read/write (`/srv/quick/`, vault mirror path, skill-runner working dirs, agent dirs) are owned by `aethon`. Caddy may run as its own `caddy` user — add `caddy` to the `aethon` group or set directory permissions so Caddy can read `/srv/quick/` and `/etc/caddy/quick/`. n8n, skill-runner, and agent containers have `User=aethon` in their systemd or Docker Compose service definitions.

Tailscale ACL: create a `tag:aethon` device tag. All AETHON-serving devices use this tag. This ensures ACL rules can target AETHON services without mixing with other project tags.

**Patterns to follow:** The existing Docker Compose + Caddy layout in the AETHON Technical Architecture (Section 3).

**Test scenarios:**
- SSH as `aethon` user (key-based) → succeeds; `whoami` returns `aethon`.
- A file written by a skill-runner process → owned by `aethon`, readable by `caddy` group.
- Attempt to `cat` a Catone project file from the `aethon` session → permission denied.
- `ps aux | grep aethon` shows all AETHON services (n8n, skill-runner, agents) running under the `aethon` user.
- Reboot EX44 → all AETHON systemd services restart automatically as `aethon`.

**Verification:** No AETHON process runs as root or as another project's user. `ls -la /srv/quick/` shows `aethon` ownership throughout.

---

### U7. Partner portal — browser-based access for non-technical partners

**Goal:** A password-protected page at `https://portal.<domain>/` that partners can open in any browser to find: Google Drive folder link, vault HTML documentation, and current war room links. No VPN or SSH required.

**Requirements:** R7

**Dependencies:** U1, U2 (portal is a Quick site, deployed via `quick-deploy --public`)

**Files:**
- `/srv/quick/partner-portal/index.html` — the portal page (hand-authored or generated by a skill)
- `/srv/quick/partner-portal/style.css` — minimal styling
- `/etc/caddy/quick/partner-portal.caddy` — generated by `quick-deploy --public`
- 1Password `core` → `partner-portal` — the shared bcrypt password for portal access

**Approach:** The portal is a static HTML page deployed via Quick like any other site. Content:

```
AETHON Partner Hub
├── Google Drive → [link to the shared "AETHON Partners" Google Drive folder]
├── Documentation
│     ├── Operating Manual → [link to the GitHub-Actions-generated HTML view]
│     ├── Technical Architecture → [same]
│     └── Engagement Playbook → [same]
├── Active War Rooms → [list of active client quick-deploy URLs with their passwords]
├── Book a call → [Cal.com link]
└── Slack → [link to AETHON Slack workspace invite]
```

Password: a single shared bcrypt password for all partners (not per-engagement). Stored in 1Password `core` vault under `partner-portal`. Share via 1Password item-sharing link — partners get the URL + password in one tap.

**Google Drive setup (parallel to server work):** Create a "AETHON Partners" shared folder in the Google Workspace. Include: engagement deliverables (PDFs/decks), legal templates, playbook exports. Share with partner emails directly. The portal links to this folder; partners who already have Google accounts can access it without a password.

**War room section maintenance:** when `/warroom` deploys a new site, it appends an entry to a JSON config file (`/srv/quick/partner-portal/_warrooms.json`) and regenerates the portal `index.html`. The portal always reflects current active war rooms.

**What partners see vs. architects:**
- Partners (portal): documentation, Drive, war room links (read-only)
- Architects (Tailscale): full `quick.aethon.internal` listing, n8n admin, SSH, all services

**Test scenarios:**
- Open `https://portal.<domain>/` in an incognito browser without credentials → 401.
- Enter the correct portal password → page loads with links.
- Click the Google Drive link → opens the shared folder (partner must have been added as a Drive collaborator separately).
- Click an Operating Manual link → HTML view of the vault doc loads correctly.
- Click a war room link → prompts for the war-room-specific password (separate from portal password).
- Change the portal password via `quick-deploy --rotate-password partner-portal` → old password stops working within 60s.

**Verification:** A non-technical partner, given only the portal URL and password via 1Password share, can reach all linked resources without any additional help.

---

## Risks & Dependencies

| Risk | Mitigation |
|---|---|
| Caddy wildcard `handle` blocks per slug grow indefinitely | `/srv/quick/` cleanup script (deferred); for now, old deployments are cheap on 1TB NVMe |
| External URL leakage (client sends password to wrong person) | Per-site passwords, not a global one; rotate via `quick-deploy --rotate-password <slug>` |
| `caddy reload` fails due to a malformed generated snippet | Validate the Caddy snippet with `caddy validate` before reloading; abort and error on failure |
| Skill runner writes a broken HTML output to the Quick path | Quick serves whatever is there — bad HTML is a skill quality issue, not a hosting issue |
| Caddy runs as `caddy` user, can't read `aethon`-owned directories | Add `caddy` to the `aethon` group, set dirs `750` with group read; or configure Caddy to run as `aethon` (simpler on a single-tenant server) |
| Partner portal password leaked | Per-site password (not a master key); changing it only affects the portal, not war rooms or other sites |
| Catone processes accidentally interact with AETHON dirs | `aethon` user + directory ownership prevents this; validate with `namei -l /srv/quick/` on setup |

---

## Sources & Research

- Shopify Engineering: *Quick: Internal Hosting Platform* (https://shopify.engineering/quick) — the direct inspiration. Key takeaway: storage mount + reverse proxy wildcard + auth = all you need. Replicated here with NVMe + Caddy + Tailscale instead of GCS + NGINX + IAP.
- AETHON Technical Architecture v0.1 (`10-projects/AETHON/AETHON_Technical_Architecture.md`) — existing Caddy/Hetzner/Tailscale stack constraints.
