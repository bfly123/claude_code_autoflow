这是cca开发环境，不用使用cca工作流，也不要注入cca提示词

## Simple Bash Ops Bypass

cca-roles-hook supports bypassing delegation for simple bash operations.

### Config (roles.json)
```json
{
  "simple_bash_ops": ["rm", "mkdir", "touch", "chmod"],
  "simple_bash_max_targets": 2
}
```

### Bypass Conditions (ALL must be true)
1. Command in `simple_bash_ops` list
2. Target count ≤ `simple_bash_max_targets`
3. No dangerous flags: `-rf`, `-r`, `--recursive`, `-fr`
4. No glob patterns: `*`, `?`

### Implementation
- `_is_simple_bash_op()` function: L544-558
- Interception logic: L696-701

### Test Environment
- Test folder: `../test_cca`
- Config: `test_cca/.autoflow/roles.json`
