# Vetting toast visibility and positioning

## Reproduction and cause

The Steam/itch.io fixes did not modify vetting notifications. An offline replay of
`RSVetting.custom_rewards_vetting()` reproduced the reported issue using the
notification panel and its overrides from `rs_main.tscn`.

At a logical viewport size of 1200 by 675, the panel and its ScrollContainer were
337 pixels wide but **zero pixels high**. The main scene's layout overrides reset
the inherited anchors. The toast still had a nonzero rectangle and
`is_visible_in_tree()` returned true, but the ScrollContainer clipped it entirely.
`RSMouseTracker` checked that rectangle without checking ancestor clipping, so the
invisible toast continued to prevent mouse passthrough.

## Changes

- Keep the notification panel anchored to the right edge and the full viewport
  height; remove the conflicting main-scene overrides.
- Make the VBox fill the available height and align its children at the bottom.
- Scroll to the newest toast after content layout or viewport size changes.
  Manual scrolling to older requests still works.
- Track the visible scrollbar as interactive UI.
- Exclude hidden, queued-for-deletion, fully transparent through `modulate`, and
  clipped controls from mouse blocking. Preserve the split-container handle case.
- Allow the panel to use an injected vetting instance for offline testing.

## Validation

`test/test_vetting_toasts.gd` passes 29 checks using the actual production scene
properties and the real vetting signal. It covers empty and single-toast states,
bottom-right placement, ten pending requests, overflow scrolling, manual scrolling,
window resizing, hidden/transparent toasts, zero-height and partial clipping,
accept/dismiss behavior, and removal of blocking areas.

Run it from PowerShell with an isolated data directory:

```powershell
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = 'C:/Git/ridiculous-stream/.godot/toast-test-data'
    & 'C:/Godot/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe' --headless --path C:/Git/ridiculous-stream --script res://test/test_vetting_toasts.gd
} finally {
    $env:APPDATA = $previousAppData
}
```

These checks verify layout, clipping, and the decision supplied to the native
mouse-passthrough code. They do not exercise Windows desktop click-through or
visually inspect a running transparent overlay. The native C# window code is
unchanged. The headless environment still reports the existing certificate-store
and shutdown resource warnings.

The editor import completed and generated the new script UIDs. It also reported
unrelated Rapier and script-ide plugin errors, missing editor OAuth files in the
isolated profile, and a sandbox-denied editor help-cache write. The toast test and
preview runs reported no GDScript errors.

## Preview without a Twitch event

Open `test/vetting_toast_preview.tscn` in Godot and press **F6** (Run Current Scene).
One toast appears automatically. Use **Add toast**, **Add 8 toasts**, and
**Clear toasts** to exercise placement, overflow, resizing, and dismissal.

The preview uses an in-memory vetting instance: its decision buttons do not save
vetting records or execute live reward actions, and it never starts the Twitch or
OBS connections. It uses the normal RS autoload, which still reads application
settings. The preview itself does not enable native desktop mouse passthrough.
