# Lethe Lookup

Read and write to the Lethe River knowledge vault. Used by both the user (explicitly) and Claude (silently as context is needed).

## Finding the Vault

Read `~/.claude/lethe-config.json` to get the vault path:
```json
{"vault_path": "/your/chosen/path/lethe-river"}
```

If `~/.claude/lethe-config.json` does not exist, tell the user: "No Lethe vault configured. Run `lethe-setup` to create one." Then stop.

All paths below are relative to `vault_path`.

---

## Wiki-Link Format

All cross-references use Obsidian-style wiki-links. Two canonical forms:

- **Link to a specific file:** `"[[projects/project-phoenix/decision-auth]]"` (no `.md` extension)
- **Link to a project or area overview:** `"[[projects/project-phoenix]]"` — this resolves to `projects/project-phoenix/overview.md`

Always use the shortest unambiguous form. When in doubt, link to the specific file.

---

## Retrieval — When to Load Context

Load context proactively when the conversation implies a relevant domain. Do not ask the user for permission — fetch silently, then proceed.

**Always load `_index.md`** when:
- The session is broad (planning, team review, cross-project discussion)
- You have no other signal about what's relevant

**Load a project folder** (`projects/[name]/`) when:
- Working in a specific codebase or repo
- The user names a project explicitly

**Load a person file** (`resources/[team]/[name].md`) when:
- The user mentions someone by name and their file already exists in the vault

**Ripgrep for type + status** when:
- Cross-cutting query: "what are my active risks", "what projects are blocked"
- Use: `rg "type: risk" "[vault_path]" -l` then filter by status field

**One-hop traversal:**
When loading any file, also load files referenced in these frontmatter fields: `related`, `related_decisions`, `related_risks`, `stakeholders`, `owner`.

---

## Retrieval — How to Load

1. Read `~/.claude/lethe-config.json` → get `vault_path`
2. Read `[vault_path]/_index.md` (always for broad sessions)
3. Use Glob or Read to load targeted files/folders
4. Summarize what you loaded in one sentence before proceeding: "Loaded context for Project Phoenix and 2 related stakeholders."

---

## Capture — Explicit ("remember this")

When the user asks you to remember, capture, or save something:

1. Determine the correct `type`: `project` | `area` | `person` | `resource` | `decision` | `risk`

   **Type defaults (when ambiguous):**
   - Ideation / exploration, no timeline or deliverable → `area`
   - Clear deliverable, owner, or deadline → `project`
   - Framework, concept, or reference material → `resource`
   Make a call and state it. Don't ask unless genuinely ambiguous between two equally valid options.

   **Person capture rule:** Only capture a `person` if: (a) the user explicitly asks, OR (b) the person is a confirmed colleague AND you know their role and team. If they appear to be a colleague but role/team is unknown, ask before creating the file. Never create a person file from a name mention alone.

2. Determine scope: which project or area folder does this belong to?
   - Project-scoped → `projects/[project-slug]/`
   - Team-scoped → `areas/[team-slug]/overview.md` (always use folder structure, never a flat `areas/[slug].md`)
   - Reference/style/runbook → `resources/[topic-slug]/`
3. Check if a file already exists for this topic. If so, update it. If not, create from the appropriate template in `_templates/`.
4. **Slug collision:** if a file with the intended slug already exists for a different topic, disambiguate: `decision-auth-oauth.md` vs `decision-auth-saml.md`. Never overwrite an unrelated file.
5. Write the file with correct YAML frontmatter and wiki-links to related files.
6. Set `updated: [today's date]`
7. Show the user a summary: list each file being created or modified with a one-line description of the change. Ask: "Does this look good? I'll commit once you confirm."
8. Wait for confirmation. On confirmation:
```bash
git -C "[vault_path]" add -A
git -C "[vault_path]" commit -m "lethe: capture [topic]"
git -C "[vault_path]" remote | grep -q . && git -C "[vault_path]" push
```
9. Tell the user: "Captured to `[relative path]`."

---

## Capture — Output Filing

At the end of a Q&A conversation that produced useful output (a risk analysis, a decision, a project update, a stakeholder brief):

1. Synthesize the conversation into a structured document — NOT a transcript
2. Determine the type. If it doesn't map cleanly to project/decision/risk/person/area, use `type: resource, category: reference`
3. Write to the appropriate vault location
4. Show the user a summary of what will be filed and ask: "Does this look good? I'll commit once you confirm."
5. Wait for confirmation. On confirmation:
```bash
git -C "[vault_path]" add -A
git -C "[vault_path]" commit -m "lethe: file output [topic]"
git -C "[vault_path]" remote | grep -q . && git -C "[vault_path]" push
```
6. Tell the user: "Filed to `[relative path]`."

---

## Frontmatter Schema Reference

**project:** `type`, `status` (active|blocked|completed|archived), `owner`, `stakeholders[]`, `related[]`, `related_decisions[]`, `related_risks[]`, `next_steps`, `tags[]`, `updated`

**area:** `type`, `status` (active|archived), `related[]`, `tags[]`, `updated`

**person:** `type`, `role`, `team`, `related_projects[]`, `tags[]`, `updated` + `## Log` section with dated entries

**resource:** `type`, `category` (runbook|domain|reference|style|tool), `tags[]`, `updated`

**decision:** `type`, `status` (open|resolved|accepted), `related_projects[]`, `related_areas[]`, `tags[]`, `updated`

**risk:** `type`, `status` (open|accepted|mitigated), `related_projects[]`, `related_areas[]`, `tags[]`, `updated`

**self:** Special case — `resources/self.md` uses `type: person` and tracks the user's own achievements, growth areas, and notable work in `## Log` entries. Created by `lethe-setup`.

---

## Passive Capture (Standing Instruction)

This behavior is defined in `CLAUDE.md` at the vault root — always active, no invocation needed.

While working:
- Decision made → write `decision-[slug].md` to the owning project or area folder
- Risk identified → write `risk-[slug].md` to the owning project or area folder
- New person mentioned who is a confirmed colleague AND whose role and team are known → create or update `resources/[team]/[name].md`. If role or team is unknown, ask before capturing. Never create a person file from a name mention alone.
- Noteworthy project fact → update the project's `overview.md`

After capturing: "I've captured [what] to `[path]`."
