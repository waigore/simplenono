# Authoring rules: scenario

Read this before editing `specs/design/scenarios/_template.md` or `specs/design/scenarios/<name>.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `scenarios/<kebab-name>.md`, one file per scenario. Do not fill the template in place.

A scenario is a defined play setup plus worked walkthroughs that show the design in action. Scenarios prove that specs combine. If a walkthrough cannot be resolved step by step from the other specs, those specs are incomplete.

How many scenarios are needed follows spec depth, per [depth.md](../depth.md).

## Header

- **Kind**: mission, puzzle, match setup, encounter, tutorial, or other.
- **Stage**: a link, or "N/A".
- **Serves**: vision qualities and definition scope items.

## Setup

Starting state as values of game-state fields. Participants, as links to characters and entities. The configuration and difficulty in effect. Objectives. Constraints, such as time, resources, or forbidden actions. End conditions, as links into `end-conditions.md`.

## Walkthroughs

At least one. Include a success path and a failure path when both are possible. Step IDs are `W<walkthrough>.<step>`, such as `W1.1`.

Columns: what the player does (a verb or a game event), how the game responds (link the rule and cite its qualified ID), and the resulting state. Then the outcome (the end condition reached and its consequences) and the player experience at key moments.

Each step's outcome follows its trigger. Scenario-walkthrough stories may chain When/Then pairs in this step order.

## Edge cases covered

Unusual situations this scenario deliberately exercises, or "None".

## Specs exercised

Links to every feature, character, entity, flow, and condition the scenario depends on.
