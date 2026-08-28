# OpenCode Go usage routing

## Goal

Use the OpenCode Go subscription efficiently by assigning models according to workload.

## Model assignments

- Default model: `opencode-go/deepseek-v4-pro`
- Lightweight internal tasks: `opencode-go/glm-5.3-flash`
- Built-in `general` subagent: `opencode-go/glm-5.3-flash`
- Built-in `explore` subagent: `opencode-go/glm-5.3-flash`
- Difficult design and review work: select a suitable model manually with `/models`; do not pin it in configuration

## Configuration constraints

- Keep existing MCP and unrelated configuration unchanged.
- Do not add an explicit `provider` entry for the built-in OpenCode Go provider.
- Use the documented `model`, `small_model`, and `agent.<name>.model` keys.

## Verification

- `opencode debug config --pure` resolves the intended default, small, and subagent models.
- Existing `pencil` and `playwright` MCP configuration remains unchanged.
- The final JSONC configuration parses successfully through OpenCode.
