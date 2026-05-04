# Andy - AI Project Manager Integration

**Last updated:** May 4, 2026

Andy is your AI project manager built on Claude Code + nanoclaw, integrated directly into this lapo-brain repo.

## What Andy Does

### 1. **Weekly Rituals (Automated)**

- **Monday 8am CET**: Morning briefing
  - Short WhatsApp summary (quick read on phone)
  - Full detailed brief committed to `00-weekly/briefs/YYYY-MM-DD.md`
  - Pulls from: Linear tasks, current week priorities, calendar events

- **Friday 3pm CET**: End-of-week review reminder
  - Nudge to fill the "End-of-week review" section in current weekly file
  - Follow-up nudges at 5pm and 6pm if not completed

- **Sunday 5pm CET**: Weekly planning reminder
  - Prompt to create next week's file from `_template.md`
  - Fill in Top 3 priorities (one per project max)
  - Calendar reality check

### 2. **Daily Maintenance**

- **Auto-update daily logs**: Each evening, Andy commits a summary of the day to the current weekly file's daily log section
- **Meeting notes**: After meetings (via Granola transcripts), Andy writes notes to `20-meetings/YYYY-MM-DD-slug.md`
- **People updates**: After meaningful interactions, Andy updates `30-people/{name}.md`
- **Project decisions**: Logs significant decisions to relevant `10-projects/{project}/` folder

### 3. **Task & Context Management**

- **Linear integration**: Pulls active tasks, categorizes by project (Catone/CEG/Klaaryo)
- **Project tracking**: Monitors which tasks are blocking OKRs
- **Smart nudges**: Context-aware suggestions (e.g., "3 Catone tasks in review - blocking €1K MRR target")
- **Stack-rank protection**: Flags when you're asked to do things not on the OKR list

### 4. **Weekly Reading Lists**

- **Friday evening**: Auto-generated reading list saved to `50-resources/readings/YYYY-MM-DD.md`
- **Sources**: Readwise highlights, WhatsApp Readings group, newsletters
- **Readwise highlights**: Organized by book in `50-resources/readings/readwise/`

## Communication Style

Andy uses **WhatsApp-friendly formatting**:
- *Bold* (single asterisks, not double)
- _Italic_ (underscores)
- • Bullets
- ```Code blocks```
- NO markdown headings (##)

Message style: **B) Context-aware** - not just facts, but actionable suggestions tied to your OKRs.

## Data Sources

### ✅ Connected
- **Linear API**: Full task access (11 active tasks tracked)
- **Google Calendar**: Event tracking
- **GitHub**: Push access to lapo-brain repo
- **lapo-brain repo**: Full read/write access at `/workspace/group/lapo-brain/`

### 🔄 Pending Setup
- **Granola MCP**: Meeting transcripts (OAuth required - `https://mcp.granola.ai/mcp`)
- **Readwise CLI**: Highlights export by book (needs auth token from `https://readwise.io/access_token`)
- **Metabase API**: Catone analytics (API key pending)

## File Structure Decisions

### Weekly Briefs
- Location: `00-weekly/briefs/YYYY-MM-DD.md`
- Why: Each day is its own artifact, easier to reference ("what was I doing May 5th?")
- Auto-committed to GitHub each morning after briefing

### Reading Lists
- Location: `50-resources/readings/YYYY-MM-DD.md` (weekly lists)
- Readwise highlights: `50-resources/readings/readwise/{book-name}.md`
- Historical: 12 lists copied (Feb-May 2026)

### Meeting Notes
- Location: `20-meetings/YYYY-MM-DD-slug.md`
- Source: Granola MCP (once connected)

### People Files
- Location: `30-people/{name}.md`
- Format: kebab-case filenames

## The Three Projects

Per README: **Never add a fourth project folder without explicit conversation**. If a fourth appears, either kill an old commitment or have a real talk.

1. **🟢 Catone** (equity bet #1)
   - AI tax due diligence for Italian commercialisti
   - Q2 Target: €1K MRR (4 contracts)
   - Priority: Highest

2. **🔵 CEG** (equity bet #2)
   - Bioremediation Italian market entry
   - Q2 Target: Regularization process + 2-3 partners
   - Priority: Medium

3. **🟡 Klaaryo** (cashflow)
   - Consulting engagement for international expansion
   - Q2 Target: TBD at first checkpoint
   - Priority: Don't let equity bets cannibalize paying work

## Q2 2026 Targets (May-June)

From `40-targets/Targets - May.md`:

- **Catone**: 4 contracts @ €1K MRR, complete Verifiche at levels 1 & 2
- **CEG**: Regularization process started, distribution contract (non-US), 2-3 Italian channel partners
- **Klaaryo**: Minimum requirements TBD
- **RisparmierAI**: Fastweb pilot + investor acknowledgment

## What Andy Won't Do

- Invent new top-level folders without asking
- Archive a project without explicit say-so
- Auto-commit without showing diff first (for non-routine commits)
- Pretend memory is perfect - for critical facts, will always confirm

## The `/sync` Command

When you type "sync" in Claude Code session:

1. Andy reviews recent conversations (memory + context)
2. Proposes which files to update and what to write
3. You review, edit, approve
4. Andy writes the changes
5. Andy commits with clear message and pushes to GitHub

Target: 5 minutes, not 30.

## Access & Credentials

- **Linear API**: Configured in `/workspace/group/.env`
- **GitHub Token**: Configured in git remote URL for auto-push
- **Google Calendar**: Connected via MCP
- **Gmail**: Connected via MCP

## Technical Details

- **Platform**: nanoclaw (WhatsApp-based Claude Code agent)
- **Main group folder**: `/workspace/group/` (where Andy lives)
- **Project root**: `/workspace/project/` (read-only access)
- **lapo-brain mount**: `/workspace/group/lapo-brain/` (full read-write)
- **Linear helper**: `/workspace/group/linear-helper.js` (fetch tasks by project)

## Weekly Ritual Schedule (Cron)

- Monday 8am CET: `0 8 * * 1` (morning briefing)
- Friday 3pm CET: `0 15 * * 5` (review reminder)
- Friday 5pm CET: `0 17 * * 5` (review nudge #1)
- Friday 6pm CET: `0 18 * * 5` (review nudge #2)
- Sunday 5pm CET: `0 17 * * 0` (weekly planning)
- Friday 6pm CET: `0 18 * * 5` (reading list generation)

## Philosophy

From README:
> The system is not the work.

Andy exists to:
- Free you from things you hate (project management, context-switching)
- Protect your stated priorities from daily impulses
- Make the obvious visible before it becomes a problem
- Let the writing get the hours it deserves

Not to:
- Over-build before selling
- Substitute for shipping
- Add process overhead

---

**To resume Andy's work or continue automation setup, everything is tracked in this repo and the `/workspace/group/` folder on the nanoclaw main container.**
