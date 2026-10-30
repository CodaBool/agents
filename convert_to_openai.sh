#!/usr/bin/env bash

# Switch path references in text files between Claude and OpenAI conventions.


set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
script=$root/$(basename -- "${BASH_SOURCE[0]}")

if [[ ${1-} != '' && ${1-} != '--status' ]]; then
  printf 'Usage: %s [--status]\n' "${0##*/}" >&2
  exit 2
fi

claude_files=()
agents_files=()
while IFS= read -r -d '' file; do
  [[ $file == "$script" ]] && continue
  if LC_ALL=C grep -IqF -- '.claude' "$file"; then
    claude_files+=("$file")
  fi
  if LC_ALL=C grep -IqF -- '.agents' "$file"; then
    agents_files+=("$file")
  fi
done < <(find "$root" -path "$root/.git" -prune -o -type f -print0)

if (( ${#claude_files[@]} && ${#agents_files[@]} )); then
  printf 'Mixed state: both .claude and .agents references exist; no files changed.\n' >&2
  exit 1
elif (( ${#claude_files[@]} )); then
  current=.claude
  next=.agents
  files=("${claude_files[@]}")
elif (( ${#agents_files[@]} )); then
  current=.agents
  next=.claude
  files=("${agents_files[@]}")
else
  printf 'Current state: unknown (no .claude or .agents references found).\n' >&2
  exit 1
fi

if [[ ${1-} == '--status' ]]; then
  printf 'Current state: %s\n' "$current"
  exit 0
fi

if [[ $current == .claude ]]; then
  perl -pi -e 's/\.claude/.agents/g' -- "${files[@]}"
else
  perl -pi -e 's/\.agents/.claude/g' -- "${files[@]}"
fi
printf 'Current state: %s (%s files updated)\n' "$next" "${#files[@]}"
