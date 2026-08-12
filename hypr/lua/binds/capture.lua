-- Screenshots, replay buffer, webcam. Everything that records something.

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts/"

-- ------------------------------------------------------------- screenshots
-- PRINT selects a region, CTRL grabs the focused window, SHIFT saves to disk
-- instead of the clipboard.
hl.bind("PRINT", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +\'%Y-%m-%d_%H-%M-%S\').png'))
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd(scripts .. "screenshot_window.sh copy"))
hl.bind("CTRL + SHIFT + PRINT", hl.dsp.exec_cmd(scripts .. "screenshot_window.sh save"))

-- ------------------------------------------------------- replay and camera
-- On release, so the shortcut is not caught mid-chord.
local on_release = { release = true }

hl.bind("ALT + z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh toggle"), on_release)
hl.bind("ALT + SHIFT + z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh save"), on_release)
hl.bind("ALT + SHIFT + c", hl.dsp.exec_cmd(scripts .. "droidcam-ctrl.sh toggle"), on_release)
