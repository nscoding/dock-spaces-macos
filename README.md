# Dock Spaces for macOS

Dock Spaces lets you create and switch between multiple custom Mac Dock configurations — one click to go from your Work setup to Gaming or Study mode, each with its own set of apps.

![Dock Spaces Screenshot](screenshot.png)

## What it does

macOS gives you one Dock. Dock Spaces gives you as many as you want.

You can create named Dock profiles (e.g., **Default**, **Work**, **Gaming**, **Study**) and instantly switch between them from the app window or the menu bar. Each profile saves a completely independent set of apps, so switching contexts means your Dock reflects exactly what you need for that moment — no manual rearranging.

### Features

- **Multiple Dock profiles** — Create unlimited named profiles, each storing a full Dock layout
- **One-click switching** — Switch the active Dock from the main window or directly from the menu bar
- **Save current Dock** — Snapshot your current Dock arrangement into any profile at any time
- **Reveal in Finder** — Browse the underlying plist file for any profile
- **Menu bar integration** — Switch profiles without opening the main window

## How it works

> **Dock Spaces is not sandboxed.**

To switch your Dock, the app reads and writes `~/Library/Preferences/com.apple.dock.plist` — a system file that lives outside any app container. Sandboxed Mac App Store apps cannot access this file, so Dock Spaces runs without the App Sandbox entitlement.

Each saved profile is stored as its own plist file under:

```
~/Library/Application Support/Dock Spaces/Docks/<profile-name-uuid>.plist
```

When you switch profiles, Dock Spaces copies the selected profile plist over the system Dock plist and restarts the Dock process to apply the changes immediately.

## Requirements

- macOS 26 or later
- Must be run outside the App Store sandbox (direct download / build from source)

## Building from source

Open `Dock Spaces.xcodeproj` in Xcode, select the **Dock Spaces** scheme, and run. No additional dependencies are required.

## License

See [LICENSE](LICENSE).
