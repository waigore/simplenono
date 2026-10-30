# Authoring rules: user-story index

Read this before editing `specs/ux/stories.md`. Do not copy these rules into the spec.

Also read [ux.md](ux.md), [ids.md](ids.md), [story-coverage.md](story-coverage.md), and [depth.md](../depth.md). A single story file follows [story.md](story.md).

User stories are concrete, testable interface behavior, written as Given/When/Then and traced to the UX element IDs they prove. They cover screens, controls, navigation, visibility, and exceptions. Player stories under `specs/design/stories.md` cover game logic.

## Rules for every story

- **Interface only**: assert screens, regions, controls, navigation, and exception UI. Cite a design ID for a game fact on screen. Leave the rule's outcome in the player story.
- **Traced**: every scenario names the UX element IDs it proves. A scenario asserts only behavior the UX spec states. Add missing interface behavior to the UX spec first. Add a missing game rule to the design first.
- **Narrative**: each story opens with "As \<actor\>, I \<operate the interface\> so that \<goal\>". The goal comes from that actor or journey.
- **Given**: the actor, the screen, the UI state, and the design facts already true, with concrete values, so two testers set up the same situation.
- **When**: exactly one trigger. A trigger is one control activation, one bound input, or one system UI event the UX spec defines. Journey stories may chain When/Then pairs in step order.
- **Then**: the resulting screen, visible regions, enabled or disabled controls, or exception, with concrete values. Add "And … is unchanged" where an unintended change is plausible.
- **Falsifiable**: name element IDs and visible strings. Do not use subjective words such as "smoothly", "quickly", or "feels". An implementation that breaks the element would fail the scenario.
- **Shared language**: use glossary terms and the defined screen, control, and action names.

## Coverage

Each UX spec with element IDs is core or not, and has a coverage level of Full, Baseline, or None — reason. Spec depth sets the minimum for each, per [depth.md](../depth.md). Choose per spec.

- **Full**: every element ID and named item is proven as [story-coverage.md](story-coverage.md) requires.
- **Baseline**: every element ID and named item is proven by at least one scenario that shows its stated outcome.
- **None**: no story file.

The coverage table agrees with the scenarios' **Proves** lines. Sections without IDs are judged during review and acceptance.

## Files

One story file per UX spec that has element IDs and coverage other than None, at the same relative path under `specs/ux/stories/`. `screens/main-menu.md` → `stories/screens/main-menu.md`. `navigation.md` → `stories/navigation.md`. Copy `stories/_template.md`.

A story that spans several specs lives in the file of the spec whose element it mainly proves, and cites the others with qualified IDs.

`stories.md` is the index: one row per UX spec that has element IDs, grouped as in the UX index. Columns: the UX spec link, core (yes or no), coverage (Full, Baseline, or None — reason), and the story file link (or "—" when None). If the index pushes the file past 500 words, move it to `stories/index.md` and leave a link.

Every indexed story file exists, and every story file has a UX spec.
