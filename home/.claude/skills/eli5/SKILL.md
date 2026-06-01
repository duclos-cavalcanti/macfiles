---
name: eli5
description: Re-explain the previous assistant response in terser, plainer, more direct terms. Strip jargon, drop optional caveats, prefer one-line examples over prose.
---

# ELI5

Re-render the most recent assistant response — same facts and conclusions, half the length.

## Rules

- **Half the length max.** If the original was already short, expand only with a concrete example, never with prose.
- **Plain words first.** Strip jargon unless the user already used it earlier in this conversation. If a technical term is unavoidable, define it inline in 5 words or fewer.
- **Drop optional caveats and edge cases.** State the rule; skip the exceptions. The user can ask.
- **Concrete beats abstract.** A one-line example beats a paragraph of description.
- **Same facts, same conclusions.** Don't change opinions, don't introduce new claims, don't contradict the prior answer. Just compress.
- **No meta-commentary.** Do not preface with "in simpler terms" or "to put it plainly". Just give the simpler version directly.

## If the previous answer was already simple

Say so in one line and stop. Don't pad. Example:

> Already as terse as it gets — `cmux markdown open <file>`.

## If the previous turn was a tool result or a question

Ask which earlier response the user meant before rewriting anything.
