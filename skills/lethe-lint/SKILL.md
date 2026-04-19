# Lethe Lint

Periodic health checks on the Lethe River vault. Designed to run overnight via cron. Produces a report in `_inbox/` — does not silently edit files.

---

## Finding the Vault

Read `~/.claude/lethe-config.json` → `vault_path`.

If `~/.claude/lethe-config.json` does not exist, tell the user: "No Lethe vault configured. Run `lethe-setup` first." Then stop.

---

## Checks

Run all checks. Collect every finding into the report.

**Excluded from all checks:** `_inbox/`, `_templates/`, `_index.md`, `CLAUDE.md`, `_sweep-state.json`, `_compile-state.json`, `_crons.md`, `resources/self.md`, `*/overview.md` (canonical folder entry points), `.obsidian/` and any dot-directories.

### Check 1: Stale Notes
Find vault files (not in the excluded list above) where:
- `status: active` AND `updated` date is more than 30 days ago

Finding format: `[path] — last updated [date]`

### Check 2: Status Mismatches
Find `decision` or `risk` files where `status: open` but every project in `related_projects` has `status: archived` or `status: completed`.

Finding format: `[path] — decision/risk is open but all related projects are closed`

### Check 3: Orphaned Files
Find vault files (not in the excluded list above) that are not referenced by any wiki-link in any other vault file.

To check: for each file, search all `.md` vault files for `[[path-fragment]]` where `path-fragment` is a prefix of the file's relative path (both the full path and the folder shorthand form should count as a match). A file is non-orphaned if any other file contains a matching wiki-link.

Finding format: `[path] — no other files link here`

### Check 4: Broken Links
Find wiki-links in vault files that reference a path that does not exist.

Pattern to search: `\[\[([^\]]+)\]\]` in all `.md` vault files (excluding `_inbox/` and `_templates/`).

For each match:
1. Strip everything after `|` (Obsidian alias syntax: `[[path|display]]` → check `path`)
2. Strip leading/trailing whitespace
3. Attempt to resolve: first check if `[vault_path]/[target].md` exists; if not, check if `[vault_path]/[target]/overview.md` exists (folder shorthand)
4. If neither exists: flag as broken

Finding format: `[source file] → [[target]] not found`

### Check 5: Connection Candidates
Find pairs of vault files that share **3 or more** tags but have no direct wiki-link between them. Cap output at the top 20 pairs by shared-tag count.

Finding format: `[file-a] ↔ [file-b] — shared tags: [tags]`

### Check 6: Note Candidates
Find topics frequently referenced across the vault that have no dedicated file.

Heuristics for identifying candidate topics:
- Capitalized multi-word phrases (e.g., "Project Phoenix", "Data Platform")
- All-caps tokens of 2–6 characters that look like acronyms (e.g., "EDI", "PII", "SLA") — exclude common English words and standard abbreviations (e.g., "API", "URL", "HTTP")
- Any string that appears in 4 or more vault files and has no corresponding `.md` file anywhere in the vault

Finding format: `"[topic]" — referenced in [N] files, no dedicated note`

---

## Output

Write report to `"[vault_path]/_inbox/lint-report-[YYYY-MM-DD].md"`:

```markdown
---
source_type: lint
ingested: [YYYY-MM-DD]
---

# Lint Report — [YYYY-MM-DD]

## Stale Notes
[findings, one per line — or "None found"]

## Status Mismatches
[findings — or "None found"]

## Orphaned Files
[findings — or "None found"]

## Broken Links
[findings — or "None found"]

## Connection Candidates
[findings — or "None found"]

## Note Candidates
[findings — or "None found"]
```

```bash
git -C "[vault_path]" add "_inbox/lint-report-[date].md"
git -C "[vault_path]" commit -m "lethe: lint report [YYYY-MM-DD]"
```
