# Granola MCP Setup Guide

**Status**: In Progress
**Date**: 2026-05-05
**Purpose**: Connect Granola meeting notes to Claude/Andy via Model Context Protocol

---

## Overview

Granola MCP enables Claude to access your meeting notes and transcripts directly. This allows Andy to:
- Search across all meeting transcripts
- Retrieve specific meeting notes
- Query meeting content for context
- Reference past discussions

**MCP Server URL**: `https://mcp.granola.ai/mcp`

---

## Setup Steps

### 1. Update MCP Configuration

Edit `/workspace/project/.mcp.json` in your nanoclaw project root:

```json
{
  "mcpServers": {
    "granola": {
      "url": "https://mcp.granola.ai/mcp"
    }
  }
}
```

If you already have other MCP servers configured, just add the `"granola"` entry to the existing `mcpServers` object.

### 2. Restart Container

After updating `.mcp.json`, restart the nanoclaw container to load the new MCP server:

```bash
# From your nanoclaw project directory
docker-compose restart
```

Or stop/start the specific container if using docker commands directly.

### 3. OAuth Authentication

On first use of Granola MCP tools, you'll be prompted to authenticate:

1. **Authentication URL provided** - You'll see a URL in the terminal
2. **Visit URL in browser** - Open the authentication link
3. **Sign in to Granola** - Use your Granola account credentials
4. **Authorize MCP** - Grant permission for Claude to access meeting notes
5. **Return to terminal** - Authentication complete

The OAuth token is stored securely and you won't need to re-authenticate unless the token expires.

### 4. Verify Connection

After authentication, test the connection by asking Andy to:
- "Search my Granola meetings for discussions about [topic]"
- "What did we discuss in my last meeting with [person]?"
- "Show me meeting notes from [date]"

---

## Available Capabilities

Once connected, Andy can:

- **Search transcripts** - Find specific topics, keywords, or people across all meetings
- **Retrieve meeting notes** - Get full transcripts and notes from specific meetings
- **Extract action items** - Pull tasks and follow-ups from meetings
- **Reference context** - Use meeting content to inform responses and research

---

## Troubleshooting

**Authentication fails:**
- Ensure you're signed in to Granola in your browser
- Check that the MCP URL is exactly: `https://mcp.granola.ai/mcp`
- Try clearing browser cookies and re-authenticating

**MCP server not loading:**
- Verify `.mcp.json` syntax is valid JSON (use a JSON validator)
- Check container logs for MCP initialization errors
- Ensure the container was fully restarted after config change

**Tools not appearing:**
- Restart the container again
- Check that OAuth authentication completed successfully
- Verify Granola account has meeting data available

---

## Resources

- **Granola MCP Blog Post**: https://www.granola.ai/blog/granola-mcp
- **MCP Server URL**: https://mcp.granola.ai/mcp
- **Granola App**: https://www.granola.ai

---

## Next Steps

- [ ] Edit `/workspace/project/.mcp.json` to add Granola server
- [ ] Restart nanoclaw container
- [ ] Complete OAuth authentication flow
- [ ] Test connection by querying meeting notes
- [ ] Document common meeting search patterns in lapo-brain

---

*Last updated: 2026-05-05*
