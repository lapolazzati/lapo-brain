---
_organized: true
---
# Ingest Workflow

How Andy captures and processes shared content into lapo-brain.

---

## Triggers

Andy automatically ingests content when you:
1. **Share just a URL** (no other text)
2. Use the word **"remember"** (e.g., "remember this for later")
3. Say **"read this"** explicitly

---

## The Flow

1. **Read**: Andy fetches and reads the content (article, video, podcast, code)
2. **Summarize**: Creates structured summary with metadata
3. **Write silently**: Saves to inbox without interrupting you
4. **Notify**: Sends quick confirmation when done

---

## File Structure

### Location
`/workspace/group/lapo-brain/50-resources/inbox/YYYY-MM-DD-slug.md`

Example: `2026-05-04-karpathy-llm-wiki.md`

### Frontmatter (Required)
```yaml
---
type: Article  # or Video, Podcast, Note, Code
status: inbox
tags: [ai, knowledge-management, wiki]
shared: 2026-05-04T19:50:00Z
context: "Shared during discussion about wiki-llm setup"
source: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
---
```

### Summary Format

**Top section**: Bullet points of key takeaways
```markdown
## Key Takeaways

• Main insight one
• Main insight two
• Main insight three
```

**Below**: Detailed notes with quotes and analysis
```markdown
## Detailed Notes

### Section 1: Core Concept

[Detailed explanation with context]

> "Notable quote from the source"

[Your analysis or connection to existing work]

### Section 2: Implementation Details

[More detailed coverage]
```

---

## Maintenance Cycle

**Every 3 days** (not immediately on each ingest):
1. Review inbox items
2. Update `index.md` with new entries
3. Update `log.md` with significant additions
4. Extract recurring themes into concept pages (when patterns emerge)

**You handle**: Moving items from inbox to project folders via Tolaria

---

## Content Type Detection

Andy auto-categorizes based on source:
- **Article**: Web pages, blog posts, newsletters
- **Video**: YouTube, Vimeo links
- **Podcast**: Audio links, podcast players
- **Code**: GitHub gists, code snippets
- **Note**: Plain text, thoughts, ideas

---

## Examples

### Example 1: URL share
**You**: `https://example.com/article`
**Andy**:
- Reads article
- Creates `2026-05-04-article-title.md` in inbox
- Notifies: "✓ Saved: Article Title"

### Example 2: "Remember this"
**You**: `remember: need to follow up with Gianni about Catone pricing`
**Andy**:
- Creates `2026-05-04-catone-pricing-followup.md`
- Type: Note
- Tags: [catone, pricing, gianni]
- Notifies: "✓ Remembered"

### Example 3: "Read this"
**You**: `read this https://paper.pdf and summarize the main findings`
**Andy**:
- Reads PDF
- Creates detailed summary with key findings
- Saves to inbox
- Notifies: "✓ Summarized: Paper Title (3 key findings)"

---

## Integration with Tolaria

Tolaria's inbox feature complements this workflow:
- Andy populates `/50-resources/inbox/` automatically
- You review and organize items manually when ready
- Tolaria's type system helps categorize and link
- Git integration tracks all changes

Andy never moves items out of inbox - that's your call during weekly reviews or when the mood strikes.

---

## Philosophy

**Capture everything, organize later.**

The inbox is a buffer. Andy's job is to make sure nothing you share gets lost. Your job is to decide what matters and where it lives.

Low friction in, thoughtful curation out.
