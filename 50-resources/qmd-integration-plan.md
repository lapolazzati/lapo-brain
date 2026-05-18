# QMD Integration Plan for Agent Memory

**Created:** 2026-05-18
**Status:** Proposed
**Problem:** Agent context management is "fucked up" - daily briefings have date errors, context compaction loses important details, memory retrieval is inconsistent

---

## What is QMD?

**QMD (Query Markup Documents)** is a mini CLI search engine for documents, knowledge bases, and meeting notes. It runs entirely locally with on-device models.

- **GitHub:** https://github.com/tobi/qmd
- **Stars:** 25.1k
- **License:** MIT
- **Tech:** TypeScript, node-llama-cpp, SQLite

### Key Features

1. **Hybrid search**: BM25 (keyword) + vector embeddings + LLM reranking
2. **All local**: No API calls, runs on-device with GGUF models
3. **MCP server support**: Direct integration with Claude Code/Desktop
4. **Smart chunking**: AST-aware for code files, markdown-aware for docs
5. **Context metadata**: Add descriptions to collections/paths for better search relevance

---

## How QMD Would Fix Our Memory Issues

### Current Problems

1. **Date confusion** - Agent calling Monday "Sunday", wrong calendar info in briefings
2. **Context loss** - Compaction summaries lose critical details
3. **Duplicate tasks** - Scheduled tasks triggering multiple times
4. **Stale context** - Agent not finding previously saved information

### QMD Solutions

| Problem | QMD Solution |
|---------|--------------|
| Can't find design guidelines | `qmd search "design guidelines" --collection lapo-brain` |
| Wrong dates in briefings | Query calendar context: `qmd query "MPO Partners call date"` |
| Lost meeting context | Index Granola notes: `qmd collection add ~/granola-notes` |
| Context compaction | Keep full history in QMD index, retrieve on-demand |
| Linear task confusion | Index Linear exports: `qmd search "CAT-111" -c linear-tasks` |

**Key insight:** Instead of cramming context into prompts, index everything and retrieve what's needed per-task.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Agent Query (Claude)                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   QMD MCP Server       │
        │   (HTTP or stdio)      │
        └────────┬───────────────┘
                 │
                 ▼
    ┌────────────────────────────┐
    │  QMD Hybrid Search         │
    │  • BM25 (keyword)          │
    │  • Vector embeddings       │
    │  • LLM reranking           │
    └────────┬───────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│         SQLite Index Database          │
│  ~/.cache/qmd/index.sqlite             │
│                                        │
│  Collections:                          │
│  • lapo-brain (vault)                  │
│  • weekly-briefs                       │
│  • granola-meetings                    │
│  • linear-exports                      │
│  • conversations                       │
└────────────────────────────────────────┘
```

---

## Installation & Setup

### 1. Install QMD

```bash
# Global install
npm install -g @tobilu/qmd

# Or use with npx
npx @tobilu/qmd --help
```

### 2. Create Collections

```bash
# Index the lapo-brain vault (main memory)
qmd collection add /workspace/group/lapo-brain --name lapo-brain

# Index weekly briefs separately
qmd collection add /workspace/group/lapo-brain/00-weekly --name weekly-briefs

# Index conversation history
qmd collection add /workspace/group/conversations --name conversations

# Index meeting notes (if Granola exports available)
# qmd collection add ~/granola-notes --name meetings
```

### 3. Add Context Metadata

```bash
# Add context to help search understand each collection
qmd context add qmd://lapo-brain "Lapo's persistent memory vault - targets, projects, resources"
qmd context add qmd://weekly-briefs "Weekly reviews, daily briefings, Sunday planning"
qmd context add qmd://conversations "Chat history with Andy assistant"
```

### 4. Generate Embeddings

```bash
# Initial embedding (takes ~5-10 min for full lapo-brain)
qmd embed

# Enable AST-aware chunking for code files
qmd embed --chunk-strategy auto
```

### 5. Test Search

```bash
# Keyword search
qmd search "design guidelines"

# Semantic search
qmd vsearch "what are my Q2 revenue targets"

# Hybrid search (best quality)
qmd query "CEG Milano contractor outreach status"

# JSON output for agent consumption
qmd query "MPO Partners call" --json -n 5
```

---

## MCP Server Integration

### Option A: Stdio (Default)

Add to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "qmd": {
      "command": "qmd",
      "args": ["mcp"]
    }
  }
}
```

### Option B: HTTP (Long-lived server)

```bash
# Start HTTP server in background
qmd mcp --http --daemon

# Server runs at http://localhost:8181
# Models stay loaded in VRAM across requests
# Faster for repeated queries

# Check status
qmd status  # Shows "MCP: running (PID ...)"

# Stop
qmd mcp stop
```

Point MCP client at `http://localhost:8181/mcp` for HTTP transport.

---

## MCP Tools Available

| Tool | Use When |
|------|----------|
| `query` | Search with typed sub-queries (lex/vec/hyde), combined via RRF + reranking |
| `get` | Retrieve a document by path or docid (with fuzzy matching suggestions) |
| `multi_get` | Batch retrieve by glob pattern, comma-separated list, or docids |
| `status` | Index health and collection info |

### Example Agent Usage

```typescript
// Search for design guidelines
const results = await mcp.query({
  query: "design guidelines background white tones",
  collections: ["lapo-brain"],
  limit: 5
})

// Get specific document
const doc = await mcp.get("50-resources/design-guidelines.md")

// Batch retrieve weekly briefs
const briefs = await mcp.multi_get("00-weekly/briefs/2026-05*.md")
```

---

## Scheduled Task Integration

Update auto-ingest and briefing tasks to use QMD:

### Daily Briefing Generation

**Before (current):**
- Read last 3 briefing files manually
- Context compaction loses details
- Date confusion from stale context

**After (with QMD):**
```bash
# Query recent context
qmd query "Week 21 priorities CEG contractor MPO call" --json -n 10

# Get specific documents
qmd get "00-weekly/reviews/2026-W20-review.md"

# Get all Monday briefings for pattern reference
qmd multi-get "00-weekly/briefs/*-monday.md" --json
```

### Weekly Review

```bash
# Find all Week 20 context
qmd query "Week 20 Klaaryo CEG Milano Catone" -c lapo-brain --json

# Get Linear task history
qmd search "CAT-111 CAT-110" --all --files

# Find meeting summaries
qmd query "Federico meeting May 14" -c conversations
```

---

## Data Storage

### Index Location
- **SQLite database:** `~/.cache/qmd/index.sqlite`
- **Models cache:** `~/.cache/qmd/models/` (~2GB for all 3 models)

### Schema
- `collections` - Indexed directories with glob patterns
- `path_contexts` - Context descriptions by virtual path
- `documents` - Markdown content with metadata and docid
- `documents_fts` - FTS5 full-text index
- `content_vectors` - Embedding chunks (900 tokens, 15% overlap)
- `vectors_vec` - sqlite-vec vector index
- `llm_cache` - Cached LLM responses

### Models (Auto-downloaded)

| Model | Purpose | Size |
|-------|---------|------|
| embeddinggemma-300M-Q8_0 | Vector embeddings | ~300MB |
| qwen3-reranker-0.6b-q8_0 | Re-ranking | ~640MB |
| qmd-query-expansion-1.7B-q4_k_m | Query expansion | ~1.1GB |

---

## Maintenance

### Re-index Collections
```bash
# Update index after new files added
qmd update

# Force re-embedding
qmd embed -f
```

### Check Index Health
```bash
qmd status
```

### Cleanup
```bash
# Clean up cache and orphaned data
qmd cleanup
```

---

## Migration Strategy

### Phase 1: Parallel Testing (Week 21)
1. Install QMD and index lapo-brain
2. Test queries manually to verify quality
3. Compare QMD search vs current context retrieval
4. Identify top 5 use cases where QMD beats current approach

### Phase 2: MCP Integration (Week 22)
1. Add QMD MCP server to Claude Code config
2. Update scheduled tasks to use QMD tools
3. Test daily briefing generation with QMD context
4. Monitor for improvements in date accuracy and context relevance

### Phase 3: Full Migration (Week 23)
1. Replace all context file reads with QMD queries
2. Update weekly review protocol to leverage QMD
3. Archive old context compaction system
4. Document new QMD-powered memory workflow

---

## Cost/Benefit Analysis

### Benefits
- ✅ **Better search**: Hybrid BM25 + vector + reranking beats simple file reads
- ✅ **No API costs**: All local, no OpenAI/Anthropic calls for memory retrieval
- ✅ **Faster context**: SQLite FTS5 faster than grepping files
- ✅ **Semantic search**: Find related content even without exact keyword matches
- ✅ **MCP native**: Direct integration with Claude Code workflows

### Costs
- ❌ **Disk space**: ~2GB for models, ~500MB for index (one-time)
- ❌ **Initial setup**: ~30 min to install, index, and test
- ❌ **Maintenance**: Must re-index after adding new files (can automate)
- ❌ **Learning curve**: New query syntax, need to learn optimal search patterns

### ROI
- **Time saved**: 10-20 min/day not manually searching for context
- **Error reduction**: Eliminates date confusion, stale context issues
- **Context quality**: Better retrieval = better decisions = faster execution

**Estimate:** Break-even after 3 days, net positive by Week 22.

---

## Next Steps

1. **Today (Monday May 18):**
   - [ ] Install QMD globally: `npm install -g @tobilu/qmd`
   - [ ] Index lapo-brain: `qmd collection add /workspace/group/lapo-brain --name lapo-brain`
   - [ ] Generate embeddings: `qmd embed`
   - [ ] Test 5 queries to validate quality

2. **Tuesday May 19:**
   - [ ] Add QMD MCP server to Claude Code config
   - [ ] Update one scheduled task to use QMD (e.g., daily briefing)
   - [ ] Compare output quality vs current approach

3. **Wednesday May 20:**
   - [ ] If QMD proves valuable, migrate all scheduled tasks
   - [ ] Document QMD query patterns for common use cases
   - [ ] Archive old context management system

---

## References

- **GitHub:** https://github.com/tobi/qmd
- **Documentation:** See README in repo
- **MCP Integration:** https://github.com/tobi/qmd#mcp-server
- **Discord/Support:** Check GitHub Discussions

---

## Related Files

- `/workspace/group/lapo-brain/50-resources/design-guidelines.md` - Example document QMD should index
- `/workspace/group/lapo-brain/00-weekly/` - Weekly briefs and reviews to index
- `/workspace/group/conversations/` - Chat history to index
- `~/.claude/settings.json` - Where to add MCP server config
