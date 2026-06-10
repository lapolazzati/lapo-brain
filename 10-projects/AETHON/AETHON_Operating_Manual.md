# AETHON — Operating Manual (SOP v0.1)

> **The one rule:** The founder validates the motion. The pod scales the motion. And every engagement must leave behind a reusable asset — data, a playbook, a relationship, or a skill.

This document is the source of truth for how AETHON works. It lives in the vault on Hefner (`/playbooks/operating-manual.md`), is versioned in git, and is the first thing a new team member reads. If reality and this document disagree, fix one of them the same day.

---

## 1. Operating principles

1. **AI does the repeatable work. Humans do the high-trust work.** Mapping, research, scoring, localization drafts, summaries → machines. Judgment, partners, senior calls, pricing conversations, trust → people.
2. **First mile, zero-to-one.** We validate motions ourselves, then hand them to someone who scales them. The founder is never the high-volume caller for long.
3. **"Stop" is a deliverable.** Kill criteria are written into every engagement before it starts. Recommending a client stop a market entry is a success, not a failure.
4. **Everything compounds.** Project → reusable intelligence → dataset → content → leads → projects. If a piece of work can't feed this loop, question why we're doing it.
5. **No fake certainty.** Every important claim carries a source, a date, and a confidence level. Deliverables distinguish facts, hypotheses, and assumptions.
6. **Be the showcase.** We sell AI-enabled market entry, so our own operation must be the best demo of AI-enabled work the client has ever seen.

---

## 2. The Skill Library

A **skill** is a documented, repeatable workflow triggered by a slash command. Each skill is a markdown file in the vault (`/skills/<name>.md`) that defines: trigger, inputs, steps, tools, output template, QA checklist, and owner. Skills run on Claude (Claude Code / API) with access to the vault and CRM via MCP.

**The iron gate:** no skill output reaches a client or prospect without human review. The skill produces the draft; the architect signs it.

### 2.1 Skill roster

| Command | What it does | Inputs | Output | Status |
|---|---|---|---|---|
| `/marketresearch <company> <country>` | The flagship. Full country-entry pack: company profile, ICP hypothesis, competitor map, regulatory and market risks, funding/hiring signals, localized positioning draft, and a presentation skeleton. (= AETHON Scout) | Company URL, target country, segment | Deck draft + risk memo + competitor map in `/clients/<name>/01-research/` | **Build first** |
| `/brief <person/company>` | Pre-meeting brief: who they are, company status, recent news, likely objections, our angle, what we want from the meeting. | Name + meeting goal | 1-page brief, 30 min before every meeting | **Build first** |
| `/debrief <transcript>` | Post-call processing: summary, objections heard (→ objection library), commitments made, next actions, CRM update draft, learnings tagged to corridor. | Call transcript | CRM entry + vault note in `/clients/<name>/04-learnings/` | **Build first** |
| `/signals <corridor>` | Expansion-intent scan: funding announcements, international hiring, localized websites, partner announcements. Produces ranked list of expansion-ready companies with trigger + intro angle. (= AETHON Signal) | Corridor or fund portfolio | Scored prospect list → CRM | Build second |
| `/accounts <client> <country>` | First 100 target accounts with decision-maker mapping and entry angle per account. | ICP from validation sprint | Account list → CRM + war room | Build second |
| `/partners <client> <country>` | First 30 partners: integrators, platforms, distributors, associations — with technical/commercial fit notes. | Client GTM + country | Partner map | Build second |
| `/localize <client> <country>` | Translate the business, not the language: positioning, outreach scripts, discovery guide, objection handling, pricing logic on **local anchors** (e.g., price vs. local salary cost, never converted EUR). | Validated ICP + home GTM | Localized GTM kit | Build second |
| `/warroom <client>` | Weekly client digest: pipeline movement, meetings, objections, partner status, learnings, next actions. Posted to the client's Slack by the agent after review. | CRM + vault | Weekly digest + dashboard refresh | Build third |
| `/proposal <client>` | Sprint proposal from template: scope, outputs, timeline, pricing, **kill criteria**, out-of-scope list. | Diagnostic notes | Proposal doc | Build third |
| `/cm <client> <country>` | Country-manager install kit: scorecard, role profile, interview guide, candidate-source map, first-90-days plan, pipeline handoff doc. | Validated motion | CM install kit | Build third |
| `/atlas <engagement>` | End-of-engagement packaging: turns accounts, partners, objections, pricing anchors, and process notes into a reusable sector-country dataset. (= AETHON Atlas) | Closed engagement folder | Dataset in `/datasets/<corridor>/` | Build third |

### 2.2 How to build a new skill

1. Run the workflow manually twice. Write down every step, prompt, and source used.
2. Create `/skills/<name>.md` from the skill template: trigger, inputs, steps, output template, QA checklist.
3. Automate the repeatable steps in Claude Code; keep judgment steps as explicit human checkpoints.
4. Run it on a real case side-by-side with the manual version. Diff the quality.
5. Mark it `active` only when its output needed fewer than 15 minutes of human correction twice in a row.

---

## 3. Infrastructure

### 3.1 Hefner — the Brain

The Hefner VPS is repurposed as AETHON's central server. It hosts:

- **The Vault** — a git-backed markdown knowledge base (Tolaria-compatible; any markdown editor works). This is the single source of truth for everything except pipeline state.
- **Datasets** — the Atlas outputs, in versioned folders.
- **The agent runtime** — the client-facing agent and the skill runners.
- **Dashboards** — war-room views served per client.

Access via SSH/Tailscale. Nightly off-server backup of the vault and datasets. Nothing client-confidential leaves Hefner except through reviewed deliverables.

### 3.2 Vault structure

```
/vault
  /playbooks        ← this manual, engagement playbook, templates
  /skills           ← one file per skill (spec + prompts)
  /corridors        ← per-corridor knowledge: brazil, italy, usa, france…
  /clients
    /<client-name>
      00-brief.md          ← who, why, kill criteria, commercial terms
      /01-research         ← /marketresearch output, sources
      /02-gtm              ← localization kit, scripts, pricing logic
      /03-pipeline         ← account & partner lists (mirror of CRM)
      /04-learnings        ← debriefs, objection log, process notes
  /datasets         ← Atlas: packaged sector-country intelligence
  /team             ← onboarding, hiring scorecards, CM bench notes
```

**Source discipline:** every factual claim in research notes ends with `[source — date — confidence: high/med/low]`. No source, no claim.

### 3.3 The agent layer

One **AETHON Agent** instance per client, living in the client's Slack (and ours).

- **Runs on:** Claude via API. The harness stays model-agnostic so we can swap or A/B models (Hermes or otherwise), but default to Claude for agentic reliability and MCP support.
- **It can:** answer market questions from the client's vault folder and the corridor knowledge; post the weekly war-room digest; capture client requests and route them; pull pipeline status from the CRM.
- **It cannot:** make commitments, quote prices, send anything strategy-level without architect review, or access other clients' folders. Strict per-client scoping; every interaction logged to `/clients/<name>/04-learnings/agent-log.md`.
- **Why it matters commercially:** the agent in their Slack *is* the product demo. It's the daily, visible proof that AETHON works differently from a traditional consultancy.

### 3.4 CRM — decision

**Recommendation: Attio** as the system of record for relationships and pipeline.

Why Attio fits AETHON specifically: the business is a relationship graph, not a sales funnel — clients, partners, funds, operators, and CM candidates all interconnect across corridors. Attio's flexible object model lets us model exactly that (custom objects, many-to-many links), it auto-enriches from email/calendar so the network builds itself, the API and MCP support make it agent-friendly, and it's cheap at 1–3 seats.

The honest alternative is **HubSpot** — we know it deeply from client work, and it has sequences + calling built in. But it's funnel-shaped, gets expensive fast, and models "a fund that is also a lead source and whose portfolio companies are prospects" poorly. If we choose HubSpot anyway for familiarity, the data model below still applies. Decide once, by end of month, and don't migrate for at least a year.

**Division of labor (non-negotiable):** the CRM is the *pipeline ledger* — who, what stage, next action, amounts. The Vault is the *brain* — knowledge, research, learnings. CRM records link to vault notes; never duplicate knowledge into CRM fields.

**Data model:**

- Objects: `Company` (tagged: client / prospect / partner / fund / platform), `Person` (tagged: buyer / champion / operator / CM candidate / investor), `Engagement`, `Signal`, `Corridor`.
- **Client pipeline:** Signal → Qualified → Diagnostic → Proposal → Active sprint → Install / Stop → Alumni (Expansion Board).
- **Partner pipeline:** Identified → Contacted → In conversation → Active corridor partner.
- Every record carries a corridor tag (e.g., `EU→BR`, `US→IT`). Corridor views are how we see the compounding.

---

## 4. The engagement playbook

Every engagement follows the Launch OS. Full checklists live in `/playbooks/engagement.md`; this is the skeleton.

1. **Hypothesis (week 0).** Why this country, why now, who buys, which entry mode. Write `00-brief.md` including **kill criteria** agreed with the client (e.g., "if after 30 qualified conversations we have no pilot path, we recommend stop").
2. **Intelligence (weeks 1–3).** Run `/marketresearch`, `/signals`, `/accounts`, `/partners`. Human pass: kill false positives, rank the first 20 conversations.
3. **Localized GTM (weeks 2–4).** Run `/localize`. Pricing is rebuilt on local anchors — what does our price *feel like* locally (a salary? a tool?) — never converted from EUR.
4. **Pipeline activation (weeks 4–12).** Warm intros first, founder-led outreach, partner conversations. Architect takes the first 5–10 calibration calls personally, then hands volume to a local BD operator. `/brief` before every meeting, `/debrief` after every meeting — no exceptions.
5. **Install, govern, or stop (decision gate).** Go/no-go memo against the kill criteria. If go: `/cm` kit and we install the country manager with pipeline. If stop: stop memo + Atlas packaging. Either way, the client gets a clear decision.

**Cadence per engagement:** weekly client call + war-room digest; monthly "how is the relationship" check-in (ask explicitly, log the answer); end-of-sprint decision memo.

**Exit checklist (the compounding rule)** — an engagement is not closed until:
- [ ] Objection library updated (corridor level)
- [ ] Partner map merged into corridor knowledge
- [ ] Pricing anchors recorded
- [ ] Process notes written (what we'd do differently)
- [ ] `/atlas` run and dataset versioned
- [ ] Reference/testimonial asked for
- [ ] One piece of publishable content identified (anonymized market insight)

---

## 5. Quality controls

1. **Human review gate** — no AI output reaches a client unreviewed. The reviewer's name goes on the document.
2. **Source discipline** — source, date, confidence on every claim.
3. **Local validation** — AI finds patterns; only local conversations confirm them. A map without conversations is a hypothesis.
4. **Privacy & compliance** — outreach, enrichment, and data processing respect local law (LGPD, GDPR) and client requirements. When in doubt, ask before scraping.
5. **No fake certainty** — deliverables label facts vs. hypotheses vs. assumptions to validate.

---

## 6. Team & talent

### 6.1 Roles

- **Expansion Architect** (founders, today): owns client relationships, strategy, the first 5–10 calibration calls, senior buyer/partner conversations, go/no-go judgment. Never the volume caller.
- **AI & Research layer**: the skill library + agents. Owned by an architect until a dedicated builder joins.
- **Local BD Operator**: runs the validated motion in-country — volume outreach, calls, follow-up, qualification, CRM hygiene. Escalates senior conversations. Executes the motion; doesn't define it alone.
- **Specialist advisors** (on demand): legal, tax, regulatory, integration — coordinated, never improvised.

### 6.2 Why work at AETHON (the talent pitch)

- You see **many companies and many markets** in a year, not one job in one company.
- You work with an **AI-native toolkit** most consultancies won't have for years — and you leave knowing how to build it.
- There is a **real destination**: the operator who runs a validated motion is first in line to be installed as the country manager — a €100k+ role we are literally paid to fill. AETHON is the best audition in the industry for country-manager careers.
- Small senior team, real responsibility, no pyramid.

### 6.3 Local BD Operator — hiring profile

Hire for: native language + local cultural fluency; 2+ years SDR/BD with phone comfort; structured CRM habits; coachability; hunger for the CM path. Score 1–5 on each via a scorecard in `/team/hiring/`; include a live role-play (cold call + objection) and a written exercise (qualify 10 accounts from a list, explain ranking).

Pay structure: local-market base + per-qualified-meeting bonus + visible CM path. We pay slightly above local market — we are selling trajectory, and we need people clients will later want to hire.

### 6.4 Onboarding (first week)

Day 1: read this manual + the corridor file. Day 2: shadow `/brief` → call → `/debrief` cycle on live meetings. Day 3: run the skills themselves on a practice account. Day 4: role-play the localized script until it sounds native. Day 5: first 10 supervised live touches. Week 2: own a slice of the account list with daily review, moving to weekly.

### 6.5 The CM bench

Every strong operator, candidate, or contact who could one day be a country manager gets tagged `CM candidate` in the CRM with corridor + sector notes. The bench is a sellable asset (AETHON Pod) and our succession plan in one.

---

## 7. Cadence & KPIs

**Weekly (Monday, 30 min):** pipeline review across engagements; pick the 3 conversations that matter this week; skill-building slot (always be automating one thing).
**Weekly (Friday, 30 min):** vault commit — debriefs filed, learnings tagged, CRM clean. If it isn't in the vault, it didn't happen.
**Monthly:** KPI review; one piece of content shipped from engagement data; CM bench review.
**Quarterly:** corridor review — where is knowledge compounding, which corridor do we double down on; pricing review; this manual gets a version bump.

**KPI shortlist:**

| Area | KPI |
|---|---|
| Pipeline | Qualified meetings / week · time to first qualified meeting · pipeline value per engagement |
| Market clarity | Time to go/no-go · validated personas · objections mapped |
| Operating leverage | Founder hours per launch · % of work produced by skills · skill outputs reused across clients |
| Compounding | Datasets shipped per quarter · inbound leads from content · revenue per corridor |
| Talent | Operators on bench · operator → CM conversions |

---

## 8. Document control

- Owner: Lapo. Version: 0.1 (first draft, pre-team).
- Lives at `/playbooks/operating-manual.md` on Hefner; HTML view regenerated on change.
- Review cycle: monthly until the first hire, quarterly after.
- Changes via git commit with a one-line "why".
