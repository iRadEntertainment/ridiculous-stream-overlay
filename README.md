# Ridiculous Stream

A Godot desktop streaming companion with Twitch chat and channel-point actions,
physics-based overlay effects, OBS controls, user management, and session summaries.
The current configuration includes behavior specific to the author's channel.

## Development requirements

- Godot **4.7.2 with .NET support**, matching `Ridiculous Stream.csproj`.
- A .NET SDK capable of building the project's `net8.0` target.
- The bundled addons and native libraries, including Rapier2D.
- A Twitch account and an application configuration for Twitch features.
- OBS with its WebSocket server enabled for optional OBS controls.

## Opening and running the project

1. Clone the repository and import `project.godot` in the Godot .NET editor.
2. Allow resource imports to finish and build the C# project with the editor's
   **Build** button.
3. Check **Project Settings > Plugins**. The shared configuration references two
   local editor tools, `editorscriptmanager` and `ridiculous_coding`, that are
   intentionally excluded from Git. If they are unavailable, disable their plugin
   entries in your local setup. The other enabled editor plugins are bundled.
4. Review the Twitch configuration before connecting. Twitcher provides a
   **Twitcher Setup** entry in the editor's **Project > Tools** menu. The application
   scene also contains shared OAuth settings under
   `rs_main.tscn > Modules > RSTwitcher > TwitchService`; check that the service and
   its children use your intended settings. Use the plugin's secret input rather
   than editing its serialized secret value. Keep credentials and tokens out of
   commits and distributed builds.
5. Use **F5** to start the application. Its `RS` autoload loads `rs_main.tscn`, while
   the configured main scene is `instances/empty.tscn`.
6. Use the connection panel to set the broadcaster ID and connect Twitch. Configure
   the OBS server address, separate port, and password in the application settings
   if you use OBS controls. Supported address examples include `127.0.0.1`, `::1`,
   and `ws://[::1]`.

The first-run welcome flow is currently disabled. A fresh checkout still needs
manual configuration; a complete setup wizard and reproducible release builds
are planned. OBS input/scene names and several commands are currently customized
in `lib/no-obs-ws/NoOBSWS.gd` and `classes/RSCustom.gd`.

## Settings and local data

`user://settings.ini` selects the application's data directory. It defaults to
Godot's user-data directory. That directory holds `settings.tres`, user records,
summaries, caches, and custom media folders. Back it up before experimenting with
settings or changing storage locations. Settings can contain credentials.

Local OAuth resource files and `export_presets.cfg` are currently ignored by Git.
Git ignore rules do not control which files Godot includes in an export.

## Platform status

Windows is the current development platform. The click-through implementation in
`classes/RSMousePass.cs` calls Windows APIs and returns without doing anything on
other operating systems. Some utilities use PowerShell, and some custom actions
reference Windows executable paths.

Windows, macOS, and Linux are the intended distribution targets. macOS and Linux
behavior has not been verified. Bundled native libraries for those platforms do
not by themselves establish support for transparency, click-through, or desktop
window placement. Linux X11 and Wayland will need separate verification.

## Code and dependencies

| Location | Purpose |
| --- | --- |
| `RSMain.gd`, `rs_main.tscn` | Application startup, global services, and UI |
| `classes/` | Application behavior, settings, and data models |
| `instances/` | Feature scenes and their scripts |
| `lib/no-obs-ws/` | OBS WebSocket integration with application-specific actions |
| `lib/games_info/` | Steam and itch.io information |
| `lib/polygon2d-fracture/` | Polygon fracture support |
| `addons/twitcher/` | Bundled Twitcher 2.2.2 and its dependencies |
| `addons/godot-rapier2d/` | Native Rapier2D physics extension |
| `local_res/`, `ui/`, `shaders/` | Media, UI assets, and visual effects |
| `test/`, `tools/`, `example/` | Manual experiments, developer tools, and examples |

The current `test/` scripts are not a comprehensive automated test suite.
Generated Twitch API files can be overwritten by regeneration; consult
`addons/twitcher/generated/README.md` before changing them.

## License

Project code is covered by the root [MIT license](LICENSE). Bundled dependencies
include their own license files. Review third-party media and font licenses
separately before redistributing assets.
