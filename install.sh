#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

echo "Installing Lethe skills to $SKILLS_DST..."

mkdir -p "$SKILLS_DST"

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  dst="$SKILLS_DST/$skill_name"
  mkdir -p "$dst"
  cp "$skill_dir/SKILL.md" "$dst/SKILL.md"
  echo "  ✓ $skill_name"
done

echo ""
echo "Done. Invoke the 'lethe-setup' skill in Claude Code to create your vault."
