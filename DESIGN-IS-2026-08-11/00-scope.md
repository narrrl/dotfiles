# Takemi shell design audit — scope

## Audited artifact

- Running Persona 5-inspired desktop shell shown in the two supplied 1920×1080 screenshots.
- Quickshell implementation under `quickshell/`, including the top bar, right rail,
  pop-outs, tray menus, power overlay, notifications/OSD, and lock screen.
- Shared design tokens and primitives in `quickshell/config/` and
  `quickshell/components/`.

## User and task

- Primary user: the workstation owner using the shell throughout the day.
- Primary task: identify system state and reach common desktop controls quickly,
  without the theme obscuring application content.

## Constraints

- Preserve the Persona 5 / Tae Takemi identity.
- Preserve the crimson, black, and white palette and screen-print character.
- Stack remains Quickshell, Hyprland, and Fluxo.
- The result must work at desktop scale, with keyboard and pointer input, and
  remain legible during long sessions.

## References

- Persona 5 interface language: asymmetric editorial composition, hard ink,
  decisive silhouettes, halftone texture, and rapid card-like motion.
- Current implementation and supplied screenshots are the concrete baseline;
  fidelity to the game is subordinate to daily desktop usefulness.

## Out of scope

- Application-level themes outside the shell.
- Replacing the wallpaper or character artwork.
- Changing the desktop stack.
