# Godot Version Reference

> Last verified: 2026-05-16

| Field | Value |
| --- | --- |
| **Engine Version** | Godot 4.6 |
| **Project Pinned** | 2026-05-16 |
| **LLM Knowledge Cutoff** | May 2025 |
| **Risk Level** | HIGH - Godot 4.6 is after the cutoff and must be checked against official docs |
| **Primary Language** | GDScript |
| **Official Docs** | https://docs.godotengine.org/en/4.6/ |
| **Release Page** | https://godotengine.org/releases/4.6/ |
| **Upgrade Guide** | https://docs.godotengine.org/en/4.6/tutorials/migrating/upgrading_to_godot_4.6.html |
| **Release Policy** | https://docs.godotengine.org/en/4.6/about/release_policy.html |

## Project Settings Observed

- `config/features` includes `4.6` and `GL Compatibility`.
- `renderer/rendering_method` is `gl_compatibility`.
- `rendering/rendering_device/driver.windows` is `d3d12`.
- `physics/3d/physics_engine` is `Jolt Physics`.
- The project has 60 `.gd` files and 5 `.gdshader` files, with no C# or C++ source detected during setup.

## Knowledge Gap Notes

Godot 4.6 is beyond the model's May 2025 baseline. Any ADR, story, code review, or migration touching engine behavior should prefer the official 4.6 docs over memory.

Key 4.6 areas to verify before making assumptions:

- Jolt Physics is the default physics engine for new 3D projects, but existing project settings are preserved.
- The default Windows rendering driver for new projects is D3D12.
- Scene files saved in 4.6 may receive expected version-control diffs because of TSCN format changes.
- Rendering defaults changed for glow and related Environment settings.
- Navigation path behavior changed for disabled/solid points.
- GDScript language server and debugger behavior received editor/tooling improvements.

## Recommended Commands

```powershell
godot --version
godot --headless --path . --quit
```

If GdUnit4 is installed later:

```powershell
godot --headless --script tests/gdunit4_runner.gd
```

## Source Notes

- Official 4.6 documentation branch: https://docs.godotengine.org/en/4.6/
- Official 4.6 release page: https://godotengine.org/releases/4.6/
- Official 4.5 to 4.6 upgrade guide: https://docs.godotengine.org/en/4.6/tutorials/migrating/upgrading_to_godot_4.6.html
- Official release policy: https://docs.godotengine.org/en/4.6/about/release_policy.html
