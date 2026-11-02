---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Quality and Spec (does the code do what was intended). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review the code mentioning MR, PR, merging, pushing."
source: https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md
---

Two-axis review of code changes against a target reference. Defaults to checking changes since the last commit (`HEAD~1`) when on `main`, or comparing against the base branch `main` when on a feature branch. The user can also supply an explicit fixed point to override this default:

- Quality: is the code high quality, are there any critical concerns?
- Spec: does the code faithfully implement the intent, and does it contradict any docs?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings. Start every sub-agent with a fresh context window.

## Process

### 1. Pin the fixed point

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base)

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

### 2. Gather intent and standards

Repos range from a lone `AGENTS.md` or `readme.md` to multiple `docs/specs` files. Check everything in these locations and any file which appears to capture intent. The step is done when each location has been checked and the found sources are listed.

### 3. Quality

Always carry the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3). Each smell is a labelled heuristic ("possible Feature Envy"), a judgement call rather than a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the change doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

Issue both sub-agent calls together, in the foreground, and aggregate the reports they return.

**Quality sub-agent prompt** should include:

- The full diff command and commit list.
- The paths of the standards files found in step 2 (or "none found").
- **the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The full diff command.
- The strongest intent source found (spec or ticket path, or the commit messages and the user's description), plus the standards file paths.
- The brief: "Report: (a) intended behaviour that is missing or partial; (b) behaviour in the diff that wasn't intended (scope creep); (c) behaviour that looks implemented but wrong; (d) places the diff contradicts behaviour a doc describes. Quote the intent or doc line for each finding. Under 400 words."

When intent comes only from commit messages, findings in (a)–(c) are as strong as those messages are specific; a vague message ("wip", "fix") leaves only (d). Skip the Spec sub-agent only when there is no stated intent and no doc describing the changed code, and note this in the final report.

### 5. Aggregate

Open with one line naming the sources each axis was judged against (e.g. "Quality: AGENTS.md + baseline. Spec: commit messages."), so the reader knows how much weight the findings carry.

Present the two reports under `## Quality` and `## Spec` headings, verbatim or lightly cleaned. Do not merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every quality but implements the wrong thing → **Quality pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Quality fail.**

Reporting them separately stops one axis from masking the other.
