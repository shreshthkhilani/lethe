# Lethe Lint

Periodic health checks on the Lethe River vault. Designed to run overnight via cron. Produces a report in `_inbox/` — does not silently edit files.

---

## Finding the Vault

Read `~/.claude/lethe-config.json` → `vault_path`.

---

## Checks

Run all checks. Collect every finding into the report.

### Check 1: Stale Notes
Find vault files (not in `_inbox/`, `_templates/`, or `_index.md`) where:
- `status: active` AND `updated` date is more than 30 days ago

Finding format: `[path] — last updated [date]`

### Check 2: Status Mismatches
Find `decision` or `risk` files where `status: open` but every project in `related_projects` has `status: archived` or `status: completed`.

Finding format: `[path] — decision/risk is open but all related projects are closed`

### Check 3: Orphaned Files
Find vault files (excluding `_inbox/`, `_templates/`, `_index.md`, `CLAUDE.md`, `_sweep-state.json`, `_compile-state.json`, `_crons.md`) that are not referenced by any wiki-link in any other vault file.

To check: search all `.md` files for `[[path-fragment]]` matching the file.

Finding format: `[path] — no other files link here`

### Check 4: Broken Links
Find wiki-links in vault files that reference a path that does not exist as a `.md` file in the vault.

Pattern to search: `\[\[([^\]]+)\]\]` in all `.md` files.

Finding format: `[source file] → [[target]] not found`

### Check 5: Connection Candidates
Find pairs of vault files that share 2 or more tags but have no direct wiki-link between them.

Finding format: `[file-a] ↔ [file-b] — shared tags: [tags]`

### Check 6: Note Candidates
Find strings (project names, person names, acronyms) that appear in 3 or more vault files but have no dedicated file of their own.

Finding format: `"[topic]" — referenced in [N] files, no dedicated note`

---

## Output

Write report to `[vault_path]/_inbox/lint-report-[YYYY-MM-DD].md`:

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
git -C [vault_path] add _inbox/lint-report-[date].md
git -C [vault_path] commit -m "lethe: lint report [YYYY-MM-DD]"
```
