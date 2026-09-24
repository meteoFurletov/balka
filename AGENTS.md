# balka

A Claude Code plugin: the six-stage AI-native SDLC loop. The repo root is the
plugin. What it does and how it works is in `README.md`; do not restate it here.

- Distributed through the `meteof-skills` marketplace in `../skills`, which lists
  this repo by GitHub source. A release needs no change there.
- Git is the history. No hook, command or template may leave an agent a route
  that deletes, recreates or renames a file to get something done. When one
  does, fix balka's logic; never document the workaround.
- Bump `version` in `.claude-plugin/plugin.json` on every release.
- Validate before committing: `claude plugin validate .`
- Tests: `bash tests/run.sh`. No network, no `gh`.
- An installed plugin's skill descriptions load into every session. Keep the
  count low and the wording tight.
- Formerly `sdlc-loop`. The `.claude/sdlc.json` fallback in
  `hooks/scripts/lib.sh` and the migration step in `commands/init.md` exist for
  repos set up under that name.
- The old personal-OS harness lives on the `v1-personal-os` branch. It is
  frozen: do not merge it into main.
