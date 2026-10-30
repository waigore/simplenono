#!/usr/bin/env bash
# Sync repository labels from .github/project-labels.yml.
# Creates missing labels; updates description and color when the name exists.
# Never deletes labels that are not in the config.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG="${LABELS_CONFIG:-$ROOT/.github/project-labels.yml}"

if [[ ! -f "$CONFIG" ]]; then
  echo "error: config not found: $CONFIG" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI is required" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "error: yq is required (https://github.com/mikefarah/yq)" >&2
  exit 1
fi

# Ensure gh talks to GitHub with the Actions token when present.
if [[ -n "${GITHUB_TOKEN:-}" && -z "${GH_TOKEN:-}" ]]; then
  export GH_TOKEN="$GITHUB_TOKEN"
fi

count="$(yq 'length' "$CONFIG")"
if [[ "$count" -eq 0 ]]; then
  echo "No labels defined in $CONFIG"
  exit 0
fi

echo "Syncing $count label(s) from $CONFIG"

existing_json="$(gh label list --limit 1000 --json name,color,description)"

created=0
updated=0
unchanged=0

for i in $(seq 0 $((count - 1))); do
  name="$(yq -r ".[$i].name" "$CONFIG")"
  color="$(yq -r ".[$i].color" "$CONFIG" | tr -d '#')"
  description="$(yq -r ".[$i].description // \"\"" "$CONFIG")"

  if [[ -z "$name" || "$name" == "null" ]]; then
    echo "error: label at index $i is missing name" >&2
    exit 1
  fi
  if [[ -z "$color" || "$color" == "null" ]]; then
    echo "error: label '$name' is missing color" >&2
    exit 1
  fi

  # mikefarah/yq v4: bind name via env (no jq-style --arg).
  match="$(echo "$existing_json" | n="$name" yq -r -p=json -o=tsv '.[] | select(.name == strenv(n)) | [.color, (.description // "")]')"

  if [[ -z "$match" ]]; then
    echo "  create: $name"
    gh label create "$name" --color "$color" --description "$description"
    created=$((created + 1))
    continue
  fi

  current_color="$(echo "$match" | cut -f1 | tr -d '#')"
  current_description="$(echo "$match" | cut -f2-)"

  # gh label list returns color without '#'; compare case-insensitively.
  current_color_lc="$(printf '%s' "$current_color" | tr '[:upper:]' '[:lower:]')"
  color_lc="$(printf '%s' "$color" | tr '[:upper:]' '[:lower:]')"
  if [[ "$current_color_lc" == "$color_lc" && "$current_description" == "$description" ]]; then
    echo "  unchanged: $name"
    unchanged=$((unchanged + 1))
    continue
  fi

  echo "  update: $name"
  gh label edit "$name" --color "$color" --description "$description"
  updated=$((updated + 1))
done

echo "Done. created=$created updated=$updated unchanged=$unchanged"
