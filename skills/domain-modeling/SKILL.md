---
name: domain-modeling
description: Clarify a project's domain model during design or implementation. Use for ambiguous terminology, entity relationships, business rules, or conflicts between a feature spec and code.
source: https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md
---

# Domain Modeling

Model the part of the domain needed for the current feature. Follow the project's `AGENTS.md` and use its existing documentation conventions.

## Work through the model

1. **Name the concepts.** Read relevant specs and code. When a term is vague or overloaded, distinguish its possible meanings and propose names grounded in the project. For example, ask whether “account” means a customer organization or a login user. Continue when each concept needed for the feature has a clear meaning.

2. **Test relationships and rules.** Use concrete scenarios: state changes, optional or one-to-many relationships, partial failures, deletion, duplication, and concurrent changes where relevant. State the invariants each scenario reveals. Continue when the model explains the feature's important cases and boundaries.

3. **Resolve discrepancies.** Compare intended, documented, and implemented behavior. Surface consequential conflicts and ask targeted questions when the choice changes the design. Treat existing code as evidence, then establish which rule the feature should follow before implementing work that depends on it.

4. **Record lasting decisions.** Update the relevant existing feature spec (usually in `docs/specs/`) with the concept, rule, or relationship, why it matters, and any important constraint. Put a system-wide rule in an existing `docs/architecture.md` when appropriate. Keep each decision in one place. If no relevant document exists, explain the model in the conversation; create a spec when the work warrants one or the user requests it.

## Finish

Summarize the clarified concepts and relationships, unresolved questions, and documentation updated. For an exploratory discussion, the conversation itself can be the deliverable.
