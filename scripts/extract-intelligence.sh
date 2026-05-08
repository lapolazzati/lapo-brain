#!/bin/bash
#
# AI-Powered Intelligence Extraction
#
# Reads all documents in raw/ and uses Claude to extract:
# - Metrics, decisions, timeline, blockers, stakeholders
# - Auto-generates context.md with citations
#

PROJECT=$1
RAW_DIR="/workspace/group/lapo-brain/10-projects/$PROJECT/raw"

if [ ! -d "$RAW_DIR" ]; then
    echo "Error: $RAW_DIR not found"
    exit 1
fi

echo "🧠 Extracting intelligence from $PROJECT raw sources..."
echo ""

# Build file list with content
FILES_CONTENT=""
for file in "$RAW_DIR"/*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "📄 Reading: $filename"
        FILES_CONTENT="$FILES_CONTENT

## Source: $filename

$(cat "$file")

---
"
    fi
done

# Also include subdirectories
for dir in "$RAW_DIR"/*/; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        echo "📁 Reading: $dirname/"
        for file in "$dir"/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                FILES_CONTENT="$FILES_CONTENT

## Source: $dirname/$filename

$(cat "$file")

---
"
            fi
        done
    fi
done

# Save to temp file for processing
echo "$FILES_CONTENT" > "/tmp/${PROJECT}-sources.txt"

echo ""
echo "✅ Aggregated $(find "$RAW_DIR" -name "*.md" | wc -l) markdown files"
echo "📊 Total content: $(wc -l < "/tmp/${PROJECT}-sources.txt") lines"
echo ""
echo "💡 Next: Use Claude to extract intelligence from /tmp/${PROJECT}-sources.txt"
echo ""
