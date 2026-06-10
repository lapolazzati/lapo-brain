---
title: "feat: Downloads Marie Kondo — age-out cleanup + weekly launchd schedule"
type: Plan
status: active
created: 2026-06-10
related_to: "[[personal-agent-stack]]"
---
# feat: Downloads Marie Kondo — age-out cleanup + weekly launchd schedule

## Summary

Two deliverables: (1) a bash script that moves any file/folder in `~/Downloads` root that was downloaded more than 2 days ago AND has never been opened into `~/Downloads/_delete/`, plus (2) a launchd agent that runs it every Saturday at 9 AM — and again Monday at 9 AM if the laptop was closed Saturday. Files opened even once are kept. Mirrors the dry-run pattern from `~/Developer/docs/organize.sh`.

***

## Problem Frame

`~/Downloads` has accumulated 511 items spanning months. The Marie Kondo rule: if it hasn't been touched after 2 days of landing, it doesn't spark joy. Weekly automation keeps the folder clean going forward without manual effort.

***

## Requirements

- R1: A file or directory moves to `~/Downloads/_delete/` only when **both** conditions are true: (a) downloaded more than 2 days ago, and (b) never opened — `kMDItemLastUsedDate` is absent or `kMDItemUseCount` is 0. Opening a file even once marks it as a keeper regardless of age.
- R2: `_delete/` itself is never processed recursively — already-staged items are not double-moved
- R3: Hidden files (`.DS_Store`, `.localized`) are ignored
- R4: Script runs in DRY_RUN mode by default, printing moves without executing them
- R5: launchd fires the script at Saturday 9:00 AM each week
- R6: If Saturday was missed (lid closed), launchd fires again at Monday 9:00 AM — script checks a lockfile and skips if this week's Saturday run already completed
- R7: Script and plist live in standard macOS user locations (`~/Library/Scripts/`, `~/Library/LaunchAgents/`)

***

## Key Technical Decisions

**KTD1: Two-condition check — download age + never-opened — via Spotlight metadata.**\
The script reads two `mdls` fields per entry: `kMDItemDownloadedDate` (when it landed in Downloads) and `kMDItemLastUsedDate` (last time any app opened it). A file is a candidate only when the download date is > 2 days ago **and** `kMDItemLastUsedDate` returns `(null)` (never opened). If `kMDItemDownloadedDate` is absent (manually copied files), the script falls back to `mtime` for the age check while still requiring `kMDItemLastUsedDate` to be null before moving.

**KTD2: Saturday + Monday dual** `StartCalendarInterval` **with a week-based lockfile.**\
A single plist entry with both weekdays eliminates a second plist file. The script writes the ISO year-week (`date +%G-%V`) to `~/.downloads-organized-week` on successful completion. The Monday invocation reads the lockfile and exits immediately if the current year-week is already recorded. No lockfile or stale week = run proceeds.

**KTD3:** `_delete/` **is a dated subfolder, not a flat dump.**\
Each run moves items into `~/Downloads/_delete/YYYY-MM-DD/`, keeping the graveyard scannable. The user manually empties `_delete/` when satisfied — no auto-purge, consistent with how macOS Trash works.

**KTD4: Dry-run by default, same pattern as** `~/Developer/docs/organize.sh`**.**\
`DRY_RUN="${DRY_RUN:-true}"`. The initial one-time cleanup follows the same workflow: preview first, then `DRY_RUN=false` to execute.

***

## Output Structure

```text
~/Library/Scripts/
└── organize-downloads.sh        ← main script (R4, R6)

~/Library/LaunchAgents/
└── com.user.organize-downloads.plist   ← scheduler (R5, R6)

~/Downloads/
└── _delete/
    └── 2026-06-10/              ← created per run
        └── ...aged-out items...
```

***

## Implementation Units

### U1. Write `organize-downloads.sh`

**Goal:** Bash script that ages out stale Downloads items with dry-run safety and week-lockfile guard.

**Requirements:** R1, R2, R3, R4, R6

**Dependencies:** none

**Files:**

- `~/Library/Scripts/organize-downloads.sh` (create)

**Approach:**

1. Read `DRY_RUN` env var (default `true`).
2. Check lockfile `~/.downloads-organized-week` — if it contains the current ISO year-week (`date +%G-%V`), print "already ran this week" and exit 0.
3. Compute the cutoff: 2 days ago in epoch seconds.
4. Iterate over top-level entries in `~/Downloads` (use a `while IFS= read -r -d ''` loop with `find -maxdepth 1 -mindepth 1`), skipping:
   - `_delete` directory
   - Hidden names (`.` prefix)
5. For each entry, evaluate both conditions:
   - **Age**: read `mdls -raw -name kMDItemDownloadedDate "$entry"`. If `(null)`, fall back to `stat -f "%Sm" -t "%s"` (mtime as epoch). Age > 2 days = condition A met.
   - **Never opened**: read `mdls -raw -name kMDItemLastUsedDate "$entry"`. If result is `(null)` = condition B met.
6. Add to move list only if **both** A and B are true.
7. Create `~/Downloads/_delete/$(date +%Y-%m-%d)/` destination.
8. Print every move (`mv "$entry" → _delete/DATE/`). If `DRY_RUN=false`, execute the move.
9. On success (at least one item processed or zero items found), write current year-week to lockfile.

**Patterns to follow:** `~/Developer/docs/organize.sh` — same header comment block, same `DRY_RUN` guard, same `move()` function pattern, same summary footer.

**Test scenarios:**

- File downloaded 3 days ago, never opened → appears in move list
- File downloaded 3 days ago, opened once → excluded (kMDItemLastUsedDate is set)
- File downloaded 1 day ago, never opened → excluded (too recent)
- `_delete/` directory itself → never included in move list
- `.DS_Store` → excluded
- Directory older than 2 days, never opened → included in move list
- `kMDItemDownloadedDate` absent → `mtime` fallback used for age, never-opened check still applies
- Lockfile already contains current week → script exits 0 with "already ran" message
- `DRY_RUN=false` → files actually moved; lockfile written

**Verification:** Run `DRY_RUN=true bash ~/Library/Scripts/organize-downloads.sh` — output lists expected files. Run with `DRY_RUN=false` — files are in `~/Downloads/_delete/YYYY-MM-DD/` and `~/.downloads-organized-week` contains the current year-week.

***

### U2. Write `com.user.organize-downloads.plist` and load it

**Goal:** launchd agent that fires the script Saturday 9 AM + Monday 9 AM.

**Requirements:** R5, R6, R7

**Dependencies:** U1 (script must exist before loading)

**Files:**

- `~/Library/LaunchAgents/com.user.organize-downloads.plist` (create)

**Approach:**

Plist structure:

- `Label`: `com.user.organize-downloads`
- `ProgramArguments`: `["/bin/bash", "-l", "/Users/lapolazzati/Library/Scripts/organize-downloads.sh"]` — use `-l` login shell so PATH includes Homebrew and Spotlight `mdls`
- `EnvironmentVariables`: `{"DRY_RUN": "false"}` so the scheduled run always executes
- `StartCalendarInterval`: array with two dicts — `{Weekday: 6, Hour: 9, Minute: 0}` (Saturday) and `{Weekday: 1, Hour: 9, Minute: 0}` (Monday)
- `StandardOutPath`: `~/Library/Logs/organize-downloads.log`
- `StandardErrorPath`: `~/Library/Logs/organize-downloads-error.log`

After writing the plist, load it with `launchctl load ~/Library/LaunchAgents/com.user.organize-downloads.plist`.

**Patterns to follow:** `~/Library/LaunchAgents/com.user.k68-keymap.plist` for the basic plist skeleton.

**Test scenarios:**

- `launchctl list | grep organize-downloads` → shows the agent loaded
- `launchctl start com.user.organize-downloads` → triggers an immediate run; check `~/Library/Logs/organize-downloads.log` for output
- After a run, `~/.downloads-organized-week` contains the current year-week
- Second consecutive `launchctl start` same week → log shows "already ran this week", no files moved

**Verification:** Agent appears in `launchctl list`; log file is created and shows script output on a manual trigger.

***

### U3. Initial one-time cleanup of 511 existing files

**Goal:** Apply the Marie Kondo rule immediately to clear the current Downloads backlog.

**Requirements:** R1, R2, R3, R4

**Dependencies:** U1

**Files:** no new files — runs the script from U1

**Approach:**

1. Run `DRY_RUN=true bash ~/Library/Scripts/organize-downloads.sh` → review the list.
2. Spot-check: confirm any files you want to rescue are moved manually before the next step.
3. Run `DRY_RUN=false bash ~/Library/Scripts/organize-downloads.sh` → all stale items land in `~/Downloads/_delete/2026-06-10/`.
4. Review `_delete/` at your leisure; permanently delete the subfolder when done.

Note: for this initial run only, the lockfile week-guard is bypassed because the lockfile doesn't exist yet. Subsequent same-week runs will be blocked by the guard — that is the correct behaviour.

**Test scenarios:**

- Dry run output lists files that are > 2 days old AND never opened (a subset of the 511 — opened files are excluded)
- A newly downloaded file (< 2 days old) is excluded even if never opened
- A file opened even once is excluded regardless of age
- After `DRY_RUN=false`, `~/Downloads` root retains all previously opened files; only untouched old items moved to `_delete/`

**Verification:** `ls ~/Downloads` shows a near-empty root. `ls ~/Downloads/_delete/2026-06-10/ | wc -l` matches the dry-run count.

***

## Open Questions

- **Q1 (deferred):** Should `_delete/` subfolders auto-purge after N days (e.g., 30)? Easily added as a fourth unit — hold a `find ~/Downloads/_delete -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;` pass. Skipped for now to keep the initial scope minimal.
- **Q2 (deferred):** Notification on run? A `osascript -e 'display notification ...'` call could alert how many items were aged out. Adds 3 lines to the script if desired later.
