#!/usr/bin/env bash
set -euo pipefail

# git-sync.sh — Stage, commit, and push changes on the current branch.
# Usage:
#   ./scripts/git-sync.sh                  # auto-generate commit message
#   ./scripts/git-sync.sh "custom message" # use a custom commit message

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# ── Check for changes ────────────────────────────────────────────────
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "Nothing to commit."
  exit 0
fi

# ── Stage everything ─────────────────────────────────────────────────
git add -A

# ── Build commit message ─────────────────────────────────────────────
if [ -n "${1:-}" ]; then
  MSG="$1"
else
  # Auto-generate a message from the changed files
  CHANGED=$(git diff --cached --name-only)
  MSG=""

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      projects/*/notes/*)
        slug=$(echo "$file" | sed 's|projects/\([^/]*\)/notes/\(.*\)\.md|\1/\2|')
        MSG="${MSG:+$MSG, }notes: $slug" ;;
      projects/*/progress.json)
        project=$(echo "$file" | sed 's|projects/\([^/]*\)/.*|\1|')
        MSG="${MSG:+$MSG, }progress: update $project" ;;
      projects/*/curriculum.md)
        project=$(echo "$file" | sed 's|projects/\([^/]*\)/.*|\1|')
        MSG="${MSG:+$MSG, }curriculum: $project" ;;
      projects/*)
        MSG="${MSG:+$MSG, }projects: update $file" ;;
      templates/*|rubrics/*|scripts/*|CLAUDE.md|README.md)
        MSG="${MSG:+$MSG, }dev: update $file" ;;
      *)
        MSG="${MSG:+$MSG, }update $file" ;;
    esac
  done <<< "$CHANGED"

  # Fallback
  [ -z "$MSG" ] && MSG="sync changes"
fi

# ── Commit ────────────────────────────────────────────────────────────
git commit -m "$MSG"

# ── Push ──────────────────────────────────────────────────────────────
BRANCH=$(git branch --show-current)
REMOTE=$(git config "branch.${BRANCH}.remote" 2>/dev/null || echo "")

if [ -n "$REMOTE" ]; then
  git push "$REMOTE" "$BRANCH"
  echo "Pushed to $REMOTE/$BRANCH"
else
  # Try pushing with -u to set upstream
  if git remote | grep -q .; then
    DEFAULT_REMOTE=$(git remote | head -1)
    git push -u "$DEFAULT_REMOTE" "$BRANCH"
    echo "Pushed to $DEFAULT_REMOTE/$BRANCH (upstream set)"
  else
    echo "Committed locally (no remote configured)"
  fi
fi
