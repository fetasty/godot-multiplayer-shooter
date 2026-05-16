# Technical Preferences

> Last updated: 2026-05-16

## Engine & Language

- **Engine**: Godot 4.6
- **Language**: GDScript
- **Rendering**: 2D-focused project using GL Compatibility renderer (`renderer/rendering_method="gl_compatibility"`) with Windows rendering driver set to D3D12 (`rendering/rendering_device/driver.windows="d3d12"`)
- **Physics**: Godot physics APIs; project setting currently pins 3D physics to Jolt Physics (`physics/3d/physics_engine="Jolt Physics"`)
- **Build System**: Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource translation/config pipeline

## Input & Platform

- **Target Platforms**: PC / Desktop
- **Input Methods**: Keyboard/Mouse
- **Primary Input**: Keyboard/Mouse
- **Gamepad Support**: None configured
- **Touch Support**: None configured
- **Platform Notes**: Current input map defines WASD/arrow movement, mouse attack, pause, and ready actions. Add gamepad or touch bindings only when a story or ADR scopes that platform work.

## Naming Conventions

- **Classes**: PascalCase when `class_name` is used, e.g. `PlayerController`
- **Variables/functions**: snake_case, e.g. `move_speed`, `take_damage()`
- **Signals**: snake_case past tense or event-style names, e.g. `health_changed`
- **Files**: snake_case matching the main class or scene role, e.g. `health_component.gd`
- **Scenes**: snake_case for existing project consistency, e.g. `player_health_ui.tscn`
- **Constants**: UPPER_SNAKE_CASE
- **Autoloads**: PascalCase singleton names matching `project.godot`, e.g. `GameState`, `GameEvents`
- **Resources**: snake_case descriptive names, e.g. `move_speed.tres`

## Performance Budgets

- **Frame Rate Target**: 60 FPS
- **Frame Budget**: 16.6 ms
- **Memory Budget**: [TO BE CONFIGURED]
- **Draw Call Budget**: [TO BE CONFIGURED]
- **Network Budget**: [TO BE CONFIGURED]
- **Notes**: Multiplayer gameplay should prefer server-authoritative state and low-frequency replicated state over per-frame RPC spam.

## Testing

- **Recommended Framework**: GdUnit4
- **Unit Tests**: `tests/unit/`
- **Integration Tests**: `tests/integration/`
- **Smoke Tests**: `tests/smoke/`
- **Manual Evidence**: `tests/evidence/`
- **Headless Command**: `godot --headless --script tests/gdunit4_runner.gd`

## Forbidden Patterns

- [TO BE CONFIGURED]

## Allowed Libraries

- Godot built-in Multiplayer API
- Existing project plugins under `addons/`
- Add external libraries here only when a story actively integrates them.

## Engine Specialists

- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist (all `.gd` files)
- **Shader Specialist**: godot-shader-specialist (`.gdshader` files, VisualShader resources)
- **UI Specialist**: godot-specialist (Control nodes, CanvasLayer, theme/resource wiring)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for architecture decisions, scene/resource structure, multiplayer architecture, and cross-cutting Godot lifecycle concerns. Invoke GDScript specialist for code quality, static typing, signal architecture, and idiomatic GDScript.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
| --- | --- |
| Game code (`.gd`) | godot-gdscript-specialist |
| Shader / material files (`.gdshader`, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer, themes) | godot-specialist |
| Scene / resource files (`.tscn`, `.tres`) | godot-specialist |
| Native extension / plugin files (`.gdextension`, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |

## Version Awareness

- Read `docs/engine-reference/godot/VERSION.md` before making engine-specific recommendations.
- Check `docs/engine-reference/godot/deprecated-apis.md` before suggesting changed APIs.
- Check `docs/engine-reference/godot/breaking-changes.md` before upgrading, saving scenes in a new format, or changing rendering/physics defaults.
- Verify uncertain Godot 4.6 APIs against official Godot 4.6 documentation.
