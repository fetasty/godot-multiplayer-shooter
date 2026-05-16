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
