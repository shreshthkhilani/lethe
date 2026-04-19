# Lethe

A personal knowledge system for staff engineers. Stores context that would otherwise live only in your head — projects, stakeholders, domain knowledge, decisions, risks, communication style — and makes it available to Claude and other AI agents.

The name is intentionally ironic: Lethe is the river of forgetfulness in Greek mythology.

---

## Lifecycle

```
INSTALL          SETUP             DAILY USE               AUTOMATED CYCLES
────────────     ─────────────     ─────────────────────   ──────────────────────
install.sh   →  lethe-setup    →  lethe-lookup            lethe-sweep  (daily)
copies skills    creates vault     explicit capture      ↓  lethe-compile (daily)
to ~/.claude/    seeds _index      Q&A + output filing   ↓  lethe-lint  (nightly)
skills/          seeds CLAUDE.md   passive via CLAUDE.md    reports → _inbox/
                 configures crons
```

---

## Quickstart

**1. Install skills**
```bash
git clone <this-repo> lethe
cd lethe
./install.sh
```

**2. Create your vault**

Open Claude Code in any directory and invoke the `lethe-setup` skill:
```
/lethe-setup
```

Follow the interactive prompts. Takes ~5 minutes.

**3. Start capturing**

In any Claude Code session, you can now:
- Say "remember this" → Claude writes it to your vault
- Work on a project → Claude silently loads relevant context
- Ask "what are my active risks?" → Claude greps your vault and answers
- End a Q&A session → ask Claude to file the output back to the vault

**4. Sweep from Glean** *(work machine only)*

```
/lethe-sweep
/lethe-compile
```

Or let the cron handle it automatically.

---

## What Lives Where

```
your-vault/
  _inbox/       raw documents from Glean (permanent)
  projects/     one folder per active project
  areas/        ongoing responsibilities (team, functional area, org)
  resources/    reference material by topic (people, runbooks, domain, style)
  archives/     completed or inactive items
```

Decisions and risks live inside the project or area that owns them — not in top-level folders. Type is in the frontmatter.

---

## Skills

| Skill | Purpose | When to invoke |
|-------|---------|----------------|
| `lethe-setup` | Create vault on a new machine | Once, after install |
| `lethe-lookup` | Read/write during work | Automatically by Claude; or explicitly to capture |
| `lethe-sweep` | Fetch new docs from Glean into `_inbox/` | Daily (cron) or on-demand |
| `lethe-compile` | Process `_inbox/` into vault entries | After sweep |
| `lethe-lint` | Health checks — stale notes, broken links, connections | Nightly (cron) |

---

## Two Repos

**This repo (Lethe)** — the system. Skills, templates, install script. Clone this on any machine.

**Your vault (Lethe River)** — your data. Created by `lethe-setup`. Private git repo. Never pushed to a public remote. Separate instance per machine — work context at work, personal context at home.

---

## Obsidian

Open your vault path in Obsidian. The wiki-links render as a graph. The Dataview plugin can query frontmatter. Obsidian is optional — the vault is plain markdown and works without it.
