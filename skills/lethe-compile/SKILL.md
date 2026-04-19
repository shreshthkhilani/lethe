# Lethe Compile

Read unprocessed files in `_inbox/` and write structured notes to the vault. Three-pass compilation: foundation (people/org) → projects → decisions/risks.

`_inbox/` files are never deleted. The inbox is the permanent raw layer.

---

## Finding the Vault

Read `~/.claude/lethe-config.json` → `vault_path`.

---

## Determine What to Compile

Read `[vault_path]/_compile-state.json`:
```json
{"compiled_files": ["2026-04-10-slack-standup.md", ...]}
```

List all files in `[vault_path]/_inbox/`. Process only files NOT in `compiled_files`.

If `_compile-state.json` does not exist, create it with `{"compiled_files": []}`.

---

## Pass 1: Foundation — People and Org Structure

For each uncompiled inbox file, extract:
- Named individuals (name, role, team if mentioned)
- Org structure clues (reporting lines, team names, ownership)

For each person found, check if `resources/[team-slug]/[person-slug].md` exists:
- If yes: append a new dated entry to their `## Log` section
- If no: create from `_templates/person.md`, fill in frontmatter, add a `## Log` entry

Log entry format:
```markdown
### [YYYY-MM-DD]
[Source: [source_type] — [brief description of what surfaced this person]]
[Observations from the document]
```

For each team or functional area encountered that has no `areas/[team-slug]/overview.md`, create a minimal area file from `_templates/area.md`.

---

## Pass 2: Projects

For each uncompiled inbox file, extract:
- Named projects or initiatives with their goals, status, owners, timelines

For each project found, check if `projects/[project-slug]/overview.md` exists:
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
- Scoped to one project → write to `projects/[project-slug]/decision-[slug].md` or `risk-[slug].md`
- Scoped to a team → write to `areas/[team-slug]/decision-[slug].md` or `risk-[slug].md`
- Org-wide → write to the highest relevant area folder

Create from `_templates/decision.md` or `_templates/risk.md`. Fill in all frontmatter fields. Set `related_projects` and `related_areas` with wiki-links.

---

## Update `_index.md`

After all three passes:
- Add any newly discovered active projects to the Active Projects list
- Add or update team structure if new teams were found
- Do not remove existing entries — only add or update

---

## Review Batch

Before committing, present a summary to the user:

```
Compiled [N] inbox files. Here's what I found:

People updated: [list names]
Projects created/updated: [list names]
Decisions captured: [list slugs and brief descriptions]
Risks captured: [list slugs and brief descriptions]

Approve all, skip all, or review individually?
```

Wait for response. On approval:

```bash
# Update compile state
# (add all newly compiled filenames to compiled_files array in _compile-state.json)

git -C [vault_path] add -A
git -C [vault_path] commit -m "lethe: compile [YYYY-MM-DD] — [N] files processed"
```

Report: "Compiled [N] files. Vault updated."
