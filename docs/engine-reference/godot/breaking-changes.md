# Godot 4.6 Breaking And Behavior Changes

> Last verified: 2026-05-16
> Scope: Godot 4.5 to 4.6, focused on changes likely to affect this project.

## Compatibility Summary

Godot's official 4.5 to 4.6 upgrade guide lists compatibility and behavior changes. This project is already marked as Godot 4.6 in `project.godot`, so this file is primarily a guardrail for future edits and code review.

## Scene And Resource Files

- TSCN scene serialization changed in Godot 4.6.
- `load_steps` is no longer written to scene files.
- Unique node IDs are now saved to scene files to make node move/rename tracking more robust.
- Saving older scenes in Godot 4.6 can create large but expected version-control diffs.
- When doing scene-wide upgrades, prefer a dedicated commit for editor-generated scene/resource format changes.

## Rendering

- New projects on Windows default to D3D12 as the rendering driver.
- This project already sets `rendering/rendering_device/driver.windows="d3d12"`.
- Glow defaults changed and may make effects brighter or visually different, especially if Environment glow is used.
- Mobile renderer glow behavior changed for performance reasons.
- Volumetric fog blending changed to be more physically accurate; this is mostly relevant to 3D scenes.

## Physics

- New 3D projects default to Jolt Physics in Godot 4.6.
- Existing project physics settings are preserved when upgrading.
- This project currently pins `physics/3d/physics_engine="Jolt Physics"`.

## Navigation

- `AStar2D.get_point_path`, `AStar3D.get_point_path`, `AStarGrid2D.get_id_path`, and `AStarGrid2D.get_point_path` now return an empty path when `from_id` is a disabled or solid point.
- Any future pathfinding logic should test disabled/solid start nodes explicitly.

## Android Export

- Android export template source layout changed to match the default Android Studio project structure.
- This matters only if the project adds Android export support.

## Project-Specific Watch List

- `addons/custom_resource_translation/` touches translation import/parsing behavior. Check Godot 4.6 importer behavior before assuming older CSV translation defaults.
- `effects/` and shader/UI effects should be visually checked if Environment glow or renderer settings change.
- Multiplayer code should avoid relying on undocumented timing/order behavior; verify against official 4.6 networking docs before architecture changes.

## Sources

- https://docs.godotengine.org/en/4.6/tutorials/migrating/upgrading_to_godot_4.6.html
- https://godotengine.org/releases/4.6/
