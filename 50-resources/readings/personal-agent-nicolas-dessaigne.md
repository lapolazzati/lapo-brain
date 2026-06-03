---
type: Note
related_to: "[[personal-agent-stack]]"
url: https://nicolas.dessaigne.com/post/personal-agent
---

# Personal Agent Architecture — Nicolas Dessaigne

Source article saved for reference. Key concepts adapted in [[personal-agent-stack]].

## Core Insight

The future of personal agents starts as a pile of commands that let the model operate the tools you already use. Reduce abstraction layers between models and APIs to a maximum.

## Agent

Codex with GPT-5.5. Used to be Claude Code, moved for model quality.

## Tools (in hierarchy order)

API and CLI > local file > browser automation > screen automation

- gogcli — Google Workspace (Gmail, Drive, Calendar, Docs, Sheets, Contacts, Tasks)
- wacli — WhatsApp
- imsg — iMessage and SMS
- Telegram connector — Telegram
- Browser Use / Chrome controller — web apps without APIs
- AppleScript / UI scripting — macOS apps
- filesystem tools — local files

## Data Layer

Google Drive as source of truth. Markdown and CSV preferred (agent-readable). Notion exported to Drive. Local instructions in AGENTS.md. Skills as Markdown files.

Drive contents:
- personal docs
- car docs
- family docs
- exported Notion pages
- PDFs
- spreadsheets

Google Sheets / CSV:
- contacts (name, phone, email, linkedin, categories, locations, notes)

Local files:
- AGENTS.md
- memories
- skills
- scripts
- blog repo

## Skills

Skills are operating manuals — small procedures that accumulate operational taste.

Example: inbox-zero skill tells the agent to list Gmail inbox, separate auto-archive from needs-review, show important emails, quote substance, suggest archive or reply, draft replies, wait for explicit approval, send in original thread, preserve all recipients, archive only after sending, keep replies short, never suggest calls unless asked, sign with "Nicolas."

Improvement loop: tool fails → fix tool or add guardrail. Agent makes judgment mistake → update skill. Agent forgets preference → write to memory or AGENTS.md. Workflow repeats → agent improves.

## Approval Gates

Trust tiers:
- Read-only scanning — auto
- Drafting — show me, wait for approval
- Sending — explicit approval for investor emails, customer replies, intros, social nuance
- Direct send — only for low-stakes messages ("Tell Hugo I am in Seattle next week")
- Delete / pay / sign / account settings — manual only, completely different tier

## Killer Workflow: "What Did I Miss?"

Life inbox triage. Every few hours, agent scans WhatsApp, Telegram, Gmail, SMS, Calendar, relevant Drive changes. Reports: who needs a reply, what's urgent, what's stale, what can be ignored, what should become a calendar event, what needs a document search.

Perfect agent task: context-heavy, repetitive, cross-tool, full of small decisions. Humans hate the first pass. Agents are good at first passes. Judgment still belongs to the human.

## Real Communication Example

Friend WhatsApps about intro to recruiter. Agent: reads WhatsApp thread → searches Gmail for recruiter email → researches startup funding/news on web → drafts intro email → waits for approval → sends email → texts friend that intro is done. 20 minutes of app switching → 10 seconds of user-facing interaction.

## License Plate Example

New license plate. Agent: updates car info Markdown file in Drive → changes license plate → adds registration notes → preserves existing VIN, insurance, owners, address → uploads back to Drive. Then uses browser automation to update same info in FasTrak, parking app, insurance portals, DMV forms.

## Operating Rules

- Draft before sending important messages.
- Sign emails as Nicolas.
- Use gog for Gmail, Drive, Calendar, Docs, and Sheets.
- Use wacli for WhatsApp.
- Use Telegram connector for Telegram.
- Use imsg for SMS and iMessage.
- Use contacts CSV for email and phone lookup.
- Prefer APIs and CLIs over browser automation.
- Do not expose private data unless asked.
- Confirm after sending.

## Setup Checklist

1. Install Codex
2. Install gogcli for Google Workspace
3. Install wacli for WhatsApp
4. Install Telegram connector
5. Install imsg for iMessage/SMS
6. Add browser automation (Browser Use or Chrome controller)
7. Add macOS automation (AppleScript, UI scripting)
8. Export Notion valuable parts to Google Drive
9. Centralize data: Drive as source of truth
10. Keep contacts in Google Sheet or CSV
11. Keep important docs as searchable files
12. Keep local AGENTS.md instructions
13. Keep small skills for recurring workflows
14. Grant permissions carefully: Full Disk Access, Screen Recording, Accessibility
15. Write operating rules

## Key Quote

"The first useful personal agents will not look like polished consumer apps. They will look like a model inside a terminal with access to your files, accounts, memories, and tools."
