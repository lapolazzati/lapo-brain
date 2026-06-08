---
type: Note
related_to:
  - "[[ai-coding]]"
  - "[[loops]]"
  - "[[claude-code]]"
source: "https://x.com/mvanhorn/status..."
date: "2026-06-08"
author: "Matt Van Horn"
---

# WTF Is a Loop?

**Author:** Matt Van Horn (@mvanhorn)  
**Date:** 2026-06-08  
**Source:** X/Twitter long-form article

## One-Liner

A loop is a small program you write that prompts the coding agent for you, reads what it produced, decides whether it is done, and if not, prompts it again. You stop being the thing inside the loop typing prompts. You become the author of the loop. The model becomes a subroutine.

## The Tweet That Started It

> "Here's your monthly reminder that you shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents."
> 
> — Peter Steinberger (@steipete), June 7, 2026 — 2.2M views

The replies turned into a brawl over what "loop" actually meant. The most telling reply came from Matthew Berman: *"nobody knows but him and boris."*

## Boris Cherny's Definition (Canonical)

> "Now it's actually leveled up, I think, again, to the next wave of abstraction where I don't prompt Claude anymore. I have loops that are running. They're the ones that are prompting Claude and figuring out what to do. My job is to write loops."
>
> — Boris Cherny, WorkOS Acquired Unplugged, June 2, 2026

Boris tells it as three stages:

1. **A year ago:** Wrote code by hand with autocomplete
2. **Then:** Ran 5-10 Claude sessions in parallel and prompted each one
3. **Now:** Does not prompt at all. Writes loops that prompt Claude. Couple hundred agents read his GitHub, Slack, and Twitter and decide what to build next.

He deleted his IDE in November 2025 and has not opened it since.

## The Spectrum: 5 Stages of Loop Evolution

1. **ReAct (2022):** Academic while-loop. Model reasons → calls tool → reads result → repeats until done. One model, one loop, human watching.
2. **AutoGPT (2023):** Gave model a goal and let it prompt itself. Famous for spinning forever doing nothing.
3. **ralph loop (July 2025):** Bash one-liner by Geoffrey Huntley that pipes same prompt file into agent repeatedly. Resets context to fixed anchor files. Built full programming language for ~$297.
4. **/goal and /loop (Spring 2026):** Codex and Claude Code ship commands that run ralph loop until validator model confirms task done.
5. **Orchestration loops (Now):** Four changes:
   - Loop = unit of work, not the task
   - Loops supervise other loops concurrently and on schedule
   - Scheduling replaces human kickoff (cron-based)
   - Durability: git-backed state and crash recovery

## Boris's Five Tips for Running Loops

1. Use auto mode for permissions so Claude doesn't ask for approval
2. Use dynamic workflows to orchestrate hundreds/thousands of agents
3. Use /goal or /loop to nudge Claude to keep going until done
4. Use Claude Code in the cloud so you can close your laptop
5. **Make sure Claude has a way to self-verify its work end to end**

## The Deep End

- **Steve Yegge's Gas Town (Jan 2026):** 20-30 Claude Code instances coordinated by a Mayor agent, patrol agents running continuous loops, state stored in git. Open source.
- **Dan Kornas's roborev:** Reviews every commit in background and feeds findings back into agent while context is still fresh.

## The Plot Twist: Loop Is Now the Expensive Part

> "Every ai agent i shipped this year is a for-loop, an llm call, and a try/catch around the json parsing. The only thing agentic about it is the anthropic bill at the end of the month."
>
> — @rohit_jsfreaky

Uber capped engineers at $1,500/person/month for Claude Code and Cursor after burning annual AI budget in 4 months. Once the model writes code for almost nothing, cost moves to the loop running it.

Three hard stops every serious loop needs:
- Max iteration count
- No-progress detection
- Token or dollar budget ceiling

## Matt Van Horn's Take

> "The loop is plumbing. The asset is the skill it calls."

Steinberger's recurring point: if you do something more than once, turn it into an automated skill. If you do something hard, turn it into a skill afterward so next time is free.

A loop with no reusable skills inside it is just a while-true around a stranger. A loop that calls a library of sharp, tested, named skills is a system that compounds.

## Key Patterns

- Loop = cron plus decision-maker in the body (model picks next action each tick, not hardcoded branch)
- Single-agent ralph is old hat; multi-agent supervision is the new layer
- Loop is only as good as its feedback. Continuous review and validation gates make it trustworthy
- Expensive resource shifted from tokens to loop management. Cap iterations, detect no-progress, set dollar budget
- Reusable unit inside the loop is a skill, not a prompt

## Applied to AETHON

See: [[aethon]] → "Aethon as Loops"

Three loops AETHON is building:
1. **Lead Discovery** — Daily scan for companies matching ICP (funding, expansion signals)
2. **Market Validation** — Active lead runs continuous market mapping until go/no-go brief with named contacts
3. **Content-to-Lead** — Weekly distribution of AETHON content to matched prospects, promoting engaged leads to validation
