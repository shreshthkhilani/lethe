#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"
TEMPLATES_DST="$HOME/.claude/lethe-templates"

echo "Installing Lethe skills to $SKILLS_DST..."
mkdir -p "$SKILLS_DST"

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  dst="$SKILLS_DST/$skill_name"
  if [ -d "$dst" ]; then
    echo "  ↻ $skill_name (updating)"
  else
    echo "  + $skill_name"
  fi
  mkdir -p "$dst"
  cp -r "$skill_dir"/* "$dst/"
done

echo ""
echo "Installing templates to $TEMPLATES_DST..."
mkdir -p "$TEMPLATES_DST"
cp "$SCRIPT_DIR/templates/"* "$TEMPLATES_DST/"
echo "  + 6 templates"

echo ""
echo "Done. Invoke the 'lethe-setup' skill in Claude Code to create your vault."
