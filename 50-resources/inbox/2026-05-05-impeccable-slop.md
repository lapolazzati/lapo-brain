---
type: Article
status: inbox
tags: [design, AI, UI-patterns, product-design, anti-patterns]
shared: 2026-05-05T10:45:20Z
context: "Shared via Twitter by Michael Nguyen (@insights_infra)"
source: https://impeccable.style/slop
Date: 2026-05-05
belongs_to: "[[design]]"
_organized: true
---

# Impeccable Slop - 37 Patterns That Mark AI-Generated Design

## Key Takeaways

• 37 detectable patterns that reveal AI-generated interfaces
• Tool includes detection overlay + Chrome extension to flag these patterns live
• Patterns split into "AI slop" (specific to AI-generated UIs) vs "Quality" (general design mistakes)
• Both 2022 wave (purple gradients, glassmorphism) and 2026 wave documented
• 25 rules run deterministically via CLI, 12 require LLM review

---

## Detailed Notes

### The Problem: AI Design Convergence

**Core insight**: Every wave of AI-generated UIs converges on a recognizable aesthetic. The patterns just change over time.

**2022 wave**:
- Purple gradients everywhere
- Glassmorphism
- Neon glow effects
- Dark mode by default

**2026 wave** (evolved but still detectable):
- Side-tab cards (thick colored border on one side)
- Inter font everywhere (no typographic hierarchy)
- Everything centered
- Hero metric layouts
- Identical card grids

### The Solution: Impeccable Detection System

**Three ways to use**:
1. `npx impeccable detect` - CLI for files
2. Browser extension - one-click on any tab
3. `/impeccable critique` - LLM design review with overlay

**How it works**:
- Deterministic rules (25): Run on HTML/CSS without needing browser
- Browser-based rules: Require real layout calculation
- LLM-only rules (12): No deterministic detector, caught during AI review

### The 37 Patterns (By Category)

#### Visual Details (6 rules)

**AI Slop patterns**:
1. **Border accent on rounded element** - Thick accent border clashes with border-radius
2. **Glassmorphism everywhere** - Blur effects as decoration not solving real layering
3. **Reaching for modals by reflex** - Lazy design default, interrupts user
4. **Rounded rectangles with generic drop shadows** - Safest, most forgettable shape
5. **Side-tab accent border** ⭐ - THE most recognizable AI tell (thick colored border on one side)
6. **Sparklines as decoration** - Tiny charts conveying no real information

#### Typography (6 rules)

**AI Slop patterns**:
1. **Flat type hierarchy** - Font sizes too close (need 1.25+ ratio between steps)
2. **Icon tile stacked above heading** ⭐ - Universal AI feature-card template
3. **Monospace as "technical" shorthand** - Lazy stereotype instead of real type choices
4. **Overused font** ⭐ - Inter, Roboto, Fraunces, Geist, Plus Jakarta Sans, Space Grotesk
5. **Single font for everything** - No typographic hierarchy

**Quality patterns**:
6. **All-caps body text** - Hard to read (we recognize words by shape)

#### Color & Contrast (6 rules)

**AI Slop patterns**:
1. **AI color palette** ⭐ - Purple/violet gradients and cyan-on-dark
2. **Dark mode with glowing accents** - Default "cool" look with colored box-shadows
3. **Defaulting to dark mode for "safety"** - Retreating from a decision
4. **Gradient text** - Decorative rather than meaningful, kills scannability

**Quality patterns**:
5. **Gray text on colored background** - Washed out, use darker shade of background color
6. **Pure black background** - #000000 looks harsh, tint toward brand hue

#### Layout & Space (7 rules)

**AI Slop patterns**:
1. **Everything centered** - Every text element center-aligned by default
2. **Hero metric layout** ⭐ - Big number, small label, three supporting stats, gradient accent
3. **Identical card grids** ⭐ - Same-sized cards with icon + heading + text repeated
4. **Monotonous spacing** - Same spacing value everywhere, no rhythm
5. **Nested cards** - Cards inside cards creating visual noise
6. **Wrapping everything in cards** - Not everything needs a bordered container

**Quality patterns**:
7. **Line length too long** - Over ~80 characters makes eye lose place

#### Motion (2 rules)

**AI Slop patterns**:
1. **Bounce or elastic easing** - Feels dated and tacky

**Quality patterns**:
2. **Layout property animation** - Animating width/height causes jank, use transform/opacity

#### Interaction (2 rules)

**Quality patterns**:
1. **Every button is a primary button** - No hierarchy when everything shouts equally
2. **Redundant information** - Intros restating headings, labels repeating titles

#### Responsive (1 rule)

**Quality patterns**:
1. **Amputating features on mobile** - Hiding critical functionality because inconvenient

#### General Quality (7 rules)

**Quality patterns**:
1. **Cramped padding** - Text too close to edge (need 8-16px minimum)
2. **Justified text** - Creates rivers of whitespace without hyphenation
3. **Low contrast text** - Fails WCAG AA (need 4.5:1 body, 3:1 large text)
4. **Skipped heading level** - h1 → h3 breaks document outline for screen readers
5. **Tight line height** - Below 1.3x makes multi-line text hard to read (use 1.5-1.7)
6. **Tiny body text** - Below 12px hard to read (use 14-16px minimum)
7. **Wide letter spacing on body text** - Above 0.05em disrupts character groupings

---

## The Most Recognizable AI Tells (Top 5)

1. **Side-tab cards** - Thick colored border on one side of rounded card
2. **Icon tile stacked above heading** - Rounded-square icon container above heading
3. **Overused fonts** - Inter/Roboto/Geist on everything
4. **Hero metric layouts** - Big number + small label + three stats + gradient
5. **Identical card grids** - Icon + heading + text repeated endlessly

---

## 11 Synthetic Slop Specimens

The tool ships with 11 example pages demonstrating each pattern:

1. Purple Gradients Everywhere
2. Lazy "Cool" (glassmorphism, neon glows, blurred orbs)
3. Lazy "Impact" (bouncing buttons, wiggling icons, gradient text)
4. Side-Tab Cards
5. Cardocalypse (5 levels of nesting)
6. Copy-Paste Layouts (same hero-metric-features template)
7. Inter Everywhere (one font for everything)
8. Massive Icons (decoration bigger than message)
9. Bad Contrast Choices
10. Redundant UX Writing
11. Modal Abuse (complex settings crammed in modal)

---

## Application to Our Work

### For Catone

**Current risk assessment**: Need to audit Catone's UI against these patterns.

**Likely issues**:
- Check for "Inter everywhere" (single font)
- Verify contrast ratios meet WCAG AA
- Ensure button hierarchy (not all primary)
- Check spacing rhythm (not monotonous)

**Opportunity**: Run `/impeccable critique` on Catone staging to get instant credibility boost with design-conscious commercialisti.

### For Klaaryo

**Current risk assessment**: Klaaryo's WhatsApp-native approach avoids many of these (no web UI to slop).

**But watch for**:
- Marketing website could fall into these traps
- Internal admin tools/dashboards
- Onboarding flows

**Opportunity**: Position Klaaryo as "human-designed, not AI-generated" in enterprise sales (differentiator vs competitors using AI design tools).

### For Both Products

**Strategic insight**: These patterns are becoming **trust signals**.

**As AI-generated UIs flood the market**:
- Users develop "slop detection" instinct
- Professional, considered design = differentiation
- Avoiding these patterns = "we're serious, not a weekend project"

**Action items**:
1. Run Impeccable on both Catone and Klaaryo
2. Fix flagged issues before major releases
3. Add to design review checklist ("passes Impeccable scan")
4. Consider adding badge: "Human-designed, Impeccable-verified"

---

## Tool Implementation

**Three deployment options**:

1. **Chrome extension** - easiest, one-click on any tab
   - Install: https://chromewebstore.google.com/detail/impeccable/bdkgmiklpdmaojlpflclinlofgjfpabf

2. **CLI** - for CI/CD integration
   ```bash
   npx impeccable detect
   ```

3. **Live server** - inject into any dev environment
   ```bash
   npx impeccable live
   ```

**Integration into workflow**:
- Add to pre-commit hooks (block if violations found)
- Run during design reviews
- Include in QA checklist before releases

---

## Creator Context

**Paul Bakaus** ([@pbakaus](https://x.com/pbakaus))
- Created Impeccable design review system
- Focus on catching AI-generated slop patterns
- Shared by Michael Nguyen (@insights_infra, Head of Customer Intelligence at Enterpret)

**Why this matters now**: 2026 is the year AI design tools went mainstream. Everyone can generate a "professional-looking" UI in seconds. These patterns are the tells that separate considered design from generated slop.

---

## Personal Reaction / Analysis

This is a **critical resource for 2026**.

**The context**: As AI design tools proliferate, they're all converging on the same patterns. Just like how you can spot a Canva template from a mile away, you can now spot AI-generated UIs.

**The insight**: These aren't just aesthetic issues—they're **trust signals**. When users see these patterns, they subconsciously register "this was generated, not designed."

**For your Q2 goals** (gain confidence + money to stay self-employed):

**Catone angle**:
- Commercialisti are sophisticated buyers
- They work with serious clients (PE funds, M&A advisors)
- A "slop" UI signals amateur hour
- Running Impeccable and fixing issues = professionalism signal

**Klaaryo angle**:
- Enterprise HR buyers have seen 1000 identical dashboards
- "Not looking like everyone else" = competitive advantage
- WhatsApp-native already differentiates, but admin UI still matters

**Personal branding**:
- You can use Impeccable as a quality gate in your consulting
- "All my work passes Impeccable scan" = credibility
- Shows you care about craft, not just shipping fast

**The meta-lesson**: In a world where everyone can generate passable UIs, **avoiding the patterns of generated UIs becomes valuable**.

It's like handwriting in the age of printing, or analog photography in the digital age. The tells of human craft become differentiators.

---

## Questions This Raises

1. What does Catone's UI look like through Impeccable? (should run scan)
2. Is Klaaryo's marketing site falling into any of these traps?
3. Could you position "Impeccable-verified design" as a Catone sales point to design-conscious studios?
4. Should you add Impeccable to your own design toolkit for client work?

---

## Next Steps

- [ ] Install Impeccable Chrome extension
- [ ] Run scan on Catone staging
- [ ] Run scan on Klaaryo marketing site
- [ ] Add to design review checklist for both products
- [ ] Consider: Create "design quality" section in Catone's positioning

---

## Research Notes

*Scraped*: 2026-05-05 using Firecrawl
*Source*: https://impeccable.style/slop
*Shared by*: Michael Nguyen (@insights_infra) on Twitter
*Context*: Part of larger conversation about AI-generated design quality
