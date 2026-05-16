# Godot 4.6 Deprecated And Changed APIs

> Last verified: 2026-05-16
> Scope: Godot 4.5 to 4.6 public upgrade notes.

## High-Value Checks

The official 4.6 upgrade guide lists API compatibility changes and behavior changes. Before using older examples from tutorials, verify the API against the Godot 4.6 class reference.

## FileDialog Moved Members

Several `EditorFileDialog` members moved to base class `FileDialog` in 4.6, including options, path/current file properties, filters, display/file mode, and file/dir selected signals.

Project impact:

- This project has custom editor plugin code under `addons/custom_resource_translation/`.
- If that plugin adds file-picking UI later, prefer the 4.6 `FileDialog` API surface.

## ResourceImporterCSVTranslation

The `ResourceImporterCSVTranslation.compress` default/value representation changed in Godot 4.6.

Project impact:

- This project includes translation files and custom translation tooling.
- Any code that directly inspects or sets CSV translation importer options should verify `ResourceImporterCSVTranslation` behavior in the 4.6 docs.

## Navigation Methods

Changed behavior:

- `AStar2D.get_point_path`
- `AStar3D.get_point_path`
- `AStarGrid2D.get_id_path`
- `AStarGrid2D.get_point_path`

These return an empty path when the starting point is disabled or solid.

Project impact:

- No direct pathfinding usage was recorded during setup, but enemy AI work should check this if navigation is added.

## GDScript And Tooling Notes

- GDScript LSP docstring rendering improved for BBCode to Markdown conversion.
- String placeholder highlighting was added in the editor.
- Debugger Step Out and ObjectDB snapshots are available for debugging workflows.

These are tooling improvements rather than breaking runtime API changes.

## Sources

- https://docs.godotengine.org/en/4.6/tutorials/migrating/upgrading_to_godot_4.6.html
- https://godotengine.org/releases/4.6/
