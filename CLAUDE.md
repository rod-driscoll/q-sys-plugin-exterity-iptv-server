# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

Building requires the external `plugincompile/` toolchain (not in this repo). From VS Code, run the task **"Build Plugin"** (`.vscode/tasks.json`), which executes four steps:

1. `compile_plugin.sh` — increments version in `info.lua`
2. `PLUGCC.exe` — compiles `plugin.lua` and its `#include`d files into a `.qplug` binary
3. `copy_plugin.cmd` — copies the compiled `.qplug` into the Q-SYS Designer plugin folder

There are no unit tests or linting tools; validation is done by loading the plugin in Q-SYS Designer.

## Architecture

`plugin.lua` is the entry point and acts purely as a manifest — it `#include`s the six module files in order. The Q-SYS runtime calls specific global functions from these files:

| File | Q-SYS function(s) it defines |
|------|-------------------------------|
| `info.lua` | `GetPrettyName`, `GetVersion`, `GetColor` |
| `pages.lua` | `GetPages` |
| `properties.lua` | `GetProperties` |
| `rectify_properties.lua` | `RectifyProperties` |
| `controls.lua` | `GetControls` |
| `layout.lua` | `GetControlLayout` |
| `runtime.lua` | all event handlers and timer callbacks |

`runtime.lua` (~1600 lines) is the core. Everything else is static configuration.

## Key Runtime Concepts

**Indexed device slots** — The "Display Count" property (1–255) determines how many per-device control arrays exist (e.g., `Controls["PowerOn"][i]`). Slot `i` is bound to whatever IPTV decoder was selected via `Controls["DeviceSelect"][i]`.

**Two-tier HTTP model** — `QueryDevices()` fetches the device list from `GET /api/public/control/devices`, then queues individual `GET /api/public/control/devices/{mac}` polls via `QueryDevicesTimer` at 100 ms intervals to avoid flooding the server. Commands use `PostRequest()` to `POST /api/public/control/devices/{mac}/commands/{cmd}`.

**Power-on channel restore** — Vitec decoders forget their channel on power-up. The plugin caches `PowerOnChannel` per device at SetChannel time and re-sends it once the device transitions from idle → powered.

**Display module integration** — Each slot can optionally bind to an external Q-SYS component (e.g., a Samsung MDCP plugin) via `Component.New(Controls["DisplayIPAddress"][i].String)`. Power commands route to the display module when it is present; the decoder otherwise.

**Image/logo pipeline** — Channel logos are resolved by fuzzy name match against `channel-logos.json` (stored in the Q-SYS core media folder). Logos are HTTP-downloaded, Base64-encoded, and stored in the LED indicator's `Legend` field as JSON. A `LogoTimer` queues a second slightly-modified write to work around a QSD image-caching bug where identical payloads don't re-render.

**Debug toggles** — Five runtime toggle buttons control verbosity: `DebugFunction`, `DebugTx`, `DebugRx`, `DebugDisplays`, `DebugSnapshot`. `DebugSnapshot` dumps the full in-memory device cache as JSON to the Q-SYS log.

## API Reference

Base URL: `http[s]://{IPAddress}:{Port}/api/public/control`

Authentication is Basic Auth but is not enforced by the Exterity server (credentials are sent but ignored).

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/devices` | List all decoders |
| GET | `/devices/{mac}` | Device status/details |
| GET | `/channels` | Channel list |
| GET | `/playlists` | Playlist list |
| GET | `/api/schedule` | Schedules |
| POST | `/devices/{mac}/commands/channel` | Set channel (`{"uri":"..."}`) |
| POST | `/devices/{mac}/commands/poweron` | Power on |
| POST | `/devices/{mac}/commands/poweroff` | Power off |
| POST | `/devices/{mac}/playlists/{id}` | Activate playlist |

Interactive API docs are served at `http://{server-ip}/docs`.

## Known Quirks

- **Q-SYS emulation mode** — the Exterity server rejects requests from the QSD emulator with 403 Forbidden; test only on hardware.
- **Playlist channel detection** — no API exists to determine which channel is active inside a playlist; the plugin cannot display this.
- **Vitec vs Exterity platforms** — some decoders behave differently (no channel memory, no idle detection). Platform-specific branches exist in `runtime.lua`.
- **Image caching bug** — QSD does not re-render an LED indicator if the payload is byte-for-byte identical to the previous write. `QueuLogoUpdate()` works around this by queuing a second send with a minor modification.

## Dependencies

`dependencies/helpers/` is a shared Lua utility library (`init.lua`). Key functions used throughout `runtime.lua`:

- `UpdateItems(data)` — converts a key-value table into `"key: value"` strings for ListBox display
- `GetArrayItemWithKey(table, pair)` — finds the first array entry matching a key-value pair
- `GetChoicesItem(array, key)` — extracts a value from a ComboBox Choices array
