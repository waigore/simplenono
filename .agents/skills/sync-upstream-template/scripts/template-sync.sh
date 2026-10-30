#!/usr/bin/env bash
# Helpers for the sync-upstream-template skill. Run from the downstream repo root.
#
#   template-sync.sh baseline <target>       Print the baseline upstream commit.
#   template-sync.sh plan <base> <target>    Classify each file upstream changed (read-only).
#   template-sync.sh apply <base> <target>   Apply the plan to the working tree.
#
# Downstream state is read from HEAD, so the working tree must be clean.
# Output lines are tab-separated: <action>\t<path> (plan/apply) or
# <method>\t<sha>\t<score>\t<subject> (baseline).
set -euo pipefail

MARKER='Sync upstream template to'

die() { echo "error: $*" >&2; exit 1; }

resolve() { git rev-parse -q --verify "$1^{commit}" || die "unknown commit: $1"; }

blob() { git rev-parse -q --verify "$1:$2" 2>/dev/null || true; }

require_clean() {
  [[ -z "$(git status --porcelain)" ]] || die "working tree is not clean"
}

# Previous sync: newest commit subject carrying the marker whose SHA is upstream history.
# Fallback: the upstream commits whose tracked files best match HEAD (fewest changed lines).
cmd_baseline() {
  local target sha subject c score best=""
  target="$(resolve "$1")"

  while IFS= read -r subject; do
    sha="$(sed -nE "s/^$MARKER ([0-9a-f]{7,40}).*/\1/p" <<<"$subject")"
    [[ -n "$sha" ]] || continue
    if c="$(git rev-parse -q --verify "$sha^{commit}")" && git merge-base --is-ancestor "$c" "$target"; then
      printf 'log\t%s\t0\t%s\n' "$c" "$(git log -1 --format=%s "$c")"
      return
    fi
  done < <(git log --format=%s HEAD | grep -E "^$MARKER [0-9a-f]{7,40}" || true)

  # Score = changed lines between candidate and HEAD, limited to paths the candidate or
  # target has, so project-only files are ignored. Binary changes count 1.
  local paths
  paths="$(mktemp)"
  git ls-tree -r --name-only "$target" >"$paths.target"
  for c in $(git rev-list --first-parent "$target"); do
    { cat "$paths.target"; git ls-tree -r --name-only "$c"; } >"$paths"
    score="$(git diff --numstat --no-renames "$c" HEAD | awk -F'\t' '
      NR == FNR { keep[$0] = 1; next }
      $3 in keep { s += ($1 == "-" ? 1 : $1 + $2) }
      END { print s + 0 }' "$paths" -)"
    best+="$score"$'\t'"$c"$'\n'
  done
  rm -f "$paths" "$paths.target"
  # Lowest score first; ties keep rev-list order (newest first). Top 3 for confirmation.
  printf '%s' "$best" | sort -s -n -k1,1 | head -n 3 | while IFS=$'\t' read -r score c; do
    printf 'match\t%s\t%s\t%s\n' "$c" "$score" "$(git log -1 --format='%cs %s' "$c")"
  done
}

# Actions:
#   skip                  HEAD already matches upstream target
#   add|update|delete     HEAD unchanged since base: take upstream (template-owned)
#   merge                 both sides changed: 3-way merge (shared)
#   ask-local-deleted     downstream deleted a file upstream changed
#   ask-upstream-deleted  upstream deleted a file downstream edited
#   ask-both-added        both sides added the path with different content
classify() {
  local base="$1" target="$2" path="$3" b t l
  b="$(blob "$base" "$path")"; t="$(blob "$target" "$path")"; l="$(blob HEAD "$path")"
  if [[ "$l" == "$t" ]]; then echo skip
  elif [[ "$l" == "$b" ]]; then
    if [[ -z "$t" ]]; then echo delete; elif [[ -z "$b" ]]; then echo add; else echo update; fi
  elif [[ -z "$l" ]]; then echo ask-local-deleted
  elif [[ -z "$t" ]]; then echo ask-upstream-deleted
  elif [[ -z "$b" ]]; then echo ask-both-added
  else echo merge
  fi
}

changed_paths() { git diff --name-only --no-renames -z "$1" "$2" | tr '\0' '\n'; }

cmd_plan() {
  local base target path
  base="$(resolve "$1")"; target="$(resolve "$2")"
  while IFS= read -r path; do
    printf '%s\t%s\n' "$(classify "$base" "$target" "$path")" "$path"
  done < <(changed_paths "$base" "$target")
}

# merge -> merged-clean | conflict (markers left in file) | ask-binary (file untouched)
cmd_apply() {
  local base target path action rc
  require_clean
  base="$(resolve "$1")"; target="$(resolve "$2")"
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  while IFS= read -r path; do
    action="$(classify "$base" "$target" "$path")"
    case "$action" in
      add|update) git checkout "$target" -- "$path" ;;
      delete) git rm -q -- "$path" ;;
      merge)
        git show "$base:$path" >"$tmp/base"
        git show "$target:$path" >"$tmp/upstream"
        rc=0
        git merge-file -L downstream -L base -L upstream "$path" "$tmp/base" "$tmp/upstream" 2>/dev/null || rc=$?
        if [[ "$rc" -eq 0 ]]; then action=merged-clean
        elif [[ "$rc" -lt 128 ]]; then action=conflict
        else git checkout HEAD -- "$path"; action=ask-binary
        fi ;;
    esac
    printf '%s\t%s\n' "$action" "$path"
  done < <(changed_paths "$base" "$target")
}

[[ $# -ge 1 ]] || die "usage: $0 baseline <target> | plan <base> <target> | apply <base> <target>"
cmd="$1"; shift
case "$cmd" in
  baseline) [[ $# -eq 1 ]] || die "usage: $0 baseline <target>"; cmd_baseline "$1" ;;
  plan) [[ $# -eq 2 ]] || die "usage: $0 plan <base> <target>"; cmd_plan "$1" "$2" ;;
  apply) [[ $# -eq 2 ]] || die "usage: $0 apply <base> <target>"; cmd_apply "$1" "$2" ;;
  *) die "unknown command: $cmd" ;;
esac
