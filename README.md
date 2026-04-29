# lapo-brain

Second brain for Lapo. Markdown files, Git, Tolaria, Claude Code.

## Why this exists

Three live commitments need a single source of truth so nothing slips:

- **Catone** — equity bet, AI tax due diligence for Italian commercialisti
- **CEG** — equity bet, bioremediation Italian market entry
- **Klaaryo** — paying consulting, keeps the cashflow alive

Plus one weekly ritual that ties it all together.

## Folder structure

```
00-weekly/        Weekly plans + logs. The keystone. One file per ISO week.
10-projects/      One folder per active project. Notes, decisions, artefacts.
20-meetings/      Granola dumps and meeting notes. Date-prefixed filenames.
30-people/        One file per key contact (Gianni, Vincenzo, Peter, etc.)
90-archive/       Stuff that's no longer active but worth keeping.
```

Three project folders, three commitments. If a fourth folder shows up in `10-projects/`, something has gone wrong — either an old commitment needs killing or a new one needs a real conversation.

## The weekly ritual

**Sunday evening, after Mira's down.**

1. Open `00-weekly/YYYY-W{N}.md` (create from `_template.md` if needed)
2. Fill in three sections:
   - **Top 3 priorities** — one per project, maximum
   - **Calendar reality check** — what's scheduled vs what should be
   - **End-of-week log** — what shipped, what slipped, what surprised (filled Friday close)
3. Commit and push

The weekly file is where Lapo and Claude collaborate. Anything that doesn't earn a slot in a weekly priority gets honest about whether it matters.

## Working with Claude Code

Tolaria exposes an MCP server. Claude Code can read, write, and commit notes directly. When Lapo opens a Claude Code session in this repo, expect Claude to:

- Read `00-weekly/` to understand current focus
- Read relevant `10-projects/` folder for project context
- Write meeting notes into `20-meetings/` after Granola transcripts
- Update `30-people/` after meaningful interactions
- Never invent new top-level folders without asking

## File naming conventions

- Weekly: `2026-W18.md` (ISO week)
- Meetings: `2026-04-29-vincenzo-tax-coach.md` (date + slug)
- People: `gianni-rizzi.md` (kebab-case)
- Projects: kebab-case folders, README.md inside each

## What this is not

- Not PARA. Not Zettelkasten. Not a knowledge graph.
- Not a place to over-build before selling.
- Not a substitute for shipping.

The system is not the work.
