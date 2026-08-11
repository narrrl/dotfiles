# Planning handoff

```text
/make-plan Redesign the Takemi Persona 5 desktop shell. Current design failed audit at 15/30 with critical gaps in principles #4 understandable, #5 unobtrusive, #8 thorough, #9 environmentally friendly, and #10 as little design as possible.

Verdict paragraph:
> The strict Rams verdict is REDESIGN (15/30): preserve the excellent brand tokens and working shell primitives, but redesign the hierarchy so permanent, transient, and cinematic surfaces no longer compete at the same intensity.

Why redesign and not refine: the total is below the 20-point refine threshold because the same high-intensity visual and interaction grammar spans permanent chrome, transient controls, and full-screen scenes.

Preserve from current design:
- Crimson/black/white palette, type scale foundation, and motion timings in quickshell/config/Theme.qml:19-148.
- Single-slab bar/rail architecture in quickshell/bar/Bar.qml:8-63 and quickshell/bar/Rail.qml:9-64.
- Reusable P5Panel geometry/texture engine in quickshell/components/P5Panel.qml:7-248.
- Existing services and feature coverage; this is an information/design hierarchy change, not a functionality cut.

Discard:
- One-intensity-fits-all use of stripes, halftone, split type, slashes, and repeated framed geometry. Evidence: DESIGN-IS-2026-08-11/01-evidence.md#5-unobtrusive. Caused failure on principles #5 and #10.
- Undisclosed multi-button/multi-gesture behavior on icon-only permanent controls. Evidence: DESIGN-IS-2026-08-11/01-evidence.md#4-understandable. Caused failure on principles #4 and #8.

Top moves:
1. Principles #4 and #8 — make behavior legible: give every icon one primary click action, add concise Persona-styled hover labels, expose secondary actions inside its pop-out, and add real focus/disabled/accessibility states. Evidence: DESIGN-IS-2026-08-11/01-evidence.md#4-understandable and #8-thorough.
2. Principles #5 and #10 — introduce three intensity tiers: quiet permanent chrome, expressive transient panels, theatrical full-screen scenes; reserve stripes, large split type, and strong halftone for the latter two. Evidence: DESIGN-IS-2026-08-11/01-evidence.md#5-unobtrusive and #10-as-little-design-as-possible.
3. Principles #3 and #6 — assign semantics by treatment, not red alone: use white fill for selection, a red rule/slash for active state, solid red only for destructive/error, and pulse only for urgency; fix white-on-red small text. Evidence: DESIGN-IS-2026-08-11/01-evidence.md#3-aesthetic and #6-honest.
4. Principles #3 and #7 — move the chaos to macro-composition: keep clean module geometry, but vary panel silhouette, title placement, and scale by context instead of repeating the same framed HUD grammar everywhere. Evidence: DESIGN-IS-2026-08-11/01-evidence.md#3-aesthetic and #7-long-lasting.
5. Principles #2 and #9 — add a calm mode: stop idle equalizer/pulse/marquee motion when reduced motion is requested and reduce polling when a detail panel is closed. Evidence: DESIGN-IS-2026-08-11/01-evidence.md#2-useful and #9-environmentally-friendly.

Redesign priorities:
1. Principle #4 — every visible control communicates its primary action without memorized mouse-button lore.
2. Principles #5/#10 — visual intensity increases deliberately from chrome to pop-out to modal.
3. Principles #3/#6 — color, fill, outline, pattern, and motion each have one stable semantic job.

Deliverables:
- New information architecture, not derived mechanically from the old layout.
- New labeled primary flow compared side-by-side with the current shell.
- Empty/loading/error/success/focus/disabled state matrix.
- Migration path that preserves existing service behavior and keybinds.
- Cutover criteria based on discoverability, contrast, reduced motion, and visual hierarchy.

Guard against porting the old structure under new styling, running both hierarchies indefinitely, following generic gaming-HUD trends, or discarding the preserved brand tokens and primitives.
```
