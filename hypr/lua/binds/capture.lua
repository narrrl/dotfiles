-- Screenshots, replay buffer, webcam. Everything that records something.

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts/"

-- ------------------------------------------------------------- screenshots
-- PRINT selects a region, CTRL grabs the focused window, SHIFT saves to disk
-- instead of the clipboard.
-- All four go through scripts/shot.sh, which also posts a notification with
-- the capture as its thumbnail (Open, Edit with satty, Save).
local shot = scripts .. "shot.sh "
hl.bind("PRINT", hl.dsp.exec_cmd(shot .. "region copy"), { description = "screenshot an area to the clipboard" })
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(shot .. "region save"), { description = "screenshot an area to a file" })
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd(shot .. "window copy"), { description = "screenshot the window to the clipboard" })
hl.bind("CTRL + SHIFT + PRINT", hl.dsp.exec_cmd(shot .. "window save"), { description = "screenshot the window to a file" })

-- ------------------------------------------------------- replay and camera
-- On release, so the shortcut is not caught mid-chord.
local on_release = { release = true }

hl.bind("ALT + z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh toggle"), on_release)
hl.bind("ALT + SHIFT + z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh save"), on_release)
hl.bind("ALT + SHIFT + c", hl.dsp.exec_cmd(scripts .. "droidcam-ctrl.sh toggle"), on_release)
