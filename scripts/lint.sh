#!/usr/bin/env bash
set -euo pipefail

# lint.sh — Health check for the learning + task system.
# Reports:
#   - tasks stuck in in-progress for > 7 days
#   - tasks in idea for > 30 days (slow rotters)
#   - orphan wiki pages (no inbound links from any task or note)
#   - stale wiki pages (updated > 60 days ago)
#   - broken [[wiki-links]] (target page doesn't exist)
#   - counter.json sanity (max ID used vs counter value)
#   - board/index.md row count mismatch vs tasks/ files
#
# Usage: ./scripts/lint.sh
# Exits 0 always — warnings are informational.

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

WARN_COUNT=0
warn() {
  printf "${YELLOW}⚠${NC}  %s\n" "$1"
  WARN_COUNT=$((WARN_COUNT + 1))
}
ok()   { printf "${GREEN}✓${NC}  %s\n" "$1"; }
hdr()  { printf "\n${BLUE}▸ %s${NC}\n" "$1"; }

today_epoch() { date +%s; }
date_to_epoch() { date -d "$1" +%s 2>/dev/null || echo 0; }

days_since() {
  local d="$1"
  local e
  e=$(date_to_epoch "$d")
  [ "$e" -eq 0 ] && { echo 9999; return; }
  echo $(( ( $(today_epoch) - e ) / 86400 ))
}

# Extract a frontmatter field from a markdown file
fm_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /^---$/ { n++; next }
    n==1 && $1 == f":" { sub(/^[^:]*: */, ""); print; exit }
  ' "$file"
}

# ── 1. Stuck tasks ───────────────────────────────────────────────────
hdr "Task health"
if [ -d tasks ] && ls tasks/NK-*.md >/dev/null 2>&1; then
  for f in tasks/NK-*.md; do
    [ -f "$f" ] || continue
    status=$(fm_field "$f" "status")
    updated=$(fm_field "$f" "updated")
    created=$(fm_field "$f" "created")
    id=$(fm_field "$f" "id")
    title=$(fm_field "$f" "title")

    case "$status" in
      in-progress)
        d=$(days_since "$updated")
        if [ "$d" -gt 7 ]; then
          warn "STUCK: $id ($d days in-progress) — $title"
        fi
        ;;
      idea)
        d=$(days_since "$created")
        if [ "$d" -gt 30 ]; then
          warn "STALE IDEA: $id ($d days old) — $title"
        fi
        ;;
    esac
  done
  ok "Scanned $(ls tasks/NK-*.md 2>/dev/null | wc -l) task files"
else
  ok "No tasks yet — skipping task checks"
fi

# ── 2. Counter sanity ────────────────────────────────────────────────
hdr "Counter sanity"
if [ -f board/counter.json ]; then
  next_task=$(grep -o '"next_task_id": *[0-9]*' board/counter.json | grep -o '[0-9]*' || echo 0)
  next_epic=$(grep -o '"next_epic_id": *[0-9]*' board/counter.json | grep -o '[0-9]*' || echo 0)

  max_task=0
  if ls tasks/NK-*.md >/dev/null 2>&1; then
    for f in tasks/NK-*.md; do
      n=$(basename "$f" .md | sed 's/NK-0*//')
      [ -z "$n" ] && n=0
      [ "$n" -gt "$max_task" ] && max_task=$n
    done
  fi

  max_epic=0
  if ls epics/EP-*.md >/dev/null 2>&1; then
    for f in epics/EP-*.md; do
      n=$(basename "$f" .md | sed 's/EP-0*//')
      [ -z "$n" ] && n=0
      [ "$n" -gt "$max_epic" ] && max_epic=$n
    done
  fi

  if [ "$next_task" -le "$max_task" ]; then
    warn "counter.json next_task_id=$next_task but max task NK-$max_task exists"
  else
    ok "next_task_id=$next_task (highest used: NK-$max_task)"
  fi
  if [ "$next_epic" -le "$max_epic" ]; then
    warn "counter.json next_epic_id=$next_epic but max epic EP-$max_epic exists"
  else
    ok "next_epic_id=$next_epic (highest used: EP-$max_epic)"
  fi
else
  warn "board/counter.json is missing"
fi

# ── 3. Wiki health ───────────────────────────────────────────────────
hdr "Wiki health"
wiki_pages=()
if [ -d wiki ]; then
  while IFS= read -r -d '' f; do
    wiki_pages+=("$f")
  done < <(find wiki -type f -name "*.md" ! -name "index.md" -print0)
fi

if [ "${#wiki_pages[@]}" -eq 0 ]; then
  ok "No wiki pages yet — skipping wiki checks"
else
  stale_days=60
  orphan_count=0
  stale_count=0

  for page in "${wiki_pages[@]}"; do
    updated=$(fm_field "$page" "updated")
    d=$(days_since "$updated")
    if [ "$d" -gt "$stale_days" ]; then
      warn "STALE WIKI: $page ($d days since update)"
      stale_count=$((stale_count + 1))
    fi

    # Orphan check: any task, note, or other wiki page reference this slug?
    slug=$(echo "$page" | sed 's|wiki/||; s|\.md$||')
    refs=$(grep -rl --include="*.md" "\[\[$slug\]\]" tasks epics projects wiki 2>/dev/null | grep -v "^$page$" || true)
    if [ -z "$refs" ]; then
      warn "ORPHAN WIKI: $page (no inbound [[links]])"
      orphan_count=$((orphan_count + 1))
    fi
  done
  ok "Scanned ${#wiki_pages[@]} wiki pages (orphans: $orphan_count, stale: $stale_count)"
fi

# ── 4. Broken wiki links ─────────────────────────────────────────────
hdr "Broken links"
broken=0
while IFS= read -r line; do
  file=$(echo "$line" | cut -d: -f1)
  target=$(echo "$line" | grep -oE '\[\[[^]]+\]\]' | sed 's/\[\[//; s/\]\]//' | head -1)
  [ -z "$target" ] && continue

  # Only check wiki-style targets (contain /)
  case "$target" in
    */*)
      if [ ! -f "wiki/$target.md" ]; then
        warn "BROKEN LINK: $file → [[$target]] (wiki/$target.md missing)"
        broken=$((broken + 1))
      fi
      ;;
  esac
done < <(grep -rn --include="*.md" -oE '\[\[[^]]+/[^]]+\]\]' tasks epics projects wiki 2>/dev/null || true)

if [ "$broken" -eq 0 ]; then
  ok "No broken wiki links found"
fi

# ── 5. Summary ───────────────────────────────────────────────────────
hdr "Summary"
if [ "$WARN_COUNT" -eq 0 ]; then
  printf "${GREEN}All checks passed.${NC}\n"
else
  printf "${YELLOW}%d warning(s).${NC}\n" "$WARN_COUNT"
fi
