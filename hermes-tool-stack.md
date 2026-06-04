---
type: Note
related_to: "[[hermes-setup]]"
status: Active
---

# Hermes Tool Stack Reference

*Last updated: 2026-06-03*

This note replaces the old memory entries. Everything about how this environment works lives here, not in ephemeral session memory.

---

## Core Tools

### QMD — Brain Search
- **What:** Vector search over `~/lapo-brain` (264+ markdown documents)
- **How:** MCP server registered with Hermes. Tools: `query`, `get`, `multi_get`, `status`
- **CLI:** `qmd` binary is NOT on PATH. Use MCP tools or Python API only
- **Collection:** Indexed at `~/lapo-brain`

### Granola — Meeting Intelligence
- **Package:** `granola-mcp-plus`
- **Auth:** Copied from Mac (`stored-accounts.json` + `supabase.json` at `~/Library/Application Support/Granola/`)
- **Tools:** 12 available — search notes/transcripts/events/panels, get documents, list folders/workspaces
- **Auth expiry:** ~6h, auto-refreshes from stored-accounts.json
- **Daily cron:** 7:30am CET runs `~/.hermes/scripts/import_granola_meetings.py` → imports yesterday's meetings to `~/lapo-brain/20-meetings/` → commits to GitHub → re-indexes QMD

### Linear — Issue Tracking
- **CLI:** `~/.local/bin/linear` (symlink to `~/.hermes/skills/productivity/linear/scripts/linear_api.py`)
- **Deps:** Python stdlib only, zero installs
- **Auth:** `LINEAR_API_KEY` env var
- **Common commands:**
  - `linear whoami`
  - `linear get-issue LIF-32`
  - `linear list-issues --team LIF --limit 10`
  - `linear add-comment <id> <body>`
  - `linear update-status <id> <state>`
  - `linear create-issue --title "x" --team LIF`

### Firecrawl — Web Scraping
- **CLI + Python SDK** installed
- **Key:** `~/.firecrawl/.env`
- **Used by:** Research agent weekly script as primary scraper

---

## Platform Quirks

1. **`write_file`/`execute_code` corrupt string literals containing `(` or `)`** — use `terminal()` with heredocs instead
2. **Secret redaction filter aggressively mangles secret-like strings in `.py` files** (e.g. `TELEGRAM_BOT_TOKEN`, `STRIPE_SECRET_KEY`) — keep secrets in `secrets.json` and load generically, or use shell heredocs for raw file writes. Never hardcode secret env-var names in Python source

---

## Research Agent

- **Vault:** `~/lapo-brain/research-vault/`
- **Schedule:** Weekly, Mondays 6:00 AM UTC (`research-agent-weekly` cron job)
- **Script:** `~/.hermes/scripts/research_agent_weekly.py`
- **Lanes:** (1) International consulting, (2) BioRemediation/CEG, (3) AI & Parenting

---

## Q2 2026 Goals (Session Artifact — May Be Stale)

- CEG = one project ready to go
- Klaaryo = 10 qualified meetings set up
- Catone = go/no go decision

*Check with Lapo before treating these as current.*
