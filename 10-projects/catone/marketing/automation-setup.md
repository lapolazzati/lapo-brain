---
date: 2026-05-07
type: technical-setup
project: catone
topic: email automation
---

# Catone Email Automation - Technical Setup

## Overview

Automated weekly customer email every Friday 9am Rome time, synthesizing product updates from git commits.

## Architecture

```
Friday 9am → Scheduled Task → Git Pull → Extract Commits → Filter Client-Facing →
Generate Email (Italian, Catone style) → Send Preview to Lapo → Wait for Approval
```

## Scheduled Task

**Task ID:** `1778175502967-ext1at.json`
**Schedule:** `0 7 * * 5` (7am UTC = 9am Rome, every Friday)
**Context:** Group (has access to conversation history and memory)

**Created via:**
```javascript
mcp__nanoclaw__schedule_task({
  prompt: "Genera aggiornamento settimanale Catone...",
  schedule_type: "cron",
  schedule_value: "0 7 * * 5",
  context_mode: "group"
})
```

## Repository Access

**Repo:** https://github.com/lapolazzati/Tax-DueDiligence-Tool
**Auth:** GitHub token embedded in lapo-brain remote URL
**Local clone:** `/workspace/group/Tax-DueDiligence-Tool`

**Get token:**
```bash
cd /workspace/group/lapo-brain
git config --get remote.origin.url
# Extracts GitHub token from remote URL
```

## Email Service (Resend)

**API Key:** Stored in `/workspace/group/.env` as `RESEND_API_KEY`

**Current setup (test mode):**
- From: `onboarding@resend.dev` (Resend test domain)
- To: `lapo.lazzati@gmail.com` (only verified email)

**Production setup (TODO):**
1. Verify `catone.ai` domain on Resend (resend.com/domains)
2. Change from: `Luca di Catone <luca@catone.ai>`
3. Update recipient list with customer emails

**Node.js SDK:**
```bash
npm install resend --legacy-peer-deps
```

## Commit Extraction & Filtering

**Command:**
```bash
git log --since="7 days ago" --pretty=format:"%h|||%an|||%s|||%b" --no-merges
```

**Client-facing (include):**
- Nuove verifiche (LIPE, F24, IVA, RF4, ritenute)
- Classification accuracy improvements
- UI changes (filters, panels, buttons, layout)
- Upload/download improvements
- User-visible bug fixes
- New document types
- Performance improvements users feel

**Internal (exclude):**
- Refactoring, code cleanup, linting
- CI/CD, Docker, deployment
- Database migrations (unless visible feature)
- Monitoring, logging (Langfuse, Sentry)
- Prompt tuning (unless measurable accuracy jump)
- Dependency updates
- Tests
- README/docs
- BullMQ/Redis/worker changes

## Email Template (HTML)

**Style matching:** `/workspace/group/Tax-DueDiligence-Tool/lib/email/onboarding.js`

**Colors:**
- Background: `#f5f4f3`
- Card: `#ffffff`
- Text: `#292524`
- Headings: `#1c1917`
- Accent: `#b45309` (amber)
- Border: `#e7e5e4`

**Fonts:**
- Body: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif`
- Heading: `'Bodoni Moda', serif` (Catone brand)

**Layout:**
- Max width: 564px
- Padding: 36px 32px
- Border radius: 14px
- Dark header with Catone. logo

## Helper Functions

```javascript
const p = (text) =>
  `<p style="margin:0 0 18px;font-size:15px;line-height:1.8;color:#292524;">${text}</p>`;

const h2 = (text) =>
  `<h2 style="margin:28px 0 12px;font-size:17px;font-weight:700;color:#1c1917;letter-spacing:-0.3px;">${text}</h2>`;

const bold = (text) =>
  `<strong style="color:#1c1917;font-weight:600;">${text}</strong>`;

const img = (alt) =>
  `<div style="margin:24px 0;padding:16px;background:#fafaf9;border-radius:8px;border:1px solid #e7e5e4;">
    <p style="margin:0;color:#78716c;font-size:13px;text-align:center;font-style:italic;">
      📸 Screenshot: ${alt}
    </p>
  </div>`;
```

## Catone Skills (Already Built)

Located in repo: `.claude/skills/`

### catone-changelog
- Extracts git commits
- Filters client-facing changes
- Groups into categories (Verifiche, Classificazione, UI, Correzioni, Prestazioni)
- Writes Italian benefit-focused changelog
- Output: `data/marketing/last-changelog.json`

### catone-regulatory
- Monitors Agenzia delle Entrate news
- Tracks deadline changes, risoluzioni, codice tributo updates
- Output: `data/marketing/last-regulatory.json`

### catone-weekly-update
- Combines changelog + regulatory
- Uses template: `.claude/skills/catone-weekly-update/templates/weekly-email.md`
- Generates HTML email + LinkedIn post
- Deduplicates against `data/marketing/updates-log.jsonl`
- Max 500 words
- Subject: `[Catone] {most impactful item} + novità fiscali`

**Voice rules (from SKILL.md):**
- Italian 100%
- Short paragraphs (1-3 sentences)
- Technical terms as commercialisti use them
- No marketing language
- Tone: sharp colleague, not SaaS company

## Approval Workflow

**Current:** Manual approval required
1. Agent generates email
2. Sends preview to lapo@catone.ai
3. Waits for "send it" reply
4. Only then sends to customer list

**Future options:**
- Auto-send unless "stop" within 2 hours
- Always require manual trigger (safest for now)

## Customer List Management

**TODO:** Determine source
- Resend audience/list?
- Database query?
- CSV file?
- For now: just Lapo for testing

## Files & Locations

**Email scripts:**
- `/workspace/group/send-catone-update.js` - V1
- `/workspace/group/send-catone-update-v2.js` - V2
- `/workspace/group/send-v2-final.js` - V2 fixed
- `/workspace/group/catone-update-final-final.js` - V3 FINAL

**Markdown versions:**
- `/workspace/group/catone-update-aprile-maggio.md` - V1 (650 words)
- `/workspace/group/catone-update-v2.md` - V2 (420 words)

**Repo clone:**
- `/workspace/group/Tax-DueDiligence-Tool/` - Main Catone repo

**Skills:**
- `~/.claude/skills/.agents/skills/resend/` - Resend email skill
- `~/.claude/skills/.agents/skills/react-email/` - React email templates
- `~/.claude/skills/.agents/skills/copywriting/` - Marketing copywriting
- 41 marketing skills from coreyhaines31/marketingskills

## Environment Variables

**Required in `/workspace/group/.env`:**
```bash
RESEND_API_KEY=<resend_api_key>
LINEAR_API_KEY=<linear_api_key>
READWISE_TOKEN=<readwise_token>
FIRECRAWL_API_KEY=<firecrawl_api_key>
```

## Testing

**Send test email:**
```bash
export RESEND_API_KEY=$(grep RESEND_API_KEY .env | cut -d'=' -f2)
node catone-update-final-final.js
```

**Check scheduled tasks:**
```bash
mcp__nanoclaw__list_tasks
```

## Production Checklist

Before going live with customer emails:

- [ ] Verify catone.ai domain on Resend
- [ ] Update from address to luca@catone.ai
- [ ] Set up customer email list source
- [ ] Add real screenshots to template (replace placeholders)
- [ ] Test with 1-2 beta customers first
- [ ] Document unsubscribe flow
- [ ] Set up bounce/complaint handling
- [ ] Add email analytics tracking
- [ ] Create LinkedIn post automation
- [ ] Archive sent emails in updates-log.jsonl

## Monitoring

**Email delivery status:**
- Check Resend dashboard: resend.com/emails
- Track open rates, clicks, bounces
- Monitor reply rate (direct to luca@catone.ai)

**Task execution:**
- Check task output in `/workspace/project/.nanoclaw/tasks/`
- Monitor for failed runs
- Set up alerting if email doesn't send

## Rollback Plan

If automation fails:
1. Check task logs
2. Manually run script locally
3. Fix and resend
4. Disable scheduled task if needed: `mcp__nanoclaw__pause_task`
