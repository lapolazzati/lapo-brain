# Capture & Sync workflow

This is how Lapo and Claude keep the brain coherent across phone, desktop, and Claude Code.

## The core loop

```
   📱 Phone (Claude app)              💻 Desktop (Claude Code in this repo)
   ─────────────────────              ──────────────────────────────────────
   "log Vincenzo call"          →     /sync
   "carry to next week"         →     Claude reads conversation memory
   "save: Gianni said €X"       →     Claude writes files, commits, pushes
   voice memo dump              →     Tolaria sees the changes on disk
```

Phone = capture. Desktop = persistence. Claude bridges both.

## Capture (phone, on the go)

Open the Claude app. Say one of these patterns:

- **Log something:** "log this: [content]"
- **Add to a project:** "add to Catone: [content]"
- **Carry forward:** "carry to next week: [content]"
- **Save a fact:** "save this fact: [precise statement, e.g. quote, number, date]"
- **Meeting note:** "meeting note from [person]: [content]"

For anything truly critical (a contract number, a quote, a deadline), explicitly ask Claude to flag it. Claude's memory is good but not perfect — explicit beats implicit.

Voice-to-text works fine. Don't over-format. Capture is dumb on purpose.

## Sync (desktop, in Claude Code)

When Lapo opens a Claude Code session in this repo, the first prompt is:

```
sync
```

What Claude does on `sync`:

1. Reviews what was discussed since the last sync (using memory + recent conversations)
2. Proposes which files to update and what to write
3. Lapo reviews, edits, approves
4. Claude writes the changes
5. Claude commits with a clear message and pushes

Sync should take 5 minutes, not 30. If it's getting long, capture has been too messy — adjust.

## Where things go

| What | Where |
|---|---|
| Weekly priorities, daily log, Friday review | `00-weekly/YYYY-W{N}.md` |
| Project decisions, threads, state | `10-projects/{project}/README.md` or sub-files |
| Meeting notes (Granola dumps, raw notes) | `20-meetings/YYYY-MM-DD-slug.md` |
| Person-specific context | `30-people/{name}.md` |
| Inactive but worth keeping | `90-archive/` |

If Claude isn't sure where something goes, default to the current weekly file under "Notes & threads" — Lapo can move it later.

## The Sunday ritual

Every Sunday evening (after Mira's down):

1. Open `00-weekly/YYYY-W{N+1}.md` (create from `_template.md`)
2. Run a sync to pull anything still pending from the week
3. Fill the three priority slots — one per project, max
4. Calendar reality check
5. Commit with message: `Week {N+1} plan`

If a project doesn't earn a slot this week, that's data. Three weeks in a row = it's time to talk about whether it's still active.

## The Friday close

Friday afternoon, before logging off:

1. Open the current weekly file
2. Fill in "End-of-week review"
3. Commit with message: `Week {N} close`

This keeps Sunday's planning honest.

## What Claude won't do

- Won't invent new top-level folders without asking
- Won't archive a project without Lapo's explicit say-so
- Won't auto-commit without showing the diff first
- Won't pretend memory is perfect — for critical facts, will always ask Lapo to confirm

## What Lapo shouldn't do

- Don't try to keep everything in your head between phone and desk. That's what this is for.
- Don't skip the Sunday ritual three weeks in a row. The system decays fast.
- Don't add a fourth active project without a real conversation about what comes off the list.
