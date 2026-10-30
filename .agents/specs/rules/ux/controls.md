# Authoring rules: controls

Read this before editing `specs/ux/controls.md` or a bindings file split from it. Do not copy these rules into the spec.

Also read [ux.md](ux.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

How input on each supported platform activates a UI action. Platforms and primary inputs come from `specs/definition/definition.md`. Screens name these actions on their controls.

A binding activates a control. The screen spec states what that control does, including any design verb it asks the game to perform. UI actions are defined once here. Screens refer to them by ID.

## UI actions

The skeleton defines `IN.confirm`, `IN.cancel`, `IN.back`, `IN.pause`, `IN.point`, and `IN.activate`. Delete an action this game does not use. Add a row for an action it needs. Each primary platform has at least one binding for every action a screen uses.

Columns: ID, action name, and meaning.

## Bindings

One row per input that activates an action, for each platform the definition lists. IDs `B1`, `B2`, ….

Columns: platform (from the definition), the input (for example keyboard Enter, pointer click, or gamepad South), and the action: a UI action from this file, or a camera action (`CC.<name>`) from `specs/view/camera-controls.md`.

On that platform, the input activates the named action and no other action. Each primary platform has at least one binding for every camera action the view defines. What a camera action does stays in the view.

## Focus

**F1**: on each screen, keyboard and gamepad focus follow that screen's controls table from top to bottom. Pointer activation hits the control under the pointer. An unavailable control shows that it is unavailable and does not activate.

`IN.F1` agrees with the order of each screen's controls table.

## Splitting

If the file passes 500 words, move the bindings table to `controls/bindings.md`. Leave a summary and a link, and update `ux.md`.
