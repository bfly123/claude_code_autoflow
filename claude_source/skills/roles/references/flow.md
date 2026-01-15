# Roles (Lightweight)

Lightweight role management for **all tasks** (not limited to `/tp`/`/tr`).

## Files & Priority

Resolve roles with this priority (highest first):

1) Project config: `<repo>/.autoflow/roles.json`
2) Defaults:
```json
{
  "schemaVersion": 1,
  "enabled": true,
  "executor": "codex",
  "reviewer": "codex",
  "documenter": "codex",
  "designer": ["claude", "codex"],
  "searcher": "codex",
  "web_searcher": "gemini",
  "repo_searcher": "codex",
  "repo_search_enforced": false,
  "git_manager": "codex"
}
```

Rules:
- If `enabled != true` or `schemaVersion != 1`, ignore that file and continue to the next.
- Extra keys (e.g. `_meta`) are allowed and ignored.

## Commands

### `/roles show`

Output:
- Effective roles (merged)
- Source per field (project/default)

Implementation:
- Claude does not read/modify repo files directly.
- Use `/file-op` with `read_file` ops to fetch existing files (best-effort; missing is OK).
- Parse JSON and apply the priority rules above.

### `/roles set <k=v ...>`

Example:
```
/roles set executor=opencode reviewer=codex documenter=gemini designer=claude,codex
```

Behavior:
- Validate keys are in: `executor`, `reviewer`, `documenter`, `designer`, `enabled`, `searcher`, `web_searcher`, `repo_searcher`, `repo_search_enforced`, `git_manager`
- Validate values:
  - `executor`: `codex|opencode`
  - `reviewer`: `codex|gemini`
  - `documenter`: `codex|gemini`
  - `designer`: comma-separated list from `claude|codex|gemini`
  - `searcher`: `claude|codex|opencode|gemini` (legacy single switch)
  - `web_searcher`: `claude|codex|opencode|gemini` (WebSearch/WebFetch)
  - `repo_searcher`: `claude|codex|opencode|gemini` (Grep/Glob and repo-search Bash like `rg`/`grep`/`git grep`; enforced only when `repo_search_enforced=true`)
  - `repo_search_enforced`: `true|false`
  - `git_manager`: `claude|codex|opencode|gemini`
- Write/update `<repo>/.autoflow/roles.json` with a full object:
  - Always include `schemaVersion: 1`
  - Always include `enabled: true` unless user sets otherwise
  - Include all role fields (resolved baseline + overrides) to keep it explicit

Implementation:
- Read current effective roles via `/file-op`.
- Apply overrides.
- Write project roles via `/file-op` (`write_file` or `write_json`).

### `/roles clear`

Behavior:
- Remove `<repo>/.autoflow/roles.json` if present.
- No-op if missing.

Implementation:
- Use `/file-op` with `apply_patch` delete (best-effort).

### `/roles init`

Behavior:
- Ensure `<repo>/.autoflow/roles.json` exists (do not overwrite).
- Initialize from template: `.claude/skills/roles/templates/roles.json`

Implementation:
- Use `/file-op`:
  - Ensure directory `.autoflow/`
  - Write file only if not exists (if /file-op doesn't support conditional, read first then decide)
