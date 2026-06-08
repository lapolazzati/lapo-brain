---
type: Note
---
# AETHON

# Aethon

### International Expansion Intelligence

Date: 2026-06-04\
\
Status: Draft v1

# The 1-Liner

Aethon validates international expansion bets before companies commit capital.

# The Core Thesis

Most companies expand in the wrong order.

They hire local representatives, commission market-entry reports, attend trade shows, and spend six figures before knowing whether buyers actually care.

Aethon flips the sequence.

Before a company commits meaningful capital to a new market, we speak directly with target buyers, channel partners, and market stakeholders to determine whether the opportunity is real, what needs to change, and who matters in the ecosystem.

If the signal is strong, we help open the right doors.

# Positioning Layers

## Short

We validate international expansion bets before companies spend.

## Medium

Aethon works with founders and leadership teams before they commit significant resources to a new market.

We conduct direct conversations with buyers, partners, and industry stakeholders to test whether demand exists, identify what must change, and uncover the fastest path to market.

If the opportunity is real, we help open the right doors.

## Long

International expansion is often treated as an execution problem.

In reality, it is a validation problem.

Most companies spend money before they acquire truth.

Aethon acquires truth first.

We run direct business-development conversations with prospective buyers, partners, regulators, and industry participants inside the target market. We extract what they actually need, what they currently use, what would make them switch, and what would prevent adoption.

The result is not a report.

It is evidence.

Evidence that tells leadership whether to invest, what to change, how to position, who to target, and which relationships matter.

When the signal is strong, we help convert those conversations into commercial opportunities.

# Why Aethon

In Homer's Odyssey, Aethon is the name Odysseus uses upon returning to Ithaca before revealing his identity.

The name means "the burning one."

The symbolism is deliberate.

Successful market entry rarely belongs to the loudest entrant. It belongs to the company that understands the terrain before it acts.

Aethon represents disciplined expansion driven by intelligence rather than assumption.

# What We Actually Do

## 1. Market Mapping

We define:

- Ideal customer profile
- Buyer personas
- Market structure
- Competitive alternatives
- Channel ecosystem
- Regulatory constraints

Output: Expansion hypothesis and target-account universe.

## 2. Buyer Validation

We conduct direct conversations with:

- Prospective customers
- Strategic partners
- Industry operators
- Distributors
- Market influencers

The objective is not selling.

The objective is discovering truth.

Output: Validated demand signal and buyer intelligence.

## 3. Strategic Refinement

We translate market feedback into decisions.

Potential outcomes:

- Product adaptation
- Pricing adjustment
- Positioning changes
- Partnership strategy
- Market prioritization

Output: Evidence-based go-to-market strategy.

## 4. Door Opening

Where appropriate, we convert validated relationships into commercial opportunities.

This can include:

- Customer introductions
- Partner introductions
- Distribution discussions
- Strategic relationship building

Output: Qualified pipeline and market access.

# Ideal Clients

Aethon works best with:

- Founder-led companies
- 10–100 employees
- Proven product in a home market
- Considering international expansion
- Willing to validate before committing

# Not For

- Companies that have already made the expansion decision
- Procurement-heavy consulting engagements
- Market-entry reports with no stakeholder conversations
- Organizations seeking execution-only support

# Engagement Model

Structure:

- Monthly retainer
- Performance-based upside where appropriate

Typical engagement:

- 3–6 months
- Single market focus
- Direct founder access

# Evidence

## Klaaryo → Brazil

HR technology platform evaluating expansion into Brazil.

Work included:

- ICP validation
- Buyer interviews
- TAM assessment
- Positioning refinement
- Ecosystem mapping
- Strategic introductions

Result:

Leadership gained evidence-based conviction regarding market opportunity, product adaptations, and expansion priorities.

## CEG → Italy

Bioremediation company assessing commercial opportunities in Italy.

Work includes:

- Regulatory ecosystem mapping
- Buyer identification
- Partner development
- Market-entry strategy

Result:

Commercial strategy built around validated regulatory and ecosystem realities rather than assumptions.

# Aethon Principle

Don't enter a market because a spreadsheet says you should.

Enter because the people who will buy have already told you why they will.

# Aethon as Loops

Inspired by: [[wtf-is-a-loop-matt-van-horn]]

AETHON is a system of loops. The model does the prompting. We write the loops.

## Loop 1: Lead Discovery

**Trigger:** Daily (cron)
**What it does:** Monitors funding announcements (Crunchbase, TechCrunch, local VC blogs), LinkedIn signals, and industry news for companies matching AETHON's ICP.

**ICP filter:**
- Founder-led
- 10–100 employees
- Recently raised Series A/B ($5M–$50M)
- Announcing or signaling international expansion
- Home-market product proven

**Output:** Auto-generated lead brief (company profile, expansion signals, why AETHON fits, outreach angles) dropped into `10-projects/Consulting/leads/`. Sends alert to Lapo + partner Slack.

**Example in the wild:** Lucis Life — caught via WhatsApp forward, but the loop should have surfaced it from the $20M Series A announcement before that.

## Loop 2: Market Validation

**Trigger:** Human kickoff (when a lead is promoted to active)
**What it does:** Runs a continuous validation cycle against the target market until it produces a go/no-go brief with named contacts.

**Each iteration:**
1. Map the target market (partners, regulators, competitors, buyers)
2. Identify 3–5 named individuals with LinkedIn + email where possible
3. Draft outreach messages personalized to each
4. Check for warm intro paths (investor network, alumni, mutual contacts)
5. Verify regulatory pathway (e.g., ANVISA for health tech in Brazil)
6. Publish strategy brief to here.now for partner review

**Stopping condition:**
- Brief delivered with ≥3 verified contacts and a validated partnership angle, OR
- Red flag discovered that kills the hypothesis (e.g., target company already has local team)

**Example in the wild:** Lucis Life → Fleury partnership hypothesis, validated via public partnership history + CEO LinkedIn mapping.

## Loop 3: Content-to-Lead

**Trigger:** Weekly (cron) + on new content publish
**What it does:** Monitors AETHON's content pipeline (case studies, market briefs, expansion playbooks) and auto-distributes to relevant prospects with personalized angles.

**Each iteration:**
1. Scan published content (lapo-brain, here.now hosted pages, LinkedIn posts)
2. Match content to active and cold leads by industry, geography, or expansion stage
3. Draft personalized outreach: "Saw you raised $X / announced Y — we just published a brief on [relevant market] that may be useful"
4. Send via LinkedIn or email (human-approved for now)
5. Track engagement signals (views, replies, clicks)
6. When engagement threshold hits, promote lead to Loop 2

**Stopping condition:**
- Lead promoted to active (Loop 2), OR
- 3 touches with no engagement → deprioritize

## What We Still Need

- [ ] Funding/news API feed (Crunchbase API, PitchBook, or RSS aggregation)
- [ ] LinkedIn monitoring for expansion signals (hiring in new market, founder posts)
- [ ] Automated lead brief generation (structured output from research agent)
- [ ] Warm intro pathfinder (graph Lapo's network vs. target company investors/advisors)
- [ ] Content engagement tracking (UTM params on here.now links, LinkedIn analytics)

## The Principle

> A loop with no reusable skills inside it is just a while-true around a stranger. A loop that calls a library of sharp, tested, named skills is a system that compounds.
>
> — Matt Van Horn

AETHON's skills are:
- BD research (the bd-research skill in Hermes)
- Market validation briefs
- here.now publishing
- lapo-brain note creation

The loops are the cron jobs that call these skills on repeat.
