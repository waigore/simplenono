#!/usr/bin/env python3
"""Sync GitHub Project single-select fields from issue status:*/type:* labels.

Adds the issue to the project when missing, then sets Workflow status / Issue type
from the issue's current labels (labels → fields only). Clears a field when no
matching label is present.

Env:
  GH_TOKEN or GITHUB_TOKEN — PAT with project (+ repo) scope
  PROJECT_OWNER — user or org login (default: waigore)
  PROJECT_NUMBER — project number (default: 3)
  ISSUE_NODE_ID — GraphQL node id of the issue (preferred)
  ISSUE_NUMBER + REPO — fallback when node id is not provided (owner/name)
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from typing import Any

PROJECT_OWNER = os.environ.get("PROJECT_OWNER", "waigore")
PROJECT_NUMBER = int(os.environ.get("PROJECT_NUMBER", "3"))

STATUS_FIELD_NAME = "Workflow status"
TYPE_FIELD_NAME = "Issue type"

STATUS_PREFIX = "status:"
TYPE_PREFIX = "type:"

STATUS_OPTIONS = {
    "pending-review",
    "pending-refinement",
    "pending-clarification",
    "pending-implementation",
    "pending-verification",
    "pending-acceptance",
    "accepted",
    "pending-redefinition",
    "pending-analysis",
    "pending-resolution",
    "resolved",
}
TYPE_OPTIONS = {"epic", "task", "defect", "feedback"}


def _token() -> str:
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN") or ""
    if not token:
        print("error: GH_TOKEN or GITHUB_TOKEN is required", file=sys.stderr)
        sys.exit(1)
    return token


def gql(query: str, variables: dict[str, Any] | None = None) -> dict[str, Any]:
    payload: dict[str, Any] = {"query": query}
    if variables is not None:
        payload["variables"] = variables
    env = os.environ.copy()
    env["GH_TOKEN"] = _token()
    result = subprocess.run(
        ["gh", "api", "graphql", "--input", "-"],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    if result.returncode != 0:
        print(result.stderr or result.stdout, file=sys.stderr)
        sys.exit(result.returncode)
    data = json.loads(result.stdout)
    if data.get("errors"):
        print(json.dumps(data["errors"], indent=2), file=sys.stderr)
        sys.exit(1)
    return data["data"]


def resolve_issue() -> tuple[str, int, list[str]]:
    """Return (issue_node_id, number, label_names)."""
    node_id = os.environ.get("ISSUE_NODE_ID", "").strip()
    if node_id:
        data = gql(
            """
            query($id: ID!) {
              node(id: $id) {
                ... on Issue {
                  id
                  number
                  labels(first: 50) { nodes { name } }
                }
              }
            }
            """,
            {"id": node_id},
        )
        issue = data["node"]
        if not issue or "number" not in issue:
            print(f"error: node {node_id} is not an Issue", file=sys.stderr)
            sys.exit(1)
        labels = [n["name"] for n in issue["labels"]["nodes"]]
        return issue["id"], issue["number"], labels

    repo = os.environ.get("REPO", "").strip()
    number_raw = os.environ.get("ISSUE_NUMBER", "").strip()
    if not repo or not number_raw:
        print(
            "error: set ISSUE_NODE_ID, or REPO and ISSUE_NUMBER",
            file=sys.stderr,
        )
        sys.exit(1)
    owner, name = repo.split("/", 1)
    data = gql(
        """
        query($owner: String!, $name: String!, $number: Int!) {
          repository(owner: $owner, name: $name) {
            issue(number: $number) {
              id
              number
              labels(first: 50) { nodes { name } }
            }
          }
        }
        """,
        {"owner": owner, "name": name, "number": int(number_raw)},
    )
    issue = data["repository"]["issue"]
    if not issue:
        print(f"error: issue #{number_raw} not found in {repo}", file=sys.stderr)
        sys.exit(1)
    labels = [n["name"] for n in issue["labels"]["nodes"]]
    return issue["id"], issue["number"], labels


def load_project() -> tuple[str, dict[str, Any], dict[str, Any]]:
    """Return (project_id, status_field, type_field) with option name→id maps."""
    data = gql(
        """
        query($login: String!, $number: Int!) {
          user(login: $login) {
            projectV2(number: $number) {
              id
              fields(first: 50) {
                nodes {
                  ... on ProjectV2SingleSelectField {
                    id
                    name
                    options { id name }
                  }
                }
              }
            }
          }
        }
        """,
        {"login": PROJECT_OWNER, "number": PROJECT_NUMBER},
    )
    project = data["user"]["projectV2"]
    if not project:
        print(
            f"error: project #{PROJECT_NUMBER} not found for {PROJECT_OWNER}",
            file=sys.stderr,
        )
        sys.exit(1)

    by_name = {
        n["name"]: n
        for n in project["fields"]["nodes"]
        if n and n.get("name")
    }
    status = by_name.get(STATUS_FIELD_NAME)
    typ = by_name.get(TYPE_FIELD_NAME)
    if not status or not typ:
        print(
            f"error: project missing fields "
            f"{STATUS_FIELD_NAME!r} and/or {TYPE_FIELD_NAME!r}",
            file=sys.stderr,
        )
        sys.exit(1)

    def option_map(field: dict[str, Any]) -> dict[str, str]:
        return {o["name"]: o["id"] for o in field["options"]}

    status["option_ids"] = option_map(status)
    typ["option_ids"] = option_map(typ)
    return project["id"], status, typ


def ensure_item(project_id: str, issue_id: str) -> str:
    """Return project item id, adding the issue when needed."""
    data = gql(
        """
        query($id: ID!) {
          node(id: $id) {
            ... on Issue {
              projectItems(first: 20) {
                nodes {
                  id
                  project { id }
                }
              }
            }
          }
        }
        """,
        {"id": issue_id},
    )
    for item in data["node"]["projectItems"]["nodes"]:
        if item["project"]["id"] == project_id:
            return item["id"]

    added = gql(
        """
        mutation($projectId: ID!, $contentId: ID!) {
          addProjectV2ItemById(
            input: { projectId: $projectId, contentId: $contentId }
          ) {
            item { id }
          }
        }
        """,
        {"projectId": project_id, "contentId": issue_id},
    )
    return added["addProjectV2ItemById"]["item"]["id"]


def set_single_select(
    project_id: str, item_id: str, field_id: str, option_id: str
) -> None:
    gql(
        """
        mutation(
          $projectId: ID!
          $itemId: ID!
          $fieldId: ID!
          $optionId: String!
        ) {
          updateProjectV2ItemFieldValue(
            input: {
              projectId: $projectId
              itemId: $itemId
              fieldId: $fieldId
              value: { singleSelectOptionId: $optionId }
            }
          ) {
            projectV2Item { id }
          }
        }
        """,
        {
            "projectId": project_id,
            "itemId": item_id,
            "fieldId": field_id,
            "optionId": option_id,
        },
    )


def clear_field(project_id: str, item_id: str, field_id: str) -> None:
    gql(
        """
        mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!) {
          clearProjectV2ItemFieldValue(
            input: {
              projectId: $projectId
              itemId: $itemId
              fieldId: $fieldId
            }
          ) {
            projectV2Item { id }
          }
        }
        """,
        {"projectId": project_id, "itemId": item_id, "fieldId": field_id},
    )


def pick_value(labels: list[str], prefix: str, allowed: set[str]) -> str | None:
    matches = []
    for name in labels:
        if name.startswith(prefix):
            value = name[len(prefix) :]
            if value in allowed:
                matches.append(value)
    if not matches:
        return None
    # Prefer the first match; issues should have at most one of each.
    return matches[0]


def sync_field(
    project_id: str,
    item_id: str,
    field: dict[str, Any],
    value: str | None,
) -> str:
    if value is None:
        clear_field(project_id, item_id, field["id"])
        return "cleared"
    option_id = field["option_ids"].get(value)
    if not option_id:
        print(
            f"warning: no option {value!r} on field {field['name']!r}; skipping",
            file=sys.stderr,
        )
        return "skipped"
    set_single_select(project_id, item_id, field["id"], option_id)
    return value


def main() -> None:
    issue_id, number, labels = resolve_issue()
    project_id, status_field, type_field = load_project()
    item_id = ensure_item(project_id, issue_id)

    status_value = pick_value(labels, STATUS_PREFIX, STATUS_OPTIONS)
    type_value = pick_value(labels, TYPE_PREFIX, TYPE_OPTIONS)

    status_result = sync_field(project_id, item_id, status_field, status_value)
    type_result = sync_field(project_id, item_id, type_field, type_value)

    print(
        f"issue #{number}: Workflow status={status_result}, "
        f"Issue type={type_result}"
    )


if __name__ == "__main__":
    main()
