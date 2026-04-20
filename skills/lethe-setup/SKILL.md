# Lethe Setup

One-time interactive initialization of a Lethe River vault. Run this once per machine after `install.sh`.

---

## Precondition: Check for existing vault

Read `~/.claude/lethe-config.json`.

- If it exists and `vault_path` is set: tell the user "A vault already exists at `[vault_path]`. Run lethe-setup again only if you want to create a new vault at a different path — this will not overwrite your existing vault, but will update `~/.claude/lethe-config.json` to point to the new one. Continue? (yes/no)" Wait for their answer. If no, stop.
- If it does not exist: proceed.

---

## Step 1: Choose vault location

Ask the user:
> "Where should I create your Lethe River vault? Please provide a full path. Example: `/Users/you/work/lethe-river`"

Wait for their answer. Call this value `VAULT_PATH`. Do not suggest or default to `~/lethe-river` or any home directory path.

Write to `~/.claude/lethe-config.json` (create `~/.claude/` if it doesn't exist):

```bash
mkdir -p "$HOME/.claude"
echo "{\"vault_path\": \"$VAULT_PATH\"}" > "$HOME/.claude/lethe-config.json"
```

---

## Step 2: Create folder structure

```bash
mkdir -p "$VAULT_PATH"/{_inbox,projects,areas,resources,archives,_templates}
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

Write responses into `$VAULT_PATH/_index.md`:

```markdown
# Index

**Role:** [answer 1]
**Company:** [answer 2]
**Team:** [answer 3]
**Manager:** [answer 4]
**Current Period:** [answer 6]

## Active Projects

[answer 5 — one bullet per project]

## Archived Projects

(moved here when status changes to archived)

## Team Structure

(fill in as context develops)

## Domain Notes

(fill in as context develops)
```

---

## Step 4: Copy templates

Templates were installed by `install.sh` to `~/.claude/lethe-templates/`. Copy them into the vault:

```bash
cp "$HOME/.claude/lethe-templates/"* "$VAULT_PATH/_templates/"
```

---

## Step 5: Create `CLAUDE.md`

Write to `$VAULT_PATH/CLAUDE.md`:

```markdown
# Lethe River — Passive Capture

**Vault config:** `~/.claude/lethe-config.json`

When working with the user in any Claude Code session, passively watch for context about **the user's own work** (their team, their projects, their direct domain). Capture the following:

- If a **decision** is made within the user's scope of work, write a `decision-[slug].md` file to the owning project or area folder (`type: decision`)
- If a **risk** is identified within the user's scope of work, write a `risk-[slug].md` file to the owning project or area folder (`type: risk`)
- If a **new person** is mentioned who is a confirmed colleague AND whose role and team are known, create or update their file at `resources/[team]/[name-slug].md` (`type: person`). If role or team is unknown, ask before capturing. Never create a person file from a name mention alone.
- If a **noteworthy project fact** surfaces (status change, blocker, key decision), update the relevant project's `overview.md`

Do NOT capture decisions or risks from external articles, third-party documentation, or general industry discussion — only from the user's active work context.

After capturing anything: tell the user — "I've captured [what] to `[relative path]`."

Read `~/.claude/lethe-config.json` to get the vault path.
```

---

## Step 6: Initialize state files

Write `$VAULT_PATH/_sweep-state.json`:
```json
{
  "last_sweep": null,
  "sources_covered": []
}
```

Write `$VAULT_PATH/_compile-state.json`:
```json
{
  "compiled_source_urls": []
}
```

---

## Step 7: Initialize git repo

```bash
git -C "$VAULT_PATH" init
git -C "$VAULT_PATH" add -A
git -C "$VAULT_PATH" commit -m "lethe: initial vault setup"
```

The vault is local by default — no push is needed. If the user wants a GitHub remote, they can add it later:
```bash
git -C "$VAULT_PATH" remote add origin https://github.com/ORG/REPO
git -C "$VAULT_PATH" push -u origin main
```

---

## Step 8: Configure crons (optional)

Ask:
> "Would you like to set up automated cron schedules?
> - **Daily sweep + compile** — fetches new docs from Glean each morning and compiles them into the vault
> - **Nightly lint** — health checks while you sleep, report waiting for you in the morning
>
> Options: both / sweep-only / lint-only / skip"

**Note:** Remote cron agents run in Anthropic's cloud and require vault access via a GitHub repo. If no remote is configured, warn the user that crons will not work until the vault is pushed to GitHub, and suggest configuring the remote first or skipping crons for now.

If they choose any crons, use Claude Code's `/schedule` system to configure them. Then write `$VAULT_PATH/_crons.md`:

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

Create `$VAULT_PATH/resources/self.md` from `_templates/person.md`. Fill in frontmatter with the user's name, role, and team from their answers in Step 3.

Note: `self.md` lives at the top level of `resources/` (not in a team subfolder) as a special case — it represents the user themselves, not a colleague. It is intentionally excluded from lint's orphan check.

Tell the user: "I've created `resources/self.md` — use this to log your own achievements and areas for growth. It feeds into performance self-reviews."

---

## Step 10: Done

Tell the user:
- Vault created at `$VAULT_PATH`
- Config written to `~/.claude/lethe-config.json`
- What was seeded in `_index.md` (brief summary)
- What crons were configured (or "none")
- Next steps: "Use `lethe-lookup` to capture knowledge as you work. Run `lethe-sweep` followed by `lethe-compile` to ingest from Glean."
