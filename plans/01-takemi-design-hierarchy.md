# Takemi design hierarchy redesign

## Outcome

Turn the existing Persona 5 shell into a three-level visual system:

1. **Chrome** — quiet, glanceable, and subordinate to applications.
2. **Transient** — expressive pop-outs with distinct compositions and obvious controls.
3. **Cinematic** — theatrical power and lock scenes with focused hierarchy.

Preserve the crimson/black/white palette, services, keybinds, one-slab bar/rail,
`P5Panel`, session-lock security, and current functional coverage. This plan changes
visual hierarchy and interaction clarity, not the desktop stack.

## Phase 1 execution override — 2026-08-11

For the current Phase 1 implementation, the user explicitly removed reduced-motion
work and screen-reader metadata from scope. This override supersedes Phase 1.1, the
`Accessible.*` parts of Phase 1.4, and their related definition-of-done and
verification requirements for this execution only.

- Do not create durable motion preferences or change animation policy.
- Do not add or alter `Accessible.*` metadata or accessible action handlers.
- Keep keyboard focus, visible focus treatment, keyboard navigation, root-disabled
  input behavior, semantic color/treatment tokens, and the surface hierarchy in
  scope.
- Defer the remaining overridden requirements to a separately approved milestone.

## Implementation progress — 2026-08-11

- **Phase 1 foundation: complete for the approved scope.** Added explicit surface
  presets and semantic treatment tokens; made `P5Button` and `P5Slider`
  keyboard-capable with visible focus and root-gated disabled behavior. The user
  explicitly excluded durable reduced-motion work and `Accessible.*` metadata, so
  those items remain deferred rather than incomplete regressions.
- **Phase 2 calm chrome: complete.** Bar and rail use the quiet `ChromeSurface`
  tier without permanent texture; the clock omits seconds; CPU/MEM/GPU are visibly
  labelled; MediaPill uses elided static text and a static play/pause mark; rail
  clicks consistently pin detail panels and undisclosed secondary state actions
  were removed; delayed Persona tooltips show state and scroll hints without
  taking focus or overlapping an opening detail panel.
- **Audio vertical slice: complete.** Output percentage is dominant, output/input
  are distinct bands, application streams are subordinate, and mute plus mixer
  actions are explicit. Pinned popouts use `PopupWindow.grabFocus` as their sole
  focus/dismiss owner, remap when promoted from hover, focus the first Audio
  control, support Tab and Escape, and synchronously release coordinator ownership.
- **Verification status.** Changed QML passes individual Qt 6 `qmllint` and the
  repository diff passes whitespace validation. Tooltip placement/suppression and
  hover open/close were exercised in a live Quickshell session and passed. Pinned
  click/remap, outside-click dismissal, Escape, and compositor-close synchronization
  remain untested and require interaction QA before the milestone is considered
  runtime-verified.

## Non-goals

- Do not replace Quickshell, Hyprland, Fluxo, PAM, or the service layer.
- Do not add new accent hues or generic glass/blur cards.
- Do not reproduce Persona 5 screens literally; keep this a usable desktop shell.
- Do not build a second “control center” that duplicates every existing pop-out.
- Do not rewrite tray-menu recursion or the popup coordinator unless verification
  exposes a concrete defect.

## Definition of done

- Permanent chrome remains readable but no longer competes with application content.
- Each primary rail icon has one obvious click action and a concise hover label.
- Selected, active, destructive, error, and urgent states are distinguishable by
  treatment as well as color.
- All small text meets WCAG AA; black-on-crimson replaces white-on-crimson where needed.
- Pinned pop-outs and modal controls are keyboard reachable and visibly focused.
- Power actions that end the session require a deliberate confirmation step.
- Lock has idle, editing, busy, failure, and visible success compositions.
- Reduced motion survives process restarts and stops all nonessential loops.
- `qmllint`, live reload, interaction checks, and 1920×1080 plus 1366×768 visual
  captures pass without new warnings.

---

## Phase 0 — API and pattern lock

### Allowed APIs

- **Quickshell 0.3.0 `PopupWindow`:** `visible`, `anchor`, `grabFocus`, `screen`.
  Configure placement through `anchor.item/window`, `edges`, `gravity`, `margins`,
  `adjustment`; call `anchor.updateAnchor()` when a visible trigger moves.
  [Official PopupWindow docs](https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/)
  and [PopupAnchor docs](https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupAnchor/).
- **Popup bounds:** combine `PopupAdjustment.Flip | Slide | Resize` where content
  can genuinely resize. Use `QsWindow.mask: Region { item: ... }` for transparent
  overshoot bleed only after testing transformed entry animation.
  [PopupAdjustment](https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupAdjustment/),
  [Region](https://quickshell.org/docs/v0.3.0/types/Quickshell/Region/).
- **Pinned dismissal:** current `HyprlandFocusGrab.active/windows/onCleared` is valid
  only after a visible window exists (`components/Popout.qml:83-97`). Do not combine
  it casually with `PopupWindow.grabFocus`; choose one owner per opening mode.
  [HyprlandFocusGrab](https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandFocusGrab/).
- **Durable preferences:** `FileView` + `JsonAdapter`, using
  `Quickshell.statePath("design-preferences.json")`, `watchChanges`, `reload()`, and
  `writeAdapter()`. `PersistentProperties` survives reload only, not restart.
  [FileView](https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView/),
  [JsonAdapter](https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/JsonAdapter/).
- **Accessibility:** `Accessible.role/name/description/focusable/focused/pressed`,
  `Accessible.onPressAction`, `onIncreaseAction`, and `onDecreaseAction`; decorative
  duplicates use `Accessible.ignored: true`.
  [Qt Accessible](https://doc.qt.io/qt-6/qml-qtquick-accessible.html).
- **Focus:** `FocusScope`, `focusPolicy: Qt.StrongFocus`, `activeFocusOnTab`,
  `KeyNavigation`, `Keys`, and `forceActiveFocus(Qt.PopupFocusReason)`.
  [Qt focus model](https://doc.qt.io/qt-6/qtquick-input-focus.html).
- **Disabled controls:** disable the root `Item`; this suppresses pointer and keyboard
  input and propagates to children. Explicitly bind `HoverHandler.enabled` when a
  disabled control must not react visually.
  [Qt Item](https://doc.qt.io/qt-6/qml-qtquick-item.html).
- **System contrast:**
  `Application.styleHints.accessibility.contrastPreference === Qt.HighContrast`.
  Qt 6.11 has no documented reduced-motion preference, so motion policy is owned by
  `Preferences`.
- **Secure lock:** retain `WlSessionLock`/`WlSessionLockSurface` in
  `lock/Lock.qml:12-28`; `Overlay + Exclusive` is not a secure replacement.
  [WlSessionLock](https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlSessionLock/).

### Repository patterns to copy

- Copy singleton structure from `config/Theme.qml:1-16` and `services/Actions.qml:1-10`.
- Copy popup show/hide ownership from `components/Popout.qml:58-116,150-190`.
- Copy keyboard roving selection from `overlays/PowerMenu.qml:242-261`.
- Copy development-safe lock preview boundary from `lock/Lock.qml:7-27` and
  `lockpreview.qml`; never style by repeatedly locking the real session.
- Copy one-slab chrome composition from `bar/Bar.qml:40-63` and `bar/Rail.qml:43-64`.

### Verification

- Record `qs --version` and Qt version in the implementation PR: expected Quickshell
  0.3.0 and Qt 6.11.1.
- Run `qmllint` on each copied API in a minimal changed component before broad rollout.
- Use `qs ipc show` to confirm existing IPC surface before adding typed functions.

### Guards

- No deprecated `PopupWindow.parentWindow`, `relativeX`, or `relativeY`.
- No direct `QsWindow.width/height`; use implicit sizes.
- No `WlrKeyboardFocus.Exclusive` as a lock substitute.
- No stock `QsMenuAnchor` or default Qt tooltip visuals inside the custom theme.
- No claimed system reduced-motion detection; it does not exist in the documented API.

---

## Phase 1 — Establish the semantic design foundation

### 1.1 Durable preferences

Create `quickshell/config/Preferences.qml` using the Phase 0 `FileView`/`JsonAdapter`
pattern. Persist:

- `reducedMotion: false`
- `tooltips: true`
- `highIntensityChrome: false` only as a migration escape hatch; default remains calm

Expose typed setters through the existing `IpcHandler` in
`services/Actions.qml:60-68`, such as `setReducedMotion(enabled: bool): void`. Do not
build a settings UI in this phase.

### 1.2 Three explicit surface presets

- Add `components/ChromeSurface.qml`: a thin `P5Panel` preset with opaque flat fill,
  one keyline, no halftone, no drop, and an active slash only when requested.
- Refine `popouts/PopoutSurface.qml:7-23` as the transient preset: halftone becomes
  opt-in by composition rather than present on every panel; retain the hard offset
  and stronger border.
- Keep `components/P5Backdrop.qml` cinematic-only. Bar, rail, tooltips, cards, and OSD
  must not instantiate it.

Do not add a generic numeric “intensity” prop to `P5Panel`; explicit presets make
the hierarchy visible in code and prevent arbitrary intermediate tiers.

### 1.3 Semantic treatments

Document and encode in `config/Theme.qml`:

| State | Fill | Mark | Text | Motion |
|---|---|---|---|---|
| Rest | surface | neutral keyline | white | none |
| Hover | surface | short red wipe | white | one short lunge |
| Focus/selected | white | black keyline | black | snap once |
| Active | surface | persistent red slash | white | none |
| Destructive/error | solid red | black keyline | black | shake only on error |
| Urgent | surface | red pulse mark | white | bounded pulse |
| Disabled | surface | muted outline | muted | none |

Replace small white-on-crimson labels with black-on-crimson; measured contrast improves
from 3.68:1 to 5.70:1. Do not add a new status color.

### 1.4 Base-control contract

- Convert `components/P5Button.qml` to a `FocusScope` or focusable root with one
  activation path shared by `TapHandler`, Enter, Space, and
  `Accessible.onPressAction`. Add `description`, visible focus state, and a real
  disabled state.
- Replace `P5Slider.enabledControl` with root `enabled` and update its call sites.
  Gate tap, drag, hover, accessible increase/decrease, and left/right keys through
  the same enabled root.
- Add semantic names and roles to `RailIcon`, `StatusIcon`, notification actions,
  media transport, calendar navigation, and tray-menu rows. Mark split-text ghosts,
  masks, texture layers, and duplicate glyphs ignored.

### Verification

- Focus every base control with Tab and confirm a visible non-color-only state.
- Trigger each through pointer, Enter/Space, and its accessible action; assert one
  signal per activation.
- Disable each control and assert no `clicked`/`moved` signal and no hover animation.
- Recompute all foreground/background contrast pairs; normal text must be ≥4.5:1.
- Restart Quickshell and confirm preferences persist.

### Guards

- Do not treat `Accessible` metadata as keyboard support; implement both.
- Do not attach semantics to every decorative child.
- Do not use `MouseArea.enabled` as the component-wide disabled gate.
- Do not spread raw state colors through callers; state treatment belongs in base controls.

---

## Phase 2 — Quiet and clarify permanent chrome

### 2.1 Bar

Update `bar/Bar.qml` and `bar/BarPill.qml` to use `ChromeSurface` and remove all
always-on texture. Keep the single slab and hairline dividers.

- `bar/Clock.qml`: remove permanent seconds; reveal them only inside Calendar.
- `bar/Resources.qml`: render tiny `CPU`, `MEM`, and `GPU` labels beside values so
  `2.6G` is not contextless; remove the currently dead `Metric.label` path only after
  its visible replacement exists.
- `bar/MediaPill.qml`: keep title/artist but replace the three continuously animated
  equalizer bars with one static play-state mark in normal mode. Allow the loop only
  when high-intensity chrome is explicitly enabled and reduced motion is off.
- Preserve active-window elision and current collision calculation in
  `bar/Bar.qml:90-96`.

### 2.2 Rail interaction grammar

Make left click mean **open/pin details** for network, Bluetooth, audio, battery,
notifications, and power. Remove undisclosed right/middle-click state changes from
`bar/Rail.qml:76-132,151-171`; move those actions into their corresponding pop-outs.

Retain scrolling only for volume, microphone, and brightness because it directly
maps to a continuous readout. Mention that gesture in the tooltip.

### 2.3 Persona tooltip

Add `components/P5Tooltip.qml` as a small anchored `PopupWindow`, not a stock Qt
tooltip. Copy anchor/delay/hide behavior from `components/Popout.qml`, but use:

- calm `ChromeSurface`
- 350–450ms delay
- one-line name + current state
- optional second micro-line such as `SCROLL TO ADJUST`
- no focus grab, no halftone, no scale loop
- `PopupAdjustment.Flip | Slide`

Add `label` and `hint` to `RailIcon`; tooltips honor `Preferences.tooltips` and never
become the only source of an accessible name.

### 2.4 Pinned keyboard opening

Add explicit `openHover()` and `openPinned()` paths to `components/Popout.qml`.
`openPinned()` must set its focus mode before mapping; if a hover popup is already
visible, close and remap rather than assuming a live `grabFocus` change works. Start
with Audio as the vertical slice. Choose either `PopupWindow.grabFocus` or the current
`HyprlandFocusGrab` for pinned dismissal after runtime comparison; never leave both
owning the same close event.

### Verification

- Screenshot clean desktop against both a quiet and high-contrast wallpaper.
- First-time test: identify every rail icon and predict left click from tooltip.
- Verify no secondary pointer action remains unless it is printed in the tooltip.
- Open Audio by hover and click: hover must remain passive; pinned mode must accept
  keyboard focus, Esc-close, and outside-click close exactly once.
- Move/rescale the rail while a popup is open and call `anchor.updateAnchor()` from
  the actual geometry-change path if it drifts.

### Guards

- Do not reintroduce separate floating cards into bar or rail.
- Do not increase bar/rail footprint.
- Do not put stripes, halftone, or large display text in permanent chrome.
- Do not make a tooltip interactive.

---

## Phase 3 — Give transient surfaces distinct macro-compositions

Retain shared popup lifecycle, width discipline, coordinator, header baseline, and
body controls. Redesign one family at a time; capture and approve each family before
moving on so a bad motif is not copied eight times.

### 3.1 Control pop-outs

- **Audio (`AudioPopout.qml`)** — make current volume the headline number; output and
  microphone form two clear bands; applications become a restrained mixer list.
  Put Mute and `Open audio mixer` inside the panel.
- **Network (`NetPopout.qml`)** — dossier composition: current connection/IP at top,
  download/upload fully named, network list as clipped paper rows. Use action labels
  `Turn Wi-Fi on/off` and `Network settings`.
- **Bluetooth (`BtPopout.qml`)** — share list-row mechanics with Network but not its
  exact silhouette. Use action copy `Turn on/off`, `Start/stop scanning`; pair/connect
  status must not rely on color alone.
- **Battery (`BatteryPopout.qml`)** — oversized percentage crossing one edge, with
  `Plugged in`/`On battery`, remaining time, draw, and health ordered underneath.
  Keep Suspend as the one explicit action.

### 3.2 Information pop-outs

- **Media (`MediaPopout.qml`)** — let album art define one side of the silhouette;
  keep metadata in a solid legibility zone; label transport actions accessibly.
- **Calendar (`CalendarPopout.qml`)** — large selected day/month as the composition,
  grid subordinate; move seconds here from the permanent bar; label previous/next.
- **Notifications (`NotifPopout.qml`, `NotifCard.qml`)** — overlapping-paper rhythm
  only at the list level, not on every inner action. Rename `n HELD` to `n IN HISTORY`;
  make DND copy an action (`Silence notifications` / `Resume notifications`).
- **System (`SysPopout.qml`)** — treat it as a diagnostic poster: four primary metrics
  first, hardware detail second. Expand `PROCS`, `MEM`, `VRAM`, `Root`, and label load
  averages `1 / 5 / 15 min`.

### 3.3 Shared transient rules

- `PopoutHeader` supplies alignment and focus traversal, not the full silhouette.
- Only one dominant numeral/image/headline per panel.
- Maximum one halftone region and one red slash per panel.
- Lists use consistent 32–40px targets and explicit selected/focused/disabled states.
- Empty and loading layouts preserve the panel silhouette instead of collapsing.
- Fix muted OSD honesty: show stored percentage beside `MUTED`, or omit percentage;
  never display a fabricated 0%.

### Verification

- Capture all eight pop-outs at rest plus empty/loading/error/disabled states where applicable.
- Test with longest realistic SSID, device, track, app, and notification strings.
- Verify list focus order, Enter/Space activation, Esc close, and disabled-row skipping.
- Ensure only one transient window stays open through a rapid rail sweep.
- Test popup bounds at every screen edge and both target resolutions.

### Guards

- Do not create eight copies of the same card grid.
- Do not vary edge angle randomly inside one surface.
- Do not use display italic for body copy or dense device lists.
- Do not put action wording in state form (`Wi-Fi On`) when clicking performs the inverse.

---

## Phase 4 — Focus the cinematic scenes

### 4.1 Power menu

In `overlays/PowerMenu.qml`:

- Keep the left headline/right action-stack asymmetry.
- Increase backdrop opacity enough that application text no longer competes.
- Use one stripe band or wedge, not a full-screen stripe field plus every other motif.
- Separate Lock/Suspend/Hibernate from Log Out/Reboot/Shut Down with a labeled break
  and greater spacing.
- Keep white fill/black text for normal selection. Use solid crimson/black text for
  destructive selection.
- Add `pendingAction`: the first activation of Log Out/Reboot/Shut Down replaces the
  action region with `CONFIRM LOG OUT`, `CONFIRM REBOOT`, or `CONFIRM SHUT DOWN`
  plus Cancel; second activation executes.
  Escape clears confirmation first and closes the menu only when no action is pending.
- Keep roving Up/Down/J/K navigation and update focus order for confirmation.

### 4.2 Lock screen

Refactor `lock/LockFace.qml` into explicit visual states while retaining the single
PAM context and `WlSessionLock` shell:

- **Idle:** clock is dominant; status is quiet; auth field is present but subordinate.
- **Editing:** first user edit shifts emphasis to auth and dims/moves clock/status.
- **Busy:** `CHECKING…`, disabled input, bounded sweep.
- **Failure:** `PASSWORD INCORRECT` or PAM message, solid error treatment, one shake.
- **Success:** paint a short `ACCESS GRANTED` state before unlocking; skip delay under
  reduced motion.

Replace `WHO GOES THERE`, `WRONG`, and `PAM ERROR` with explicit copy. Resolve the
username safely from `USER` then `LOGNAME`; if both are empty, do not call PAM with a
literal placeholder—show `AUTHENTICATION USER UNAVAILABLE`.

Keep responsive scaling, per-monitor wallpaper, and `lockpreview.qml`. Ensure the
password input exposes `Accessible.EditableText`, name `Password`, `editable: true`,
and `passwordEdit: true`.

### Verification

- Power: pointer and keyboard through safe action, destructive confirmation, cancel,
  outside click, and repeated open/close.
- Lock preview: capture all five states at 1920×1080 and 1366×768.
- Real lock test only after preview and PAM-path review; test wrong password, correct
  password, empty username environment simulation, and Quickshell reload behavior.
- Confirm `WlSessionLock.secure` path remains unchanged.

### Guards

- Never execute destructive action on the first activation.
- Never fake authentication success in preview or bypass PAM.
- Never replace session lock with a focus-exclusive overlay.
- Do not let theatrical copy obscure what the user must do.

---

## Phase 5 — Motion, contrast, and runtime calm

### 5.1 Motion policy

In `Theme.qml`, derive `motionScale` from `Preferences.reducedMotion`. Apply it to:

- every `Behavior`
- popup enter/exit sequences
- media equalizer and marquee loops
- icon pulses
- toast countdown/entry
- OSD, power, and lock scene transitions

When reduced motion is on, set final state directly or disable `Behavior`; do not merely
shorten loops to 1ms. Essential progress indicators may remain static with clear text.

### 5.2 High contrast

Read `Application.styleHints.accessibility.contrastPreference`. In high contrast:

- increase keyline/border separation
- disable low-opacity texture behind text
- retain shape/icon differences among selection, active, danger, and urgency
- do not change the three-color identity

### 5.3 Polling cleanup

After visual behavior is stable, move `sysReader` from the 2-second batch to the
20-second batch in `services/Sys.qml:78-102`; uptime/load/process count do not drive
permanent animation. Keep CPU/MEM/GPU at 2 seconds because the bar renders them.
Measure before making further demand-driven polling changes; do not introduce a
consumer-count abstraction without evidence that it materially reduces work.

### Verification

- Restart with reduced motion and verify zero infinite animations via source grep and
  live observation; all final states must still appear.
- Toggle high contrast and re-run contrast checks.
- Compare Fluxo process-launch frequency before/after for 60 seconds.
- Confirm notification timing, popup dismissal, and lock success still complete when
  animation is disabled.

### Guards

- Do not claim to follow an OS reduced-motion setting.
- Do not gate functional timers such as notification lifetime or polling behind motion.
- Do not add blur, gradients, or extra texture to compensate for removed motion.

---

## Phase 6 — Integrated verification and cutover

### Automated checks

1. `qmllint -I quickshell` on every changed QML file individually; the current tool can
   exit 255 without diagnostics on some recursive/singleton batches, so record files
   and results rather than treating one giant invocation as authoritative.
2. `git diff --check`.
3. Grep for:
   - white small text on solid accent
   - `enabledControl`
   - pointer handlers without an accessible name on shared controls
   - infinite animations not gated by reduced motion
   - deprecated popup properties
   - old copy: `WHO GOES THERE|PAM error|HELD|PROCS|VRAM`
4. Reload through `qs ipc call shell reloadConfig` and inspect `qs log`.

### Interaction matrix

Test each bar/rail/pop-out action with pointer, keyboard where focusable, outside-click,
Esc, disabled state, and service unavailable. Specifically test tray menus with nested
submenus, Wi-Fi off, no Bluetooth adapter, no battery, no player, no notifications,
and missing album art.

### Visual matrix

Capture:

- 1920×1080 and 1366×768
- calm and high-contrast wallpaper
- default, reduced-motion, and high-contrast preferences
- desktop, every pop-out, tray menu, OSD, toast, power normal/confirm, and all lock states

Compare against these invariants:

- Chrome has no texture and never dominates content.
- Transient panels each have one dominant composition.
- Cinematic scenes retain the strongest typography and atmosphere.
- Nothing important is encoded by color alone.
- No text clips, crosses a cut edge, or falls below contrast requirements.

### Cutover sequence

Implement in six reviewable commits matching Phases 1–6. Do not delete the old visual
path until its phase passes screenshots and interaction tests. Remove migration aliases
(`enabledControl`, high-intensity escape hatch) only in the final cleanup commit after
all call sites and preferences have migrated.

## Expected file map

### New

- `quickshell/config/Preferences.qml`
- `quickshell/components/ChromeSurface.qml`
- `quickshell/components/P5Tooltip.qml`

### Foundation edits

- `quickshell/config/Theme.qml`
- `quickshell/components/P5Panel.qml`
- `quickshell/components/P5Button.qml`
- `quickshell/components/P5Slider.qml`
- `quickshell/components/Popout.qml`
- `quickshell/components/Icon.qml`
- `quickshell/components/Marquee.qml`
- `quickshell/services/Actions.qml`

### Surface edits

- `quickshell/bar/{Bar,BarPill,Rail,RailIcon,StatusIcon,Clock,Resources,MediaPill,Tray}.qml`
- `quickshell/popouts/{PopoutSurface,PopoutHeader,AudioPopout,NetPopout,BtPopout,BatteryPopout,MediaPopout,CalendarPopout,NotifPopout,SysPopout,TrayMenuList}.qml`
- `quickshell/components/NotifCard.qml`
- `quickshell/overlays/{Osd,Toasts,PowerMenu}.qml`
- `quickshell/lock/LockFace.qml`
- `quickshell/services/Sys.qml`

## Recommended execution order

Execute Phase 1 first and review its state matrix before any visual restyling. Then use
Audio as the full vertical slice through Phases 2–3. Once its tooltip, pinned focus,
semantic states, reduced motion, and transient composition pass, repeat that proven
pattern across the remaining surfaces. Leave real session-lock testing until the lock
preview and power confirmation work are complete.
