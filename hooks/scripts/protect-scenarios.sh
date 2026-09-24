#!/usr/bin/env bash
# protect-scenarios — the agent cannot rewrite the contract it is measured
# against.
#
# Scenarios change during the design transition — while a change's spec.md is in
# draft — and at no other time. Then they are edited in place, so git keeps their
# history. Outside it, an edit, overwrite, deletion or rename of an existing
# .feature file is blocked, whether it comes through Edit/Write or through rm,
# mv, git rm or git mv. Creating a new scenario always passes.
#
# An earlier version blocked every edit and told the agent to `git rm` and write
# a fresh file instead. That route erased the history it was meant to protect;
# see "Git is the history" in lib.sh.
#
# Step definitions, unit tests and fixtures are untouched by this hook — they
# follow the code and are expected to churn.
set -uo pipefail

BALKA_INPUT=$(cat)
# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
balka_load_config "${1:-}"

mapfile -t globs < <(balka_cfg_list scenarioGlobs)
[ "${#globs[@]}" -gt 0 ] \
  || balka_note "no scenarioGlobs in .claude/balka.json — scenarios unprotected."

tool=$(printf '%s' "$BALKA_INPUT" | jq -r '.tool_name // empty')
touched=()
case $tool in
  Edit|Write|MultiEdit)
    target=$(printf '%s' "$BALKA_INPUT" | jq -r '.tool_input.file_path // empty')
    [ -n "$target" ] || exit 0
    rel=$(balka_relpath "$target") || exit 0
    balka_matches_any "$rel" "${globs[@]}" || exit 0
    # Creating a scenario that does not exist yet is always fine.
    [ "$tool" = "Write" ] && [ ! -e "$target" ] && exit 0
    touched=("$rel")
    ;;
  Bash)
    cmd=$(printf '%s' "$BALKA_INPUT" | jq -r '.tool_input.command // empty')
    printf '%s' "$cmd" | grep -Eq '(^|[;&|(])[[:space:]]*(git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+)?(rm|mv)([[:space:]]|$)' \
      || exit 0
    cwd=$(printf '%s' "$BALKA_INPUT" | jq -r '.cwd // empty')
    [ -n "$cwd" ] || cwd=$BALKA_PROJ
    set -f
    for word in $cmd; do
      word=${word//[\"\']/}; word=${word%%[;&|)]*}
      case $word in ''|-*) continue ;; /*) path=$word ;; *) path="$cwd/$word" ;; esac
      rel=$(balka_relpath "$path") || continue
      balka_matches_any "$rel" "${globs[@]}" && touched+=("$rel")
    done
    set +f
    ;;
  *) exit 0 ;;
esac
[ "${#touched[@]}" -gt 0 ] || exit 0

# The design transition is open: change the scenario in place, in the open.
balka_open_spec >/dev/null && exit 0

balka_deny "Blocked: ${touched[*]} is an existing scenario, and no design
transition is open.

Scenarios are the contract this change is measured against, and they belong to
the artefact's owner. They change during /balka:spec — while a change's spec.md
is in draft — and nowhere else: not during a fix, not during a feature, not to
match what the code turned out to do.

Routes through:
  - The contract is wrong, or the behaviour changed: run /balka:spec. It opens
    the design transition with a draft spec.md, and the scenario is then edited
    in place, so git keeps its history.
  - You need new behaviour: it gets a new scenario in /balka:spec.

Never delete, recreate, rename or copy a scenario to get past this hook. Git is
where the history lives, and a workaround erases it. If this hook stands in the
way of work that is right, stop, tell the owner, and add it to PROPOSALS.md:
that is a bug in balka, and it is fixed in balka.

Step definitions, unit tests and fixtures are yours to edit freely."
