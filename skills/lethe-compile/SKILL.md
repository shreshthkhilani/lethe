# Lethe Compile

Read unprocessed files in `_inbox/` and write structured notes to the vault. Three-pass compilation: foundation (people/org) → projects → decisions/risks.

`_inbox/` files are never deleted. The inbox is the permanent raw layer.

---

## Finding the Vault

Read `~/.claude/lethe-config.json` → `vault_path`.

If `~/.claude/lethe-config.json` does not exist, tell the user: "No Lethe vault configured. Run `lethe-setup` first." Then stop.

---

## Detect Execution Mode

If this skill was invoked from a cron schedule (no interactive user session), run in **cron mode**: skip the Review Batch approval step and commit automatically.

If invoked interactively, run in **interactive mode**: present the Review Batch summary and wait for approval before writing or committing.

---

## Determine What to Compile

Read `"[vault_path]/_compile-state.json"`:
```json
{"compiled_source_urls": ["https://docs.google.com/...", ...]}
```

If `_compile-state.json` does not exist, create it with `{"compiled_source_urls": []}`.

List all files in `"[vault_path]/_inbox/"`. For each file, read its `source_url` frontmatter field.

**Skip a file if:**
- Its `source_url` is already in `compiled_source_urls` (already processed)
- Its `source_type` is `lint` (lint reports must not be re-compiled as source content)
- It has no `source_url` field (malformed — skip and note in the summary)

Process only the remaining files.

---

## Slug Normalization

When creating filenames for people, projects, decisions, or risks, normalize slugs consistently:
- Lowercase all characters
- Replace spaces and special characters with hyphens
- Strip titles (Dr., Mr., Ms., etc.) and common suffixes (Jr., III, etc.)
- Truncate to 50 characters
- Example: "Dr. Sarah O'Brien" → `sarah-obrien`

Within a single compile run, maintain an in-memory map of `slug → file path` to detect collisions before writing. If two inbox files produce the same slug for different entities, append a disambiguator (e.g., `-2`) to the second.

---

## Pass 1: Foundation — People and Org Structure

Process inbox files **sequentially** so earlier-created files are visible when later files are processed.

For each uncompiled inbox file, extract:
- Named individuals (name, role, team if mentioned)
- Org structure clues (reporting lines, team names, ownership)

For each person found:
1. Normalize their name to a slug
2. Check if `"[vault_path]/resources/[team-slug]/[person-slug].md"` exists
   - If yes: append a new dated entry to their `## Log` section
   - If no: create from `_templates/person.md`, fill in frontmatter, add a `## Log` entry

Log entry format:
```markdown
### YYYY-MM-DD
Source: [source_type] — [brief description of what surfaced this person]
[Observations from the document]
```

For each team or functional area encountered that has no `"[vault_path]/areas/[team-slug]/overview.md"`, create a minimal area file from `_templates/area.md`.

---

## Pass 2: Projects

For each uncompiled inbox file, extract:
- Named projects or initiatives with their goals, status, owners, timelines

For each project found:
1. Normalize the project name to a slug
2. Check if `"[vault_path]/projects/[project-slug]/overview.md"` exists
   - If yes: update the `next_steps` and `updated` fields; add new stakeholders to the list
   - If no: create from `_templates/project.md`, fill in all frontmatter fields found

Use wiki-link format for all cross-references: `"[[resources/team-name/person-slug]]"`

---

## Pass 3: Decisions and Risks

For each uncompiled inbox file, extract:
- Explicit decisions (something was agreed upon, chosen, or resolved)
- Risks or blockers (something that could go wrong, is delayed, or is uncertain)

For each decision or risk:

**Determine scope and placement:**
- Scoped to one project → write to `"[vault_path]/projects/[project-slug]/decision-[slug].md"` or `risk-[slug].md`
- Scoped to a team → write to `"[vault_path]/areas/[team-slug]/decision-[slug].md"` or `risk-[slug].md`
- Org-wide → write to the highest relevant area folder

Create from `_templates/decision.md` or `_templates/risk.md`. Fill in all frontmatter fields. Set `related_projects` and `related_areas` with wiki-links.

---

## Update `_index.md`

After all three passes:
- Add any newly discovered active projects to the **Active Projects** list
- If a project's status changed to `archived` or `completed`, move it from **Active Projects** to **Archived Projects**
- Add or update team structure if new teams were found

---

## Review Batch (interactive mode only)

Collect all writes from the three passes. Do NOT write any files to disk yet.

Present a summary to the user:

```
Ready to compile [N] inbox files. Here's what I'll write:

People to create/update: [list names and paths]
Projects to create/update: [list names and paths]
Decisions to capture: [list slugs and one-line descriptions]
Risks to capture: [list slugs and one-line descriptions]

Options:
  approve all  — write everything and commit
  skip all     — mark all as compiled (skip silently, no vault writes)
  review       — go through each item one by one
```

Wait for response.

**On "approve all":** write all files, update `_compile-state.json`, commit.

**On "skip all":** do NOT write vault files. Update `_compile-state.json` to mark all inbox files as compiled (so they are not retried on the next run). Commit state only.

**On "review":** present each item individually. For each: "Write this? (yes / skip)". Collect answers. After reviewing all items, write only the approved ones, update `_compile-state.json` for all reviewed items (approved and skipped), commit.

---

## Commit

After writing vault files (and in cron mode, after all three passes):

Update `_compile-state.json`: add the `source_url` of every processed inbox file to `compiled_source_urls`.

```bash
git -C "[vault_path]" add -A
git -C "[vault_path]" commit -m "lethe: compile [YYYY-MM-DD] — [N] files processed"
```

Report: "Compiled [N] files. Vault updated."
