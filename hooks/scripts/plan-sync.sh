#!/usr/bin/env bash
# plan-sync — when implementation departs from the plan, plan.md changes in the
# same commit.
#
# Departure is defined as the plan's own "Files that change" list being wrong,
# which is the only form of departure a script can see. A commit staying inside
# the planned file set passes untouched, so this is silent through a normal task.
set -uo pipefail

BALKA_INPUT=$(cat)
# shellcheck source=./lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
balka_load_config "${1:-}"

# hooks.json also filters with `if`, but that is a registration-time convenience
# and its handling of compound commands is not something to rely on. The script
# is the authority.
cmd=$(printf '%s' "$BALKA_INPUT" | jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0
printf '%s' "$cmd" | grep -Eq '(^|[;&|]|&&)[[:space:]]*git([[:space:]]+-[^[:space:]]+([[:space:]]+[^[:space:]]+)?)*[[:space:]]+commit([[:space:]]|$)' || exit 0

artifact_dir=$(printf '%s' "$BALKA_CONFIG" | jq -r '.artifactDir // empty')
[ -n "$artifact_dir" ] || balka_note "no artifactDir in .claude/balka.json."

staged=$(git -C "$BALKA_PROJ" diff --cached --name-only 2>/dev/null) \
  || balka_note "cannot read the git index."
[ -n "$staged" ] || exit 0

# There is no pointer to "the" active change: several can be in flight at once,
# each on its own branch or worktree. The plans in play are the accepted ones —
# accepted is the status a plan holds while it is being built. None means no
# build is running, and a commit outside the loop is not this hook's business.
plans=()
for f in "$BALKA_PROJ/$artifact_dir"/*/plan.md; do
  [ -f "$f" ] || continue
  status=$(grep -m1 -oE 'Status:[[:space:]]*[a-z]+' "$f" | awk '{print $2}')
  [ "$status" = accepted ] && plans+=("${f#"$BALKA_PROJ"/}")
done
[ "${#plans[@]}" -gt 0 ] || exit 0

mapfile -t artifact_paths < <(balka_cfg_list artifactPaths)

code=""
while IFS= read -r file; do
  [ -n "$file" ] || continue
  # A plan moving with the code is exactly what this hook wants to see.
  case "$file" in "$artifact_dir"/*/plan.md) exit 0 ;; esac
  # Artefacts are always allowed to move — AGENTS.md and REVIEW.md live at the
  # repo root, so a single-directory rule would block every commit touching them.
  [ "${#artifact_paths[@]}" -gt 0 ] && balka_matches_any "$file" "${artifact_paths[@]}" && continue
  code="$code$file"$'\n'
done <<< "$staged"
[ -n "$code" ] || exit 0

# The staged code files a plan's "Files that change" list does not cover, one
# per line. Returns 1 when the plan has no such list.
uncovered_by() {
  local planned entry file matched
  planned=$(awk '
    /^#{1,6}[[:space:]]+Files that change[[:space:]]*$/ { inside = 1; next }
    inside && /^#{1,6}[[:space:]]/                      { inside = 0 }
    inside && /^[[:space:]]*[-*][[:space:]]+/ {
      sub(/^[[:space:]]*[-*][[:space:]]+/, "")
      gsub(/`/, "")
      sub(/[[:space:]]+—.*$/, "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      if ($0 != "" && $0 !~ /^</) print
    }
  ' "$1")
  [ -n "$planned" ] || return 1
  mapfile -t planned_arr <<< "$planned"
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    matched=0
    for entry in "${planned_arr[@]}"; do
      entry=${entry#./}; entry=${entry%/}
      [ -n "$entry" ] || continue
      [ "$file" = "$entry" ] && { matched=1; break; }
      case "$file" in "$entry"/*) matched=1; break ;; esac   # a directory covers its tree
      case "$entry" in *[*?]*) balka_matches_any "$file" "$entry" && { matched=1; break; } ;; esac
    done
    [ "$matched" -eq 1 ] || printf '  %s\n' "$file"
  done <<< "$code"
  return 0
}

# One commit carries one change, so one plan must cover all of it. When none
# does, name the closest.
best="" best_missing="" best_n=-1
for plan_rel in "${plans[@]}"; do
  missing=$(uncovered_by "$BALKA_PROJ/$plan_rel") || continue
  [ -n "$missing" ] || exit 0
  n=$(printf '%s\n' "$missing" | grep -c .)
  if [ "$best_n" -lt 0 ] || [ "$n" -lt "$best_n" ]; then
    best=$plan_rel; best_missing=$missing; best_n=$n
  fi
done
[ -n "$best" ] \
  || balka_note "no accepted plan under $artifact_dir/ has a Files that change list."

others=""
[ "${#plans[@]}" -gt 1 ] && others="
It is the closest of ${#plans[@]} accepted plans; none covers the whole commit."

balka_deny "Blocked: this commit departs from $best.

These staged files are not in its \"Files that change\" list:

$best_missing
$others
Two ways through:
  1. The departure is right — add these paths to \"Files that change\" in
     $best and stage it with this commit.
  2. The departure is accidental, or belongs to another change — split these
     files out of this commit."
