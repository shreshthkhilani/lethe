# Lethe Sweep

Fetch new documents from Glean and store them raw in `_inbox/`. This skill only ingests — it does not compile. Run `lethe-compile` after sweeping.

---

## Finding the Vault

Read `~/.claude/lethe-config.json` → `vault_path`.

---

## Step 1: Read sweep state

Read `[vault_path]/_sweep-state.json`.

- If `last_sweep` is `null` → this is the first sweep, fetch all available documents
- Otherwise → fetch documents updated after `last_sweep`

---

## Step 2: Query Glean

Use the Glean MCP tool. Query across all source types. Fan out in parallel using subagents if available:

| Source | What it covers |
|--------|---------------|
| `slack` | Slack messages, threads, DMs |
| `google-docs` | Google Docs |
| `confluence` | Confluence pages |
| `google-meet` | Meeting transcripts and notes |
| `calendar` | Calendar events with meeting notes |

Use `_index.md` context (role, team, active projects) to focus queries on relevant content. Do not fetch unrelated company-wide content.

---

## Step 3: Write to `_inbox/`

For each document returned by Glean:

**Skip if:**
- A file with the same `source_url` already exists in `_inbox/` (deduplication)
- The document is a calendar invite with no body/notes
- The document is an automated notification with no substantive content

**Otherwise, write to `[vault_path]/_inbox/[YYYY-MM-DD]-[source_type]-[slug].md`:**

Where `[slug]` is the document title sanitized to lowercase-hyphenated form (max 50 chars).

File content:
```markdown
---
source_url: "[original URL from Glean]"
source_type: [slack|google-docs|confluence|google-meet|calendar]
ingested: [today YYYY-MM-DD]
---

[full document content as markdown]
```

---

## Step 4: Update sweep state

Write to `[vault_path]/_sweep-state.json`:
```json
{
  "last_sweep": "[ISO 8601 timestamp, e.g. 2026-04-19T09:00:00Z]",
  "sources_covered": ["slack", "google-docs", "confluence", "google-meet", "calendar"]
}
```

---

## Step 5: Commit and report

```bash
git -C [vault_path] add _inbox/ _sweep-state.json
git -C [vault_path] commit -m "lethe: sweep [YYYY-MM-DD] — [N] documents ingested"
```

Tell the user:
"Swept [N] documents into `_inbox/` from [sources covered]. Run `lethe-compile` to process them into the vault."
