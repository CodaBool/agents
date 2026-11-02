# AGENTS.md

A skills repo: each `skills/<name>/SKILL.md` installs into Claude Code and Codex via `npx skills add CodaBool/agents`. Most skills are forks of Matt Pocock's, adapted for a **solo dev**: output lands in local files (`docs/specs/`, `docs/tickets.md`), with no issue trackers, reviewers, or team hand-offs.

## Editing skills

- Load the `writing-for-agents` skill before creating or editing any skill or this file.
- Write frontmatter as flat one-line `key: value` pairs. CI parses it with a line-based reader, so multi-line YAML (`>`, `|`, lists) breaks the readme table.
- `disable-model-invocation: true` marks a skill **manual** (user-invoked only); omit it for **auto**.
- Keep `source:` pointing at the upstream file when a skill is forked, so it can be diffed against upstream later.
- Ship helper scripts as a `.sh` + `.ps1` pair (see `skills/wizard/`, `skills/diagnosing-bugs/scripts/`) so skills work on both Linux and Windows.

## Readme

The skills table between `SKILLS_TABLE_START`/`SKILLS_TABLE_END` in `readme.md` is regenerated from frontmatter by `.github/workflows/main.yml` on every push to `main`. Change a skill's frontmatter to change its row; edit only the readme prose outside the markers.
