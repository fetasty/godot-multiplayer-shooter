# 01-multi-player

## Project Overview

Godot 4.6 multiplayer shooter practice project with local and online multiplayer, reusable gameplay components, state-machine driven enemies, UI menus, localization resources, and custom editor tooling for resource translation.

## Technology Stack

- **Engine**: Godot 4.6
- **Language**: GDScript
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Repository Instructions

- Prefer GDScript for gameplay, UI, tools, and plugin code unless an ADR explicitly chooses another language.
- Keep Godot scene/resource files (`.tscn`, `.tres`, `.import`, `.uid`) in editor-managed format.
- Do not hand-edit `project.godot` unless the change is small, deliberate, and easier to review than an editor-generated diff.
- Preserve existing scene UIDs and resource paths when refactoring.

## Current Project Shape

- Gameplay code: `entities/`, `components/`, `scripts/`, `autoload/`
- UI code and scenes: `ui/`
- Effects: `effects/`, `resources/shader/`
- Data/config: `config/`, `resources/`
- Localization: `translate/`, `addons/custom_resource_translation/`
- Plugins: `addons/`
- Keep project-specific working context current in this `AGENTS.md` as the project evolves, so new sessions can start with minimal re-sync.

## Active Work: CSV Resource System Rework

- Progress document: `docs/csv_resource_rework_progress.md`
- Current gate: Task 3 is waiting for user validation; after Task 3 is accepted, continue with Task 4.
- Execution rule: work one task at a time, update the progress document with requirements, scope, test method, test result, status, and validation notes, then stop for user approval.
- Planned tasks:
  - Task 0: establish the progress document.
  - Task 1: build runtime CSV-to-Resource cache.
  - Task 2: drive enemy spawning from `config/enemy_config.csv`.
  - Task 3: replace old upgrade rewards with passive items from `config/passive_item_config.csv` (implemented, pending validation).
  - Task 4: implement the six passive item effects.
  - Task 5: add shared pickup item drops from enemy deaths using `config/pickup_item_config.csv`.
  - Task 6: cleanup and regression.

### CSV Resource Rules

- CSV rows use the first row as headers.
- Columns named `comment_xxx` are CSV-only comments and must not be stored in runtime Resource objects.
- Columns ending in `_key`, such as `name_key` and `description_key`, store localization keys, not display text.
- UI and gameplay presentation must keep these `_key` values in Resources and call `tr(resource.name_key)` / `tr(resource.description_key)` when localized text is needed.
- Runtime resource generation is preferred for this work; do not generate `.tres` files unless a later task explicitly changes that decision.

### Current CSV Rework Notes

- Task 2 has been accepted by the user.
- Task 3 now uses `CSVResourceCache.get_all_passives()` as the reward option pool and records selections per peer as passive item counts in `UpgradeComponent`.
- `components/upgrade_component.tscn` no longer references `resources/upgrade_resource/*.tres`; keep the existing `UpgradeComponent` / `UpgradeOptionsUI` names as compatibility shells until the cleanup task.
- Task 4 should consume the new passive ids directly: `basic_damage_up`, `health_limit_up`, `bullet_split`, `attack_speed_up`, `move_speed_up`, and `defence_up`.
