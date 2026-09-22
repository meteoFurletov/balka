#!/usr/bin/env bash
# claim — one change, one main agent.
#
# A change number is reserved the moment an agent takes it, in the repo's shared
# git directory, so every worktree on this machine sees the claim. A claim is a
# symlink named after the number and pointing at the owning worktree; creating a
# symlink is atomic, so two agents asking at once get two different numbers.
#
#   claim.sh next    <artifactDir> <slug>      reserve the next free number and
#                                              print <NNN>-<slug>
#   claim.sh check   <artifactDir> <NNN-slug>  exit 0 if this worktree may work
#                                              on it (claiming it if nobody has),
#                                              3 if another agent holds it
#   claim.sh release <artifactDir> <NNN-slug>  drop this worktree's claim
#
# Agents on other machines share no .git. /balka:deploy catches that collision.
set -euo pipefail

cmd=${1:-}; artifact_dir=${2:-}; arg=${3:-}
if [ -z "$cmd" ] || [ -z "$artifact_dir" ] || [ -z "$arg" ]; then
  echo "usage: claim.sh next|check|release <artifactDir> <slug|NNN-slug>" >&2
  exit 2
fi

top=$(git rev-parse --show-toplevel)
claims="$(git rev-parse --path-format=absolute --git-common-dir)/balka/claims"
mkdir -p "$claims"

num=${arg%%-*}                      # 007-login -> 007
owner() { readlink "$claims/$1" 2>/dev/null || true; }
# -n: an existing claim links to a directory, and plain ln would write inside it.
take()  { ln -sn "$top" "$claims/$1" 2>/dev/null; }

# A claim whose worktree is gone holds nothing.
live() {
  # Not grep -q: it exits at the first match, git takes SIGPIPE, and pipefail
  # would call the main worktree dead.
  [ -d "$1" ] && git worktree list --porcelain | grep -xF "worktree $1" >/dev/null
}

case $cmd in
  next)
    highest=$( { ls "$top/$artifact_dir" 2>/dev/null || true; ls "$claims"; } \
      | { grep -oE '^[0-9]+' || true; } | sed 's/^0*//' | sort -n | tail -n1)
    n=$(( ${highest:-0} + 1 ))
    until take "$(printf '%03d' "$n")"; do n=$((n + 1)); done
    printf '%03d-%s\n' "$n" "$arg"
    ;;
  check)
    take "$num" && exit 0
    held_by=$(owner "$num")
    [ "$held_by" = "$top" ] && exit 0
    if ! live "$held_by"; then
      rm -f "$claims/$num"
      take "$num"
      echo "claim: took over $arg; the worktree that held it ($held_by) is gone." >&2
      exit 0
    fi
    echo "claim: $arg belongs to the agent working in $held_by" \
      "(branch $(git -C "$held_by" branch --show-current))." >&2
    exit 3
    ;;
  release)
    [ "$(owner "$num")" = "$top" ] && rm -f "$claims/$num"
    exit 0
    ;;
  *)
    echo "claim: unknown command $cmd" >&2
    exit 2
    ;;
esac
