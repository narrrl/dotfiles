# Evidence

## 1. Innovative

- The shell applies one custom QML geometry and print system across panels,
  backdrops, motion, and textures (`quickshell/config/Theme.qml:118-153`,
  `quickshell/components/P5Panel.qml:7-56`).
- This refreshes standard desktop bars/popovers, but the interaction model is
  still conventional bar + rail + popup + modal.

## 2. Useful

- The permanent bar exposes workspaces, active window, media, resources, and
  time in one slab (`quickshell/bar/Bar.qml:67-122`).
- Power and lock are keyboard-operable; bar, rail, tray, and most pop-out
  actions remain pointer-only (`quickshell/overlays/PowerMenu.qml:242-261`,
  `quickshell/lock/LockFace.qml:290-311`,
  `quickshell/bar/RailIcon.qml:104-124`).
- The primary surfaces contain at least 41 interactive targets; the live total
  grows with workspaces, devices, streams, notifications, and tray entries.

## 3. Aesthetic

- A clear system exists: spacing `[6,12,20,32]`, type
  `[9,11,12,15,20,34,92]`, 12 literal palette colors, one nominal 14° angle,
  and shared 10px cuts (`quickshell/config/Theme.qml:19-49,92-148`).
- Runtime type exceptions include 8, 30, 42, and 156.4px; local geometry also
  introduces several non-token cuts and leans.
- White on crimson is 3.68:1 and fails normal-text AA where selected destructive
  actions or unread badges use that pairing
  (`quickshell/components/P5Button.qml:32-73`,
  `quickshell/bar/NotifButton.qml:38-58`).
- Screenshot #1: permanent chrome is visually continuous and disciplined, but
  competes with an already high-contrast Persona wallpaper/frame.
- Screenshot #2: the left headline/right action-stack composition is strong;
  the repeated stripe field and still-legible desktop behind it dilute focus.

## 4. Understandable

- The power screen labels all actions and prints its keyboard map
  (`quickshell/overlays/PowerMenu.qml:31-38,216-261`).
- Rail icons expose different left/right/middle/scroll behaviors without visible
  instruction (`quickshell/bar/Rail.qml:76-132`).
- Several state labels behave as inverse actions: “Wi-Fi On,” Bluetooth “On,”
  “Scanning,” and “Silenced” toggle those states off.
- “WHO GOES THERE,” “WRONG,” “HELD,” “PROCS,” “VRAM,” and unlabeled load values
  favor voice or jargon over immediate comprehension.

## 5. Unobtrusive

- Normal chrome consumes only a 40px top bar and 48px right rail
  (`quickshell/config/Theme.qml:109-116`).
- The full-screen modes add stripes, a wedge, oversized split text, attribution,
  six slabs, and a hint simultaneously
  (`quickshell/overlays/PowerMenu.qml:50-228`).
- Twelve action identities are repeated between permanent chrome and detail
  panels; repetition improves reach but adds competing affordances.

## 6. Honest

- No marketing inflation or dark patterns were found. Power labels map directly
  to their system action (`quickshell/overlays/PowerMenu.qml:31-38,230-239`).
- “n HELD” counts all history rather than suppressed items
  (`quickshell/popouts/NotifPopout.qml:27`,
  `quickshell/services/Notifs.qml:36-44`).
- Muted OSDs display 0% even when stored volume remains nonzero
  (`quickshell/overlays/Osd.qml:51-64,172-185`).
- A visually disabled slider can still emit changes
  (`quickshell/components/P5Slider.qml:9-12,48-84`).

## 7. Long-lasting

- The system is based on reusable primitives rather than per-screen decoration.
- Literal `P5` branding, the quote attribution, and the esports-like continuous
  frame tie the result closely to one entertainment reference and visual era
  (`quickshell/bar/Sigil.qml:31`,
  `quickshell/overlays/PowerMenu.qml:88-118`).

## 8. Thorough

- Empty, loading, failure, focus, and disabled states exist.
- A rendered success state is absent; generic buttons lack a disabled state;
  focus treatment is concentrated in power and lock; explicit accessible names
  and roles total zero (`quickshell/components/P5Button.qml:6-107`).
- The lock’s disabled state is clear, but `P5Slider` can look disabled while
  remaining interactive.

## 9. Environmentally friendly

- The shell has 0 JavaScript bytes, about 259KB of QML, 1.4KB of local texture
  assets, no declared HTTP request, and a measured load proxy below two seconds.
- Seven Fluxo reads recur in polling batches; playing media creates 3–6 idle
  animation loops (`quickshell/services/Sys.qml:78-102`,
  `quickshell/bar/MediaPill.qml:125-153`).
- No reduced-motion branch exists (`quickshell/config/Theme.qml:139-148`).

## 10. As little design as possible

- The one-slab bar avoids a row of redundant cards
  (`quickshell/bar/Bar.qml:8-14,40-63`).
- The audited tree reaches seven declarative levels, contains twelve repeated
  action identities, and includes removable atmospheric elements in modal and
  lock compositions.
- The permanent surface, transient surface, and cinematic surface currently
  share too much of the same visual intensity instead of forming a hierarchy.

## Known gaps

- Dynamic application strings, device counts, and menu depth cannot be fixed
  from static source.
- Exact compositor frame time, GPU cost, and live accessibility-tree output
  were not available.
- Screenshot evidence covers the normal desktop and power overlay; lock-screen
  judgments also use its implementation source.
