# Ask Codex

Thin wrapper for Codex communication. Handles send/wait/validate without modifying content.

## Usage

```
/ask-codex <prompt>
```

## Execution

1. Send prompt to Codex:
```
Bash(cask "<prompt>", run_in_background=true)
```

2. Wait for response:
```
TaskOutput(task_id, block=true, timeout=300000)
```

3. Validate response:
   - Check for valid JSON output (if expected)
   - On timeout: retry once or report error
   - On invalid output: show raw response for debugging

## Options (in prompt)

Add to prompt for specific behavior:
- "Return JSON only" - enforce JSON response
- "Return FileOpsRES format" - expect protocol response

## Error Handling

On failure, return:
```json
{
  "status": "error",
  "reason": "timeout|invalid_json|execution_failed",
  "rawOutput": "<original output for debugging>",
  "originalPrompt": "<prompt sent>"
}
```

## Principles

1. **Thin wrapper**: No content modification, only transport
2. **Debuggable**: Always expose original prompt and raw output on error
3. **Predictable**: Fixed timeout (5min default), single retry on timeout
