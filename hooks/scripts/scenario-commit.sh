#!/usr/bin/env bash
# scenario-commit — the contract moves only with the spec, whatever wrote it.
#
# protect-scenarios sees Edit and Write. It does not see a shell redirect, sed,
# or a patch, and an agent working through the shell rewrites a .feature file
# without it noticing. This hook closes that at the commit: a staged
# modification, deletion or rename of a .feature file that exists in HEAD is
# allowed only when the active change's spec.md is staged with it. A new file
# passes — creation is the design transition doing its job.
set -uo pipefail

BALKA_INPUT=$(cat)
# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
balka_load_config "${1:-}"

cmd=$(printf '%s' "$BALKA_INPUT" | jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0
printf '%s' "$cmd" | grep -Eq '(^|[;&|]|&&)[[:space:]]*git([[:space:]]+-[^[:space:]]+([[:space:]]+[^[:space:]]+)?)*[[:space:]]+commit([[:space:]]|$)' || exit 0

mapfile -t globs < <(balka_cfg_list scenarioGlobs)
[ "${#globs[@]}" -gt 0 ] || exit 0

# A repo with no commits has nothing to protect: everything staged is new.
git -C "$BALKA_PROJ" rev-parse --verify -q HEAD >/dev/null 2>&1 || exit 0

staged=$(git -C "$BALKA_PROJ" diff --cached --name-status 2>/dev/null) \
  || balka_note "cannot read the git index."
[ -n "$staged" ] || exit 0

moved=""
while IFS=$'\t' read -r status path rest; do
  [ -n "$path" ] || continue
  case "$status" in
    A*) continue ;;                       # creation passes
    R*|C*) [ -n "$rest" ] && path="$path -> $rest" ;;
  esac
  first=${path%% -> *}
  if balka_matches_any "$first" "${globs[@]}"; then
    moved="$moved  $status  $path"$'\n'
  fi
done <<< "$staged"
[ -n "$moved" ] || exit 0

artifact_dir=$(printf '%s' "$BALKA_CONFIG" | jq -r '.artifactDir // empty')
[ -n "$artifact_dir" ] || balka_note "no artifactDir in .claude/balka.json — a scenario is moving unchecked."

# Any change's spec.md counts: several changes can be in flight at once, and
# there is no pointer saying which one this commit belongs to.
while IFS=$'\t' read -r _ path _; do
  case "$path" in "$artifact_dir"/*/spec.md) exit 0 ;; esac
done <<< "$staged"
spec_rel="$artifact_dir/<change>/spec.md"

balka_deny "Blocked: this commit moves the scenario contract without its spec.

$moved
Scenarios change at the design transition and nowhere else, and the commit that
changes one carries $spec_rel with it. That pairing is what review looks for.

Routes through:
  - This is the design transition: stage $spec_rel with this commit.
  - It is not: unstage the .feature changes. Build changes code and binding glue,
    never the scenarios — take the change to /balka:spec."
