-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
--
-- YoRHa motion: calm and mechanical. Things glide in, settle and stop; nothing
-- overshoots, nothing pops. Matches Theme.easeSnap / easeGlide in
-- ~/.config/quickshell/config/Theme.qml.
--
-- The screen is a porthole: the hull (quickshell/bar/Frame.qml) sits on the
-- top layer, so anything that moves past the edge of the opening passes
-- behind the frame instead of over the bar.
--
--   windows      resolve in from a hair smaller and fade, the way a NieR menu
--                panel appears rather than arrives; leave the same way, faster.
--   workspaces   drift: the old one sinks a little way behind the rim as it
--                fades, the new one rises into its place. A short, slow
--                vertical drift rather than a full-screen sweep, which on a
--                2560px panel is a lot of motion for "you are somewhere else
--                now". Direction follows workspace order.
--   scratchpad   a drawer: SUPER+S lowers it out from under the bar, the same
--                gesture as the dashboard and the popouts, and raises it back.
--   layers       only fade; quickshell animates its own surfaces.
--
-- Nothing overshoots and the border angle never animates.

hl.config({
    animations = {
        enabled = true,
    },
})

-- ------------------------------------------------------------------- curves
-- outQuint: fast off the mark, long quiet settle.
hl.curve("glide", { type = "bezier", points = { { 0.22, 1.00 }, { 0.36, 1.00 } } })
-- Material standard, for things that move from one place to another.
hl.curve("standard", { type = "bezier", points = { { 0.40, 0.00 }, { 0.20, 1.00 } } })
-- Leaving: ease in, so the exit gathers pace and is gone.
hl.curve("exit", { type = "bezier", points = { { 0.55, 0.00 }, { 0.90, 0.35 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
-- easeInOutSine-ish with a long tail: starts without a jolt, settles slowly.
-- For motion big enough that a fast start would read as a shove.
hl.curve("drift", { type = "bezier", points = { { 0.35, 0.00 }, { 0.15, 1.00 } } })

-- --------------------------------------------------------------------- tree
-- speed is in ds (1ds = 100ms). Unset leaves inherit their parent.
hl.animation({ leaf = "global", enabled = true, speed = 4, bezier = "glide" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "glide" })
hl.animation({ leaf = "borderangle", enabled = false })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "glide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "glide", style = "popin 94%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.4, bezier = "exit", style = "popin 96%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "standard" })

hl.animation({ leaf = "fade", enabled = true, speed = 3.4, bezier = "glide" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.4, bezier = "glide" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.2, bezier = "exit" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 3, bezier = "glide" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 3.4, bezier = "glide" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 3, bezier = "glide" })

-- Quickshell animates its own surfaces; the compositor only fades them, so the
-- two motions never stack.
hl.animation({ leaf = "layers", enabled = true, speed = 2.6, bezier = "glide" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.6, bezier = "glide", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "exit", style = "fade" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 5.5, bezier = "drift", style = "slidefadevert 18%" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 5.5, bezier = "drift", style = "slidefadevert 18%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.5, bezier = "drift", style = "slidefadevert 18%" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.5, bezier = "glide", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4.5, bezier = "glide", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3.5, bezier = "exit", style = "slidevert" })
