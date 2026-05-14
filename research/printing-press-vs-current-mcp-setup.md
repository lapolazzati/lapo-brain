# Printing Press vs Current MCP Setup - Investigation

**Date:** 2026-05-14
**Command examined:** `npx -y @mvanhorn/printing-press install granola`

---

## What is Printing Press?

Printing Press is an **MCP server installer/manager** created by @mvanhorn that:
- Builds "GOAT CLIs" designed for AI agents first
- Includes SQLite sync for offline search
- Creates compound insight commands only possible with local data
- Works as both a CLI tool AND an MCP server

**Philosophy:** "Every API has a secret identity. This finds it, absorbs every feature from every competing tool, then builds the GOAT CLI."

---

## Current Granola MCP Setup (Your System)

**Status:** ✅ Working
- You have Granola MCP tools available (`mcp__granola__*`)
- Connected to account: `lapo@risparmier.ai`
- Active workspace: RisparmierAI
- Successfully queried meetings, created meeting notes, etc.

**How it's installed:** Unknown (not via printing-press, based on `printing-press list` showing no installations)

**Likely setup:**
- Standard MCP server installation (manual or via another tool)
- Configured in Claude Desktop config
- Running as background service

---

## Printing Press Granola vs Standard Granola MCP

### Standard Granola MCP (What You Have Now)

**Features:**
- Query meetings by natural language
- List meetings by time range or folder
- Get meeting details (notes, summary, attendees)
- Get meeting transcripts
- Get account info

**Installation methods:**
1. Via Conare: `claude mcp add granola -- uv run mcp_granola.server`
2. Manual setup in `claude_desktop_config.json`
3. Various GitHub implementations:
   - `@btn0s/granola-mcp`
   - `proofgeist/granola-ai-mcp-server`
   - `cobblehillmachine/granola-claude-mcp`

### Printing Press Granola (What the Command Would Install)

**Additional features beyond standard MCP:**
- ✨ **Offline SQLite cross-meeting search**
- ✨ **Attendee timelines** (track interactions over time)
- ✨ **MEMO pipeline runner** (automated workflows)
- ✨ **Go CLI binary** for command-line access
- ✨ **Focused skill** (agent-specific workflows)
- ✨ **Compound insights** (cross-meeting analysis)

**Installation:**
```bash
npx -y @mvanhorn/printing-press install granola
```

**What gets installed:**
1. **Go CLI binary** - Command-line tool for Granola operations
2. **MCP server** - Enhanced server with SQLite caching
3. **Focused skill** - Pre-built agent workflows (optional with `--skill-only`)

---

## Comparison Matrix

| Feature | Current Setup | Printing Press |
|---------|--------------|----------------|
| Query meetings | ✅ Yes | ✅ Yes |
| List meetings | ✅ Yes | ✅ Yes |
| Get transcripts | ✅ Yes | ✅ Yes |
| Natural language search | ✅ Yes | ✅ Yes |
| **Offline SQLite cache** | ❌ No | ✅ Yes |
| **Cross-meeting search** | ❌ Limited | ✅ Enhanced |
| **Attendee timelines** | ❌ No | ✅ Yes |
| **MEMO pipeline runner** | ❌ No | ✅ Yes |
| **CLI access** | ❌ No | ✅ Yes |
| **Compound insights** | ❌ No | ✅ Yes |
| Installation complexity | Simple | Moderate |
| Maintenance | Manual updates | `printing-press update` |

---

## Key Differences

### 1. Offline SQLite Cache
**Current:** Every query hits Granola API
**Printing Press:** Syncs to local SQLite, queries run offline

**Benefit:** Faster queries, works offline, reduces API calls

### 2. Attendee Timelines
**Current:** Query one meeting at a time
**Printing Press:** Track interactions with specific people over time

**Example use case:** "Show me all meetings with Federico in the last 3 months and extract common themes"

### 3. MEMO Pipeline Runner
**Current:** Manual workflows
**Printing Press:** Automated multi-step operations

**Example:** Automatically extract action items from all meetings → create Linear tasks → send summary email

### 4. CLI Binary
**Current:** MCP only (accessible via Claude)
**Printing Press:** Go CLI for terminal use + MCP

**Benefit:** Use in scripts, cron jobs, non-Claude contexts

### 5. Compound Insights
**Current:** Single-meeting analysis
**Printing Press:** Cross-meeting pattern detection

**Example:** "Analyze decision velocity across all Q2 meetings with Klaaryo team"

---

## Installation Options

### Option 1: Keep Current Setup (No Change)
**Pros:**
- Already working
- Simple, minimal
- No migration needed

**Cons:**
- Missing advanced features
- No offline cache
- No CLI access

### Option 2: Install Printing Press (Full)
```bash
npx -y @mvanhorn/printing-press install granola
```

**Installs:**
- Go CLI binary
- Enhanced MCP server with SQLite
- Focused skill

**Pros:**
- All advanced features
- CLI + MCP access
- Offline cache
- Attendee timelines
- MEMO pipelines

**Cons:**
- May conflict with existing setup (need to disable old MCP)
- More complex
- Requires Go runtime

### Option 3: Install MCP Only (Skip CLI)
```bash
npx -y @mvanhorn/printing-press install granola --skill-only
```

**Installs:**
- Enhanced MCP server
- Focused skill

**Pros:**
- Advanced MCP features
- No CLI complexity
- Easier migration

**Cons:**
- No terminal access
- Still need to disable old MCP

---

## Migration Considerations

### If Installing Printing Press:

**1. Disable current Granola MCP:**
- Find current MCP config (likely in `~/.config/claude/claude_desktop_config.json`)
- Comment out or remove Granola MCP entry
- Restart Claude Desktop

**2. Install Printing Press version:**
```bash
npx -y @mvanhorn/printing-press install granola
```

**3. Verify tools available:**
- Check if `mcp__granola__*` tools still work
- May have different tool names (e.g., `granola__*`)
- Test basic queries

**4. Re-authenticate if needed:**
- Printing Press may require separate Granola API token
- Check auth flow during install

---

## Recommendation

### For Your Use Case (NanoClaw + Daily Briefings + Auto-Ingest):

**Short-term:** Keep current setup
- It's working reliably
- No immediate need for advanced features
- Avoid migration risk before June 26 deadline

**Medium-term (after June 26):** Evaluate Printing Press
- **Compelling for you:**
  - Attendee timelines (track Federico, Tamara interactions)
  - MEMO pipelines (auto-create tasks from meetings)
  - Offline cache (faster briefing generation)

- **Test approach:**
  1. Install in parallel (different port/config)
  2. Compare performance and features
  3. Migrate if benefits clear

### Specific Benefits for Your Workflows:

**Daily briefing auto-ingest:**
- Current: Query Granola API for "last 3 days action items"
- With Printing Press: Offline SQLite query (instant), richer attendee context

**Klaaryo tracking:**
- Current: Manual queries for Federico meetings
- With Printing Press: Attendee timeline shows all Federico interactions + themes

**CEG contractor follow-up:**
- Current: Search meetings manually
- With Printing Press: MEMO pipeline auto-creates follow-up tasks from meeting notes

---

## Command Reference

### Printing Press Commands

```bash
# Search catalog
npx -y @mvanhorn/printing-press search granola

# Install full (CLI + MCP + skill)
npx -y @mvanhorn/printing-press install granola

# Install MCP only (no CLI)
npx -y @mvanhorn/printing-press install granola --skill-only

# List installed
npx -y @mvanhorn/printing-press list

# Update installed
npx -y @mvanhorn/printing-press update granola

# Uninstall
npx -y @mvanhorn/printing-press uninstall granola
```

### After Installation (if CLI installed)

```bash
# Example CLI usage (hypothetical - actual commands TBD)
granola list-meetings --last 7d
granola search "action items" --attendee "Federico"
granola timeline --person "federico@klaaryo.com"
```

---

## Sources

- [Printing Press GitHub](https://github.com/mvanhorn/cli-printing-press)
- [Printing Press Library](https://github.com/mvanhorn/printing-press-library)
- [Printing Press Website](https://printingpress.dev/)
- [Granola MCP (Conare)](https://conare.ai/marketplace/mcp/granola/setup)
- [Granola MCP (PulseMCP)](https://www.pulsemcp.com/servers/granola)
- [Granola MCP (@btn0s)](https://glama.ai/mcp/servers/@btn0s/granola-mcp)

---

## Next Steps (If You Want to Explore)

1. **Test in parallel:**
   - Keep current Granola MCP running
   - Install Printing Press to different port
   - Compare side-by-side

2. **Document current setup:**
   - Find where current Granola MCP is configured
   - Note auth tokens, endpoints
   - Backup config before changes

3. **Trial period:**
   - Install Printing Press version
   - Use for 1 week
   - Evaluate if advanced features justify complexity

4. **Decision point:**
   - Keep Printing Press OR revert to current
   - Document choice in lapo-brain

---

**Status:** Investigation complete
**Current setup:** Works, no immediate action needed
**Printing Press:** Advanced features available, evaluate after June 26 deadline
