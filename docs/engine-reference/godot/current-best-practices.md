# Godot 4.6 Current Best Practices

> Last verified: 2026-05-16

## Project Baseline

- Treat this project as Godot 4.6 + GDScript.
- Use official 4.6 documentation for API questions.
- Prefer small, reviewable scene/resource changes because Godot 4.6 can produce expected scene serialization diffs.

## GDScript

- Use static typing for exported properties, member variables, function arguments, and return values when practical.
- Prefer signals or event autoloads for cross-scene communication instead of deep node-path reach-through.
- Keep `_ready`, `_process`, and `_physics_process` short; move behavior into named methods.
- Avoid per-frame allocations in combat, enemy, bullet, and UI update loops.

## Scene And Node Structure

- Keep reusable gameplay pieces in `components/`.
- Keep entity-specific behavior under `entities/`.
- Keep shared singleton-style services under `autoload/`.
- Preserve scene ownership and UIDs when editing `.tscn` files.
- Use Godot editor operations for broad scene/resource migrations.

## Multiplayer

- Keep server-authoritative gameplay decisions in networking-sensitive systems.
- Avoid broadcasting high-frequency per-frame RPCs unless an ADR explicitly budgets them.
- Prefer explicit synchronization boundaries for input, readiness, player state, health, bullets, and round state.
- Add smoke tests or manual evidence for multiplayer flows that cannot be unit-tested headlessly.

## Rendering And Effects

- The project uses GL Compatibility rendering. Check shader and effect behavior in that renderer before adding Forward+/Mobile-only assumptions.
- D3D12 is configured as the Windows rendering driver, but GL Compatibility uses OpenGL as its renderer path.
- When changing glow, Environment, or shader effects, verify visually because Godot 4.6 changed several rendering defaults.

## Physics

- Jolt Physics is configured for 3D physics. Most gameplay appears 2D, so verify whether changes touch 2D physics, 3D physics, or both.
- Keep hitbox/hurtbox collision layers documented when adding combat features.

## Localization And Resource Translation

- Keep translation extraction and custom parser behavior deterministic.
- Add tests for CSV/resource parsing when `tests/` is scaffolded.
- Check Godot 4.6 importer defaults before changing translation import options.

## Debugging Godot 4.6

- Use ObjectDB snapshots when tracking leaked nodes/resources.
- Use debugger Step Out for complex signal and state-machine flows.
- Use tracing profiler support for deeper script performance investigation when built-in profiling is insufficient.

## Sources

- https://docs.godotengine.org/en/4.6/
- https://godotengine.org/releases/4.6/
- https://docs.godotengine.org/en/4.6/tutorials/rendering/renderers.html
