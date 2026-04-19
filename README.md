# Lethe

A personal knowledge system for engineers and engineering leaders. Stores context that would otherwise live only in your head — projects, stakeholders, domain knowledge, decisions, risks, communication style — and makes it available to Claude and other AI agents.

<p align="center">
  <img src="static/lethe.png" alt="Lethe" width="400" />
  <br/>
  <em>Lethe, the underworld river of oblivion, is a personal knowledge system to help engineers and engineering leaders remember everything.</em>
</p>

---

## Skills

| Skill | When | What it does |
|-------|------|-------------|
| `lethe-setup` | Once, on a new machine | Creates your vault, walks through guided questions to seed it, configures crons |
| `lethe-lookup` | Every session (automatic) | Loads relevant context silently; captures when you say "remember this"; files output at the end of a Q&A |
| `lethe-sweep` | Daily or on-demand | Fetches new docs from Glean into `_inbox/` |
| `lethe-compile` | After every sweep | Reads `_inbox/`, extracts people, projects, decisions, and risks; writes structured notes to the vault |
| `lethe-lint` | Nightly (cron) | Health checks — stale notes, broken links, orphans, connection candidates. Report lands in `_inbox/` |

---

## Quickstart

**1. Install skills**
```bash
git clone <this-repo> lethe
cd lethe
./install.sh
```

**2. Create your vault**

Open Claude Code in any directory and invoke the `lethe-setup` skill by typing its name.

Follow the interactive prompts. Takes ~5 minutes.

**3. Start capturing**

In any Claude Code session, you can now:
- Say "remember this" → Claude writes it to your vault
- Work on a project → Claude silently loads relevant context
- Ask "what are my active risks?" → Claude greps your vault and answers
- End a Q&A session → ask Claude to file the output back to the vault

**4. Sweep from Glean** *(requires Glean MCP)*

Invoke the `lethe-sweep` skill, then `lethe-compile`.

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

## Two Repos

**This repo (Lethe)** — the system. Skills, templates, install script. Clone this on any machine.

**Your vault (Lethe River)** — your data. Created by `lethe-setup`. Private git repo. Never pushed to a public remote.

---

## Obsidian

Open your vault path in Obsidian. The wiki-links render as a graph. The Dataview plugin can query frontmatter. Obsidian is optional — the vault is plain markdown and works without it.
