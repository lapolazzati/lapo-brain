#!/bin/bash
#
# Project Seeding Script - Living Intelligence System
#
# Usage: ./project-seed.sh <project-name>
#
# Reads all documents from 10-projects/<project>/raw/ and generates:
# 1. <project>-context.md - Structured intelligence with citations
# 2. sources.json - Source monitoring configuration
#

set -e

PROJECT=$1
if [ -z "$PROJECT" ]; then
    echo "Usage: ./project-seed.sh <project-name>"
    echo "Example: ./project-seed.sh klaaryo"
    exit 1
fi

PROJECT_DIR="/workspace/group/lapo-brain/10-projects/$PROJECT"
RAW_DIR="$PROJECT_DIR/raw"
CONTEXT_FILE="$PROJECT_DIR/${PROJECT}-context.md"
SOURCES_FILE="$PROJECT_DIR/sources.json"

if [ ! -d "$RAW_DIR" ]; then
    echo "Error: $RAW_DIR does not exist"
    echo "Create it first: mkdir -p $RAW_DIR"
    exit 1
fi

echo "🌱 Seeding project: $PROJECT"
echo "📁 Raw sources: $RAW_DIR"
echo ""

# Count source files
FILE_COUNT=$(find "$RAW_DIR" -type f | wc -l)
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "⚠️  No source files found in $RAW_DIR"
    echo "Add documents (PDFs, emails, notes, decks) to $RAW_DIR first"
    exit 1
fi

echo "📄 Found $FILE_COUNT source files"
echo ""

# Build sources list for AI processing
SOURCES_LIST=$(find "$RAW_DIR" -type f -exec basename {} \; | sort)

# Create extraction prompt for Claude
cat > /tmp/project-seed-prompt.txt <<EOF
Extract structured project intelligence from the source files in $RAW_DIR.

Generate a comprehensive ${PROJECT}-context.md file with these sections:

## Overview
- What is this project?
- Who are the key stakeholders?
- What is the current status?

## North Star Metrics
- What are the key success metrics? (cite source)
- Current values vs. targets (if available)

## Timeline & Milestones
- Key dates and deadlines (cite source)
- Completed milestones
- Upcoming milestones

## Decisions & Strategy
- Major decisions made (with date and source)
- Open decisions awaiting data/input
- Strategic bets ranked by impact

## Blockers & Risks
- Active blockers (what's blocking progress?)
- Known risks
- Dependencies on other teams/projects

## Open Questions
- Unanswered questions from documents
- Areas needing clarification

## Stakeholder Map
- Internal: team members, decision makers
- External: clients, partners, vendors

**Citation format**: Every claim must cite source like: "Contract signed for €X annual [source: contract.pdf]"

**Source files available**:
$SOURCES_LIST

Read each file and extract relevant information. Be precise, cite everything, flag contradictions.
EOF

echo "🤖 Extracting intelligence from sources..."
echo ""

# This would call Claude to process the files
# For now, create a template structure
cat > "$CONTEXT_FILE" <<EOF
# ${PROJECT^} - Project Context

**Last updated**: $(date +%Y-%m-%d)
**Sources analyzed**: $FILE_COUNT files
**Status**: $([ -f "$PROJECT_DIR/status-$(date +%Y-%m-%d).md" ] && echo "Active" || echo "Unknown")

---

## Overview

_Auto-generated from raw sources - edit sources.json to configure monitoring_

**What is this project?**
- TBD: Extract from raw/

**Key stakeholders**:
- TBD: Extract from raw/

**Current status**:
- See: [status-$(date +%Y-%m-%d).md](./status-$(date +%Y-%m-%d).md)

---

## North Star Metrics

TBD: Extract from raw/

---

## Timeline & Milestones

**Key dates**:
- TBD: Extract from raw/

**Completed**:
- TBD

**Upcoming**:
- TBD

---

## Decisions & Strategy

**Major decisions**:
- TBD: Extract from raw/

**Open decisions**:
- TBD

**Strategic bets**:
1. TBD
2. TBD

---

## Blockers & Risks

**Active blockers**:
- TBD: Extract from raw/

**Known risks**:
- TBD

---

## Open Questions

- TBD: Extract from raw/

---

## Stakeholder Map

**Internal**:
- TBD

**External**:
- TBD

---

## Sources

EOF

# List all source files with metadata
echo "### Raw Documents" >> "$CONTEXT_FILE"
echo "" >> "$CONTEXT_FILE"
find "$RAW_DIR" -type f | while read -r file; do
    filename=$(basename "$file")
    size=$(du -h "$file" | cut -f1)
    modified=$(stat -c %y "$file" | cut -d' ' -f1)
    echo "- **$filename** ($size) - Last modified: $modified" >> "$CONTEXT_FILE"
done

echo "" >> "$CONTEXT_FILE"
echo "_To update this context: add/modify files in raw/ and run: ./scripts/project-seed.sh $PROJECT_" >> "$CONTEXT_FILE"

# Create sources.json configuration
cat > "$SOURCES_FILE" <<EOF
{
  "project": "$PROJECT",
  "canonical_sources": {
    "status_updates": {
      "pattern": "status-*.md",
      "check_frequency": "daily",
      "description": "Daily/weekly status updates"
    },
    "meetings": {
      "pattern": "Granola:$PROJECT",
      "check_frequency": "after_each",
      "description": "Meeting transcripts and notes from Granola"
    },
    "email_threads": {
      "pattern": "Gmail:subject:$PROJECT",
      "check_frequency": "daily",
      "description": "Email threads mentioning project"
    },
    "linear_tasks": {
      "pattern": "Linear:project:$PROJECT",
      "check_frequency": "hourly",
      "description": "Tasks and issues in Linear"
    }
  },
  "monitoring": {
    "enabled": true,
    "last_check": null,
    "next_check": null
  },
  "sync": {
    "linear_project_id": null,
    "auto_create_tasks": false,
    "auto_update_context": true
  }
}
EOF

echo "✅ Project seeded successfully!"
echo ""
echo "📝 Generated:"
echo "   - $CONTEXT_FILE"
echo "   - $SOURCES_FILE"
echo ""
echo "📋 Next steps:"
echo "   1. Review $CONTEXT_FILE and fill in TBD sections manually"
echo "   2. Configure sources.json for automatic monitoring"
echo "   3. Link Linear project: Update 'linear_project_id' in sources.json"
echo "   4. Enable monitoring: Schedule source-monitor.sh to run daily"
echo ""
echo "💡 To add more context:"
echo "   - Drop documents into: $RAW_DIR"
echo "   - Run: ./scripts/project-seed.sh $PROJECT"
echo ""
