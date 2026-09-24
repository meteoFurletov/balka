# Shared machinery for the balka hooks.
#
# Every hook is registered by the plugin in every session and is inert in any
# repo that has not opted in. Opting in is one file: .claude/balka.json.
#
# Three rules hold throughout:
#   - Git is the history. A hook never leaves deleting, recreating or renaming a
#     file as the only way through: that erases the history it exists to keep.
#     When a hook blocks work that is right, the hook is wrong, and the fix
#     belongs in balka.
#   - A hook that cannot establish its condition allows the action and says why.
#     Ambiguity never blocks.
#   - Nothing ever emits permissionDecision "allow". An explicit allow from a
#     PreToolUse hook bypasses the user's own permission settings; declining to
#     decide (exit 0) leaves those settings in force.

# Cannot establish the condition: say why, allow the action.
balka_note() {
  jq -n --arg m "balka: $1" '{systemMessage: $m}'
  exit 0
}

balka_deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

balka_ask() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# Which checkout the action is in. ${CLAUDE_PROJECT_DIR} arrives as $1 and stays
# at the checkout the session started in; the input's `cwd` follows the agent
# into a worktree and on through `cd`. So the git top level of `cwd` wins, and
# $1 is the fallback. Hooks themselves run elsewhere, so every git call must be
# `git -C "$BALKA_PROJ"`.
balka_load_config() {
  local cwd
  cwd=$(printf '%s' "${BALKA_INPUT:-}" | jq -r '.cwd // empty' 2>/dev/null)
  BALKA_PROJ=""
  [ -n "$cwd" ] && BALKA_PROJ=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  [ -n "$BALKA_PROJ" ] || BALKA_PROJ=${1:-$PWD}
  BALKA_CFG="$BALKA_PROJ/.claude/balka.json"
  # A repo that opted in before the rename from sdlc-loop still counts.
  [ -f "$BALKA_CFG" ] || BALKA_CFG="$BALKA_PROJ/.claude/sdlc.json"
  [ -f "$BALKA_CFG" ] || exit 0

  command -v jq >/dev/null 2>&1 || exit 0
  jq -e . "$BALKA_CFG" >/dev/null 2>&1 \
    || balka_note "${BALKA_CFG#"$BALKA_PROJ"/} is not valid JSON — no gate applied."
  BALKA_CONFIG=$(cat "$BALKA_CFG")
}

# Read a string array out of the config, one entry per line.
balka_cfg_list() {
  printf '%s' "$BALKA_CONFIG" | jq -r --arg k "$1" '(.[$k] // []) | .[]'
}

# Turn a shell glob into an anchored regex. `**/` spans directories, `*` and `?`
# stop at a separator, everything else is literal. Bash [[ ]] cannot do this:
# globstar only affects pathname expansion, so `features/**/*.feature` would
# never match `features/login.feature`.
balka_glob_to_regex() {
  printf '%s' "$1" | awk '
    {
      out = "^"; n = length($0)
      for (i = 1; i <= n; i++) {
        c = substr($0, i, 1)
        if (c == "*") {
          if (substr($0, i, 3) == "**/")     { out = out "(.*/)?"; i += 2 }
          else if (substr($0, i, 2) == "**") { out = out ".*";     i += 1 }
          else                               { out = out "[^/]*" }
        }
        else if (c == "?")                        { out = out "[^/]" }
        else if (index(".^$+(){}[]|\\", c) > 0)   { out = out "\\" c }
        else                                      { out = out c }
      }
      print out "$"
    }'
}

balka_matches_any() {
  local path=$1 glob
  shift
  for glob in "$@"; do
    [ -n "$glob" ] || continue
    printf '%s' "$path" | grep -Eq "$(balka_glob_to_regex "$glob")" && return 0
  done
  return 1
}

# Repo-relative, normalised. Returns 1 for a path outside the project.
balka_relpath() {
  local path=$1
  case $path in
    "$BALKA_PROJ"/*) path=${path#"$BALKA_PROJ"/} ;;
    /*)             return 1 ;;
  esac
  printf '%s' "${path#./}"
}

# The design transition is open while a change's spec.md is in draft: that is
# when scenarios change, in place, and at no other time. Prints that spec.md;
# returns 1 when every spec is settled.
balka_open_spec() {
  local dir f
  dir=$(printf '%s' "$BALKA_CONFIG" | jq -r '.artifactDir // empty')
  [ -n "$dir" ] || return 1
  for f in "$BALKA_PROJ/$dir"/*/spec.md; do
    [ -f "$f" ] || continue
    if grep -m1 -oE 'Status:[[:space:]]*[a-z]+' "$f" | grep -q 'draft$'; then
      printf '%s' "${f#"$BALKA_PROJ"/}"
      return 0
    fi
  done
  return 1
}
