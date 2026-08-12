-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
--
-- Quick and clean. Motion should get out of the way, not perform.
--
-- An earlier pass overdid it: a 1.56 overshoot on every window, an 88% popin
-- scale, and a borderangle looping forever so the focused border was in
-- constant motion. The bounce is dialled back to a hint, the popin barely
-- scales, and the border angle does not animate at all.

hl.config({
    animations = {
        enabled = true,
    },
})

-- ------------------------------------------------------------------- curves
hl.curve("snap", { type = "bezier", points = { { 0.16, 1.00 }, { 0.30, 1.00 } } })
hl.curve("overshoot", { type = "bezier", points = { { 0.34, 1.12 }, { 0.64, 1.00 } } })
hl.curve("hard", { type = "bezier", points = { { 0.55, 0.00 }, { 0.90, 0.35 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

-- --------------------------------------------------------------------- tree
-- speed is in ds (1ds = 100ms). Unset leaves inherit their parent.
hl.animation({ leaf = "global", enabled = true, speed = 4, bezier = "snap" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "snap" })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "snap" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "overshoot", style = "popin 96%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.6, bezier = "hard", style = "popin 97%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.6, bezier = "snap" })

hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "snap" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.4, bezier = "snap" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.8, bezier = "hard" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2, bezier = "snap" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 3, bezier = "snap" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.4, bezier = "snap" })

hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "snap" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "snap", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "hard", style = "slide" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "snap", style = "slidevert" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 3, bezier = "snap", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.4, bezier = "hard", style = "slidevert" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "snap", style = "slidevert" })
