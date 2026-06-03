---
type: Note
related_to: "[[hermes-agent]]"
status: Active
---

# Personal Agent Stack

Adapted from [[personal-agent-nicolas-dessaigne]]. Mapped to my actual tools, data, and constraints.

## Core Philosophy

The agent is *glue*, not oracle. Administrative continuity, not dramatic autonomy. The agent does the tedious first-pass work across my tools and asks at the right moments. I stay in control.

I do not want an agent that blindly replies to everyone. I want an agent that prepares the work, shows me the draft, and asks at the right moment.

## Agent

*Hermes* (this session). Running on a Linux box, connected to Telegram.

I also use Codex and Claude Code for coding tasks, but Hermes is the persistent personal agent that manages cross-tool workflows and remembers context across sessions.

## Tool Surface

Hierarchy: API and CLI > local file > browser automation > screen automation

| Tool | Connector | Status | Notes |
|------|-----------|--------|-------|
| Telegram | Native (this chat) | Live | Primary chat interface |
| Gmail / Drive / Calendar / Docs / Sheets | `gws` skill | Connected | Google Workspace via Python/CLI |
| lapo-brain (QMD) | MCP server `qmd` | Live | 264 notes, local search |
| Granola (meetings) | MCP `granola-mcp-plus` | Live | Auto-imports to `20-meetings/` daily at 7:30am CET |
| Linear | `linear` skill | Connected | Project management |
| Readwise | `readwise-official` skill | Connected | Reading highlights |
| Notion | `notion` skill | Available | API works, not primary source of truth |
| X/Twitter | `xurl` skill | Available | Post, search, DM |
| Spotify | `spotify` skill | Available | Play, queue, playlists |
| Browser | `browser_*` tools | Live | Navigate, click, fill forms, screenshot |
| Himalaya (email CLI) | `himalaya` skill | Available | IMAP/SMTP backup |
| WhatsApp | `wacli` | **NOT INSTALLED** | Need to install and wire up |
| iMessage / SMS | `imsg` | **NOT POSSIBLE** | macOS only, this is Linux |
| Local files | `read_file`, `write_file`, `terminal` | Live | Full filesystem access |

Screen automation is a dead end on this headless Linux box. Browser automation is the fallback for messy web apps (FasTrak, parking, insurance, DMV).

## Data Layer

My primary source of truth is **lapo-brain**, not Google Drive. Drive is secondary. This is the main divergence from Nicolas's setup.

```
PRIMARY SOURCE OF TRUTH: lapo-brain (~/lapo-brain)
  00-weekly/          weekly plans, Monday briefings, Friday reviews, Sunday planning
  10-projects/        Catone, CEG, Klaaryo
  20-meetings/        Granola imports (auto-daily)
  20-personal/        personal admin, agent stack, car docs, family docs
  20-projects/        project docs
  30-people/          people notes
  40-targets/         BD targets
  50-resources/       readings, references
  60-health/          health tracking
  90-archive/         old stuff
  99-backlog/         capture inbox
  AGENTS.md           vault conventions
  ANDY.md             agent instructions
  CAPTURE.md          inbox

SECONDARY: Google Drive
  Exported Notion pages
  Car docs (mirror)
  Family docs (mirror)
  PDFs
  Spreadsheets

NOT YET BUILT:
  contacts.csv        phone, email, LinkedIn, categories, locations, notes, last contact
  wacli connection    WhatsApp messages, chats
```

The article says: "You should not organize your knowledge only for the human UI. You should organize it for the agent's tool path. Agents like stable file IDs, text, tables, Markdown, CSVs, and commands that return JSON."

lapo-brain is already Markdown-native and searchable via QMD. That is the right primary layer. Drive holds mirrors and exports.

## Contacts Gap

I do *not* have a centralized contacts.csv yet. The article calls this "one of my best investments." This is a blocker for cross-tool person lookup.

Needed fields:
- Name
- Phone
- Email
- LinkedIn
- Category (investor, friend, founder, recruiter, family, etc.)
- Location
- Notes
- Last contact date
- Source (where I know them from)

Options:
1. Google Sheet mirrored to CSV in Drive, synced locally
2. Structured Markdown note in lapo-brain
3. Both: Sheet for editing, CSV for agent consumption, synced via cron

## Skills (Recurring Workflows)

Already have:
- `google-workspace` — Gmail/Drive/Calendar ops
- `linear` — Project management
- `linear-pm-ops` — Active PM auditing
- `readwise-official` — Reading library
- `lapo-brain` — QMD queries
- `web-research-publishing` — Research + publish
- `agent-cron-patterns` — Recurring automation
- `notion` — Notion API ops
- `xurl` — X/Twitter
- `himalaya` — Email CLI
- `obsidian` — Vault editing

Need to build:
- `inbox-zero` — Gmail triage: list inbox, separate auto-archive from needs-review, show important emails, quote substance, suggest archive or reply, draft replies, wait for explicit approval, send in original thread, preserve all recipients, archive only after sending, keep replies short, never suggest calls unless I ask, sign with "Lapo"
- `contacts` — Lookup by name, category, location. Cross-reference with lapo-brain people notes.
- `weekly-sync` — Monday briefing, Friday review, Sunday planning
- `what-did-i-miss` — Cross-tool life inbox triage

Skill improvement loop: tool fails once → fix tool or add guardrail. Agent makes judgment mistake → update skill. Agent forgets preference → write to memory or AGENTS.md. Workflow repeats → agent improves.

## Approval Gates

| Tier | Action | Gate |
|------|--------|------|
| Read-only | Scan, search, summarize | Auto |
| Draft | Write email, message, doc | Show me, wait for approval |
| Send | Email, Telegram, WhatsApp, X | Explicit approval unless stakes are trivial |
| Delete / Pay / Sign / Account change | Never | Manual only |

Rules:
- Draft before sending important messages.
- Sign emails as *Lapo*.
- Use `gws` for Google Workspace.
- Use `wacli` for WhatsApp (when installed).
- Use Telegram connector for Telegram.
- Use contacts.csv for email and phone lookup (when built).
- Prefer APIs and CLIs over browser automation.
- Do not expose private data unless asked.
- Confirm after sending.
- Save all outputs to ~/lapo-brain/, never temp.

## The Killer Workflow: "What Did I Miss?"

Every few hours, or on demand:

1. Scan Telegram (this chat history, unread)
2. Scan Gmail (inbox, flagged)
3. Scan WhatsApp (when wacli is live)
4. Check Calendar (upcoming, conflicts)
5. Check Linear (assigned issues, due soon)
6. Check Granola / `20-meetings/` (action items)
7. Check lapo-brain / CAPTURE.md (backlog)
8. Report: who needs a reply, what's urgent, what's stale, what can be ignored, what should become a calendar event or a Linear issue

This is the perfect agent task: context-heavy, repetitive, cross-tool, full of small decisions. Humans hate the first pass. Agents are good at first passes. Judgment still belongs to me.

The result is not that my life becomes autonomous. The result is that I stop being the person manually digging through five apps to discover the three things that matter.

## Real Communication Example (Adapted to My Setup)

Friend texts on Telegram: "Can you intro me to that recruiter you know?"

Agent should:
1. Read the Telegram thread
2. Search lapo-brain for recruiter contact (or contacts.csv when built)
3. Search Gmail for last interaction with recruiter
4. Research the company if needed (web search)
5. Draft intro email
6. Show draft, wait for approval
7. Send email via `gws`
8. Reply on Telegram: "Intro sent."

Currently blocked on: contacts lookup. I have to manually remember or search.

## License Plate / Car Docs Example (Adapted)

I got a new license plate. Agent should:
1. Update car info Markdown file in `20-personal/car-docs.md`
2. Change license plate, add registration notes
3. Preserve existing VIN, insurance, owners, address
4. Sync to Google Drive if mirror exists
5. Use browser automation to update FasTrak, parking app, insurance portals, DMV forms

Currently: no car-docs.md exists. Need to create it.

## Gaps & Blockers

1. **wacli not installed** — WhatsApp is invisible to the agent. Need to install and authenticate.
2. **imsg not possible** — iMessage is macOS-only. This Linux box can't do it. Workaround: use iPhone or Mac for SMS, or accept that SMS stays manual.
3. **No contacts.csv** — Cross-tool person lookup is broken. Need to build this.
4. **No car-docs.md** — Vehicle info scattered or not digitized.
5. **Browser automation is brittle** — For FasTrak, DMV, insurance portals. Works but needs babysitting.
6. **No "what did i miss" skill yet** — Need to codify the cross-tool scan.
7. **No "inbox-zero" skill yet** — Need Gmail triage procedure with my taste.

## What I Actually Have Today

I can already do:
- Search lapo-brain via QMD
- Read/write files in the vault
- Browse the web
- Send Telegram messages (this chat)
- Query Google Workspace (via gws skill)
- Query Linear
- Query Readwise
- Query Granola
- Query Notion
- Post to X
- Control Spotify
- Run cron jobs

What I cannot do yet:
- Read/send WhatsApp messages
- Read SMS/iMessage
- Look up contacts in a centralized CSV
- Run a life-inbox triage across all channels

## Next Steps (Prioritized)

1. **Install wacli and authenticate WhatsApp** — Biggest gap. Most of my contacts are there.
2. **Build contacts.csv** — Export from Google Contacts or manual. This unlocks cross-tool person lookup.
3. **Create car-docs.md** — Centralize vehicle info.
4. **Write `inbox-zero` skill** — Gmail triage with my taste.
5. **Write `what-did-i-miss` skill** — Cross-tool life inbox scan.
6. **Test cross-tool workflow** — Telegram → lapo-brain → Gmail → Calendar.

## Operating Rules

```markdown
# Personal Agent Rules

- Draft before sending important messages.
- Sign emails as Lapo.
- Use gws for Gmail, Drive, Calendar, Docs, and Sheets.
- Use wacli for WhatsApp (when installed).
- Use Telegram connector for Telegram.
- Use contacts.csv for email and phone lookup (when built).
- Prefer APIs and CLIs over browser automation.
- Do not expose private data unless asked.
- Confirm after sending.
- Save all outputs to ~/lapo-brain/, never temp.
```

## Key Insight

"The first useful personal agents will not look like polished consumer apps. They will look like a model inside a terminal with access to your files, accounts, memories, and tools."

That is what I have today with Hermes. Every week I should give it one more piece of my life to operate.
