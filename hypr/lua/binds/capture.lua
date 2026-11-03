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

-- --------------------------------------------------------------- recording
-- A toggle: press once to pick an area (or take the monitor) and start, press
-- again to stop. Saved to ~/Videos/Recordings by scripts/record.sh.
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd(scripts .. "record.sh region"), { description = "record an area (again to stop)" })
hl.bind("SUPER + SHIFT + PRINT", hl.dsp.exec_cmd(scripts .. "record.sh screen"), { description = "record the screen (again to stop)" })

-- ------------------------------------------------------------ colour picker
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker --autocopy --no-fancy"), { description = "pick a colour to the clipboard" })

-- ------------------------------------------------------- replay and camera
-- replay-ctrl.sh needs gpu-screen-recorder.
-- On release, so the shortcut is not caught mid-chord.
local on_release = { release = true }

hl.bind("ALT + z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh toggle"), on_release)
hl.bind("ALT + SHIFT + z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh save"), on_release)
hl.bind("ALT + SHIFT + c", hl.dsp.exec_cmd(scripts .. "droidcam-ctrl.sh toggle"), on_release)
