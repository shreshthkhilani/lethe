# Lethe Setup

One-time interactive initialization of a Lethe River vault. Run this once per machine after `install.sh`.

---

## Step 1: Choose vault location

Ask the user:
> "Where should I create your Lethe River vault? Please provide a full path. Example: `/Users/you/work/lethe-river`"

Wait for their answer. Do not suggest or default to `~/lethe-river` or any home directory path.

Write to `~/.claude/lethe-config.json`:
```json
{"vault_path": "[chosen_path]"}
```

```bash
echo '{"vault_path": "[chosen_path]"}' > ~/.claude/lethe-config.json
```

---

## Step 2: Create folder structure

```bash
VAULT=[chosen_path]
mkdir -p "$VAULT"/{_inbox,projects,areas,resources,archives,_templates}
```

---

## Step 3: Seed `_index.md` via guided questions

Ask these questions **one at a time**. Wait for each answer before asking the next.

1. "What is your role and title?"
2. "What company do you work at, and in one sentence, what does it do?"
3. "What team are you on, and what does your team own or build?"
4. "Who do you report to?"
5. "List your current active projects (names and one-line descriptions)."
6. "What quarter/period are you in and what is your main focus or goal?"

Write responses into `[vault_path]/_index.md`:

```markdown
# Index

**Role:** [answer 1]
**Company:** [answer 2]
**Team:** [answer 3]
**Manager:** [answer 4]
**Current Period:** [answer 6]

## Active Projects

[answer 5 — one bullet per project]

## Team Structure

(fill in as context develops)

## Domain Notes

(fill in as context develops)
```

---

## Step 4: Copy templates

Ask: "Where is the Lethe system repo (the one you cloned with `install.sh`)?"

```bash
cp [lethe_repo]/templates/* [vault_path]/_templates/
```

---

## Step 5: Create `CLAUDE.md`

Write to `[vault_path]/CLAUDE.md`:

```markdown
# Lethe River — Passive Capture

**Vault location:** [vault_path]

When working with the user in any Claude Code session:

- If a **decision** is made or referenced, write a `decision-[slug].md` file to the owning project or area folder (`type: decision`)
- If a **risk** is identified or referenced, write a `risk-[slug].md` file to the owning project or area folder (`type: risk`)
- If a **new person or stakeholder** is mentioned with context, create or update their file at `resources/[team]/[name-slug].md` (`type: person`)
- If a **noteworthy project fact** surfaces (status change, blocker, key decision), update the relevant project's `overview.md`

After capturing anything: tell the user — "I've captured [what] to `[relative path]`."

Read `~/.claude/lethe-config.json` if you need the vault path.
```

---

## Step 6: Initialize state files

Write `[vault_path]/_sweep-state.json`:
```json
{
  "last_sweep": null,
  "sources_covered": []
}
```

Write `[vault_path]/_compile-state.json`:
```json
{
  "compiled_files": []
}
```

---

## Step 7: Initialize git repo

```bash
git -C [vault_path] init
git -C [vault_path] add -A
git -C [vault_path] commit -m "lethe: initial vault setup"
```

---

## Step 8: Configure crons (optional)

Ask:
> "Would you like to set up automated cron schedules?
> - **Daily sweep + compile** — fetches new docs from Glean each morning and compiles them into the vault
> - **Nightly lint** — health checks while you sleep, report waiting for you in the morning
>
> Options: both / sweep-only / lint-only / skip"

If they choose any crons, use Claude Code's `/schedule` system to configure them. Then write `[vault_path]/_crons.md`:

```markdown
# Configured Cron Schedules

(Informational only — live schedules managed via /schedule in Claude Code)

| Job | Schedule | Skill |
|-----|----------|-------|
| sweep + compile | daily 8:00am | lethe-sweep → lethe-compile |
| lint | nightly 2:00am | lethe-lint |
```

Adjust table to reflect only what was actually configured.

---

## Step 9: Create `resources/self.md`

Create `[vault_path]/resources/self.md` from `_templates/person.md`. Fill in frontmatter with the user's name, role, and team from their answers in Step 3. Tell the user: "I've created `resources/self.md` — use this to log your own achievements and areas for growth. It feeds into performance self-reviews."

---

## Step 10: Done

Tell the user:
- Vault created at `[vault_path]`
- Config written to `~/.claude/lethe-config.json`
- What was seeded in `_index.md` (brief summary)
- What crons were configured (or "none")
- Next steps: "Use `lethe-lookup` to capture knowledge as you work. Run `lethe-sweep` followed by `lethe-compile` to ingest from Glean."
