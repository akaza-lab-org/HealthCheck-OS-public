# Learning Log

## Success

- 2026-05-03: `kensin` + `AHK_setting` are already migrated to `akaza-lab-org` remotes. App-side `pytest` passes with 199 tests. AHK v2 is installed and `kenshin_order_bridge.ahk`, `main.ahk`, and `config_editor.ahk` pass `/Validate`.

## Failure

- 2026-05-03: Notion native GitHub sync is not suitable as the primary Notion-to-Issue creation path. Use GitHub Issues/docs/PRs as the agent memory system of record, with Notion as a human overview layer.

## Rules Update

- Treat `config.ini` as terminal-specific local state unless explicitly promoted through a migration/defaults change.
- Treat `kensin` as the workflow source of truth and AHK/EMR as execution targets.
- Treat the clinic sub PC as a USB release workstation: it builds and carries ZIPs, but production settings and AHK coordinates remain terminal-local.

