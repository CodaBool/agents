---
name: code-review
description: Review a batch of changes along two axes, Quality and Spec, in parallel sub-agents. Use when the user asks for a review before committing or pushing, or names an MR, PR, commit or branch to review.
---

Reviews a **batch**: about ten unrelated changes sitting uncommitted in the working tree, reviewed together before one commit and push. Each change in the batch is reviewed against its own intent, and both axes report per change.

## 1. Observe the diff

- The batch is `git diff HEAD` plus every untracked file (`git ls-files --others --exclude-standard`).

Exclude lockfiles and generated output from what reviewers read. Notes files listed in `AGENTS.md` and similar markdown are intent sources, not code. Stop here if the diff is empty.

Done when you hold one diff command and the list of untracked files.

## 2. Split the batch into changes

Group hunks into **changes**, one per logical fix or feature. Use the shared ticket, the shared feature, or files that only make sense together. Name each change in a few words (`cloud upload replace mode`, `ci workflow`). Hunks that fit nowhere go in a `misc` change.

Done when every changed file and untracked file belongs to exactly one change.

## 3. Gather intent

Check each of these and list what you found:

- `AGENTS.md`, and any docs it points to (`docs/specs/`).
- The diff of the notes files. An item deleted from a TODO list is a claim that it's done. An item still listed but fixed by the diff is stale.

Attach the intent you found to each change. A change with no stated intent is marked `no intent` and gets a Quality review only.

## 4. Spawn both sub-agents in parallel

Send both calls in one message, in the foreground. Each gets the diff command, the untracked file list, the change list from step 2 (name plus files for each), and the standards paths. Tell both: run `npm test`, not `npm run build` (CI runs the build).

**Quality** also gets the smell baseline below, pasted in full. Brief: "For each change, report (a) documented-standard violations, citing file and rule, (b) bugs, and (c) baseline smells, naming the smell and quoting the hunk. Smells are judgement calls; a documented repo standard overrides the baseline. Then list cross-change findings: the same logic duplicated across changes, or one change breaking another. Rank by severity. Report only the top half."

**Spec** also gets each change's intent. Brief: "For each change, report (a) intended behaviour that is missing or partial, (b) behaviour nobody asked for, (c) behaviour that looks implemented but wrong, (d) contradictions with a doc, and (e) notes-file items that are stale or deleted with no code behind them. Quote the intent or doc line for each. Rank by severity. Report only the top half."

Smell baseline (Fowler, _Refactoring_ ch.3), each written as smell → fix:

- **Mysterious Name**: the name hides what it does → rename.
- **Duplicated Code**: same logic shape in several hunks or files → extract it.
- **Feature Envy**: reaches into another object's data more than its own → move it there.
- **Data Clumps**: the same fields travel together → bundle them.
- **Primitive Obsession**: a primitive standing in for a domain concept → give it a type.
- **Repeated Switches**: the same conditional cascade recurs → one shared map.
- **Shotgun Surgery**: one change scatters edits across many files → gather them.
- **Divergent Change**: one file edited for unrelated reasons → split it.
- **Speculative Generality**: hooks or params with no current need → inline them.
- **Message Chains**: long navigation chains → hide the walk behind one method.
- **Middle Man**: mostly delegates → call the real target.
- **Refused Bequest**: ignores most of what it inherits → use composition.

## 5. Aggregate

1. Open with one line naming the diff reviewed and the intent sources for each axis.
2. Show `## Quality` and `## Spec` as the sub-agents returned them, lightly cleaned. Keep the axes apart and don't rerank across them.
3. End with one summary line: finding count per axis and the worst finding within each axis.
4. Add `## Commit split`: one short lowercase message per change from step 2 (`fix cloud upload double merge`), with its files. The user can commit the batch as one commit or split it along these lines.
