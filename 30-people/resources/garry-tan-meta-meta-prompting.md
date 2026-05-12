# Meta-Meta-Prompting: The Secret to Making AI Agents Work

**Author:** Garry Tan (@garrytan)  
**Date:** May 9, 2026  
**Source:** Twitter/X thread  
**Saved:** May 10, 2026

---

## The Core Thesis

**The future belongs to individuals who build compounding AI systems, not to individuals who use corporate-owned centralized AI tools.**

The difference is the difference between keeping a journal and having a nervous system.

---

## Why Garry Is Coding Until 2AM

> "People keep asking me why I am spending my nights coding til 2AM. I have a job and a big one, as CEO of Y Combinator."

In the last 5 months, AI made him a builder again. Not toy projects. **Real systems that compound.**

He stopped treating AI as a chat window and started treating it as **an operating system**.

---

## The Book That Read Me Back

### What Happened:

Garry asked his AI to do a **"book mirror"** of Pema Chödrön's *When Things Fall Apart* (162 pages, 22 chapters).

**What that means:**
- System extracted all 22 chapters
- For each chapter, ran a sub-agent that:
  1. Summarized the author's ideas
  2. Mapped every idea to Garry's actual life

**Not generic "this applies to leaders" pablum. Specific mapping.**

The system knew:
- Family history (immigrant parents, dad from Hong Kong/Singapore, mom from Burma)
- Professional context (running YC, building open-source tools, mentoring thousands)
- Reading history, 2am thoughts, therapy sessions

### The Output:

**30,000-word brain page** in 40 minutes.

Each chapter rendered as two columns:
- What Pema says
- How it maps to what Garry is actually living through

Examples:
- Chapter on groundlessness → specific founder conversation from the week before
- Chapter on fear → patterns his therapist had identified
- Chapter on letting go → late-night session about creative freedom

### Why This Matters:

> "A $300/hour therapist reading this book and applying it to my life couldn't do this in 40 hours, because they don't have the full graph of my professional context, my reading history, my meeting notes, and my founder relationships all loaded and cross-referenceable."

### Books Mirrored So Far (20+):

- Amplified (Dion Lim)
- Autobiography of Bertrand Russell
- Designing Your Life
- Drama of the Gifted Child
- Finite and Infinite Games
- Gift from the Sea (Lindbergh)
- Siddhartha (Hesse)
- Steppenwolf (Hesse)
- The Art of Doing Science and Engineering (Hamming)
- The Dream Machine
- The Book on the Taboo Against Knowing Who You Are (Alan Watts)
- What Do You Care What Other People Think (Feynman)
- When Things Fall Apart (Pema Chodron)
- A Brief History of Everything (Ken Wilber)

**Each mirror gets richer because the brain gets richer. The 20th knew about all 19.**

---

## How Book-Mirror Got Better Through Iteration

### Version 1: Terrible

Three factual errors about his family:
- Said parents were divorced (they weren't)
- Said he grew up in Hong Kong (born in Canada)

### Version 2: Fact-Checking Added

Every mirror now runs **cross-modal evaluation** against known facts before shipping:
- Opus 4.7 1M catches precision errors
- GPT-5.5 catches missing context
- DeepSeek V4-Pro catches when something reads as generic

### Version 3: Deep Retrieval

Added **GBrain tool use** for per-section brain searches.

Every right-column entry **cites actual brain pages**:
- Actual meeting notes with specific founders
- Ideas from Thursday hangout with brother James
- IM chat with college roommate at 19

> "It's uncanny."

### The Skillification:

Used `/skillify` in GBrain to:
- Extract repeatable pattern
- Write tested skill file with triggers and edge cases
- Every fix compounded across all future book mirrors

---

## Skills That Build Skills (Meta-Meta-Prompting)

### The Recursive Insight:

**Skillify is a meta-skill that creates new skills.**

When Garry encounters a workflow he'll repeat:
1. Says "skillify this"
2. System examines what just happened
3. Extracts repeatable pattern
4. Writes tested skill file with triggers and edge cases
5. Registers it in the resolver

### Skills Compose:

Book-mirror calls:
- `brain-ops` for storage
- `enrich` for context
- `cross-modal-eval` for quality
- `pdf-generation` for output

**When one skill improves, every workflow using it gets better automatically.**

---

## The Meeting That Prepped Itself

### The Scenario:

Demis Hassabis came to YC for fireside chat. Sebastian Mallaby's biography had just come out.

### What the System Did (Under 2 Minutes):

Pulled:
- Demis's full brain page (months of articles, podcast transcripts, notes)
- His published beliefs about AGI timelines ("50% scaling, 50% innovation," thinks AGI is 5-10 years away)
- Mallaby biography highlights
- His stated research priorities (continual learning, world models, long-term memory)
- Cross-references to Garry's public statements about AI
- Three demo scripts for showing brain's multi-hop reasoning
- Conversation hooks based on where worldviews overlap/diverge

**Not just a better Google search. Preparation that used accumulated context about Demis, Garry's own positions, and strategic goals.**

---

## What 100,000 Pages of Brain Looks Like

### The Structure:

Every person gets a page with:
- Timeline
- State section (what's currently true)
- Open threads
- Score

Every meeting gets:
- Transcript
- Structured summary
- **Entity propagation**: System walks through every person/company mentioned and updates their brain pages

Every book gets:
- Chapter-by-chapter mirror

Every article, podcast, video:
- Ingested, tagged, cross-referenced

### Page Schema:

Each page has:
1. **Compiled truth at the top** (current best understanding)
2. **Append-only timeline below** (events in chronological order)
3. **Raw data sidecars** (source material)

**Think: Personal Wikipedia where every page is continuously updated by an AI that was at the meeting, read the email, watched the talk, ingested the PDF.**

### Example Compounding:

Meet a founder at office hours → System:
- Creates/updates their person page
- Updates their company page
- Cross-references meeting notes
- Checks if met before (surfaces what was discussed last time)
- Checks application data
- Pulls latest metrics
- Identifies if any portfolio companies/contacts are relevant

**By next meeting, full context pack ready.**

### Filing Cabinet vs. Nervous System:

> "The filing cabinet stores things. The nervous system connects them, flags what's changed, and surfaces what's relevant to right now."

---

## The Architecture

### 1. The Harness is Thin

**OpenClaw** is the runtime:
- Receives messages
- Figures out which skill applies
- Dispatches
- A few thousand lines of routing logic
- Doesn't know anything about books/meetings/founders
- Just routes

### 2. The Skills are Fat

**Over 100 skills now.** Each is a self-contained markdown file with detailed instructions for one specific task.

#### Key Skills:

**meeting-ingestion:**
- Pulls transcript after every meeting
- Creates structured summary
- **Entity propagation:** Walks through every person/company mentioned and updates their brain pages
- The meeting page is not the end product—the propagation back to entity pages is the real value

**enrich:**
- Give it a person's name
- Pulls from 5+ sources
- Merges into single brain page with career arc, contact info, meeting history, relationship context
- Cited sources on every claim

**media-ingest:**
- Handles video, audio, PDF, screenshots, GitHub repos
- Transcribes, extracts entities, files to right brain location
- Used constantly for YouTube videos, podcasts, voice memos

**perplexity-research:**
- Brain-augmented web research
- Searches web via Perplexity
- Before synthesizing, checks what brain already knows
- Tells you what's actually new vs. already captured

**Other skills Garry built (will probably open source):**
- email-triage
- investor-update-ingest (detects portfolio updates in email, extracts metrics into company pages)
- calendar-check (conflict detection, travel impossibility)
- Journalistic research stack for civic work

> "Each skill encodes operational knowledge that would take a new human assistant months to learn. When someone asks how I 'prompt' my AI, the answer is: I don't. The skills are the prompts."

### 3. The Data is Fat

**100,000 pages** of structured knowledge in brain repo:
- Every person, company, meeting, book, article, idea
- All linked, all searchable, all growing daily

### 4. The Code is Fat

Code that feeds it:
- Scripts for transcription, OCR, social media archival
- Calendar sync, API integrations
- **100+ crons per day** checking: social media, Slack, email, etc.
- OpenClaw/Hermes Agents look at everything for him

### 5. The Models are Interchangeable

- **Opus 4.7 1M** for precision
- **GPT-5.5** for recall and exhaustive extraction
- **DeepSeek V4-Pro** for creative work and third perspectives
- **Groq with Llamma** for speed

**The skill decides which model to call for which task. The harness doesn't care.**

> "When someone asks 'which AI model is best,' the answer is: wrong question. The model is just the engine. Everything else is the car."

---

## The Compounding System

### Not Productivity, Compounding:

Every meeting → adds to brain  
Every book → enriches context for next book  
Every skill → makes next workflow faster  
Every person page → makes next meeting prep sharper  

**System today is 10x what it was 2 months ago. In 2 months it'll be 10x again.**

### What 2AM Coding Means:

> "I'm not just writing software. I'm adding to a system that gets better every hour."

**100 cronjobs running 24/7:**
- Meeting ingestion runs automatically
- Email triage runs every 10 minutes
- Knowledge graph enriches itself from every conversation
- System processes daily transcripts and extracts patterns in real time

### What This Actually Is:

> "This is not a writing tool. It's not a search engine. It's not a chatbot. It's a second brain that actually works, not as a metaphor, but as a running system with 100,000 pages, 100+ skills, 15 cron jobs, and the accumulated context of every professional relationship, meeting, book, and idea I've engaged with in the last year."

---

## The Open Source Stack

Garry open-sourced everything:

### GStack
- Coding skill framework (87,000+ stars)
- Used as a skill inside OpenClaw/Hermes Agent when agent needs to code
- Great programmable browser (headed and headless)

### GBrain
- Knowledge infrastructure
- Inspired by Karpathy's LLM Wiki
- **97.6% recall on LongMemEval** (beats MemPalace with no LLM in retrieval loop)
- Ships **39 installable skills** including everything in this article
- One command to install
- Git repo where every person, meeting, article, idea gets a page

### OpenClaw and Hermes Agent
- The harnesses
- "You should choose but I usually do both"

### Data Repos
- On GitHub

---

## How to Start

### 1. Pick a Harness

- OpenClaw
- Hermes Agent
- Or build your own from scratch with Pi

**Keep it thin. The harness is just the router.**

Host it:
- On spare computer at home with Tailscale
- Or use Render/Railway in the cloud

### 2. Start a Brain with GBrain

### 3. Do Something Interesting

**Don't start by planning skill architecture.**

Start by doing a thing:
- Write a report
- Research a person
- Download NBA scores and build prediction model for sports bets
- Analyze your portfolio
- Whatever you actually care about

**Then:**
1. Do it with your agent
2. Iterate until it's good
3. Run **Skillify** to extract pattern into reusable skill
4. Run **check_resolvable** to verify new skill is wired into resolver

**That loop turns one-off work into compounding infrastructure.**

### 4. Keep Using It and Look at Output

The skill will be **mediocre at first. That's the point.**

Use it, read what it produces, and when something is off:
- Run **cross-modal eval**: send output through multiple models
- Have them score each other on dimensions you care about

**The fix gets baked into the skill. Every use since has been clean.**

---

## The Learning Curve

> "The first thing I built with this system was terrible. The hundredth was something I'd trust with my calendar, my inbox, my meeting prep, and my reading list."

**The system learned. I learned. The compound curve is real.**

In six months you'll have something no chatbot can replicate, because:

**The value isn't in the model. It's in what you've taught the system about your specific life, work, and judgment.**

---

## Related Articles (Garry's Series)

1. **Fat Skills, Fat Code, Thin Harness** — Core architecture
2. **Resolvers** — Routing table for intelligence
3. **The LOC Controversy** — Every technical person just multiplied themselves by 100x to 1000x
4. **Naked models are stupider** — The model is the engine, not the car
5. **The skillify manifesto** — Why LangChain raised $160M and gave you a squat rack and dumbbell set without a workout plan

---

## Key Insights

### On Tolerance vs. Compounding Systems:

This connects directly to the Livorno model:

**Livorno:** Build infrastructure → attract diaspora → extract network value → compound  
**Garry's System:** Build skills → accumulate context → extract compound value → multiply yourself

Both are about **creating the porto franco** (the hub that taxes the flow).

### On Skills vs. Prompts:

> "When someone asks how I 'prompt' my AI, the answer is: I don't. The skills are the prompts."

This is the **Livorno lesson applied to AI**: Don't be the merchant. Be the free port. The skills are the infrastructure. The models are the merchants passing through.

### On Compounding vs. Productivity:

> "I don't think about productivity. What I think about is compounding."

Every interaction feeds the system. Every system improvement multiplies future value.

**This is the √n strategy:** Find the 6 high-leverage hours (out of 40). Automate everything else. Let the system compound.

### On Personal vs. Corporate AI:

> "The future belongs to individuals who build compounding AI systems, not to individuals who use corporate-owned centralized AI tools."

**You want to be the Medici building Livorno, not a merchant renting space in someone else's port.**

---

## Tags

`#ai` `#agents` `#compounding-systems` `#gbrain` `#openclaw` `#skills` `#meta-prompting` `#second-brain` `#garry-tan` `#yc` `#open-source` `#personal-ai`
