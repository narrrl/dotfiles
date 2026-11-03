-- Screenshots, recordings, replay buffer, webcam. Everything that records
-- something.

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts/"

-- ------------------------------------------------------------- screenshots
-- PRINT selects an area. SHIFT saves to a file instead of the clipboard.
-- CTRL skips the selection and takes what has focus: the window here, the
-- monitor when recording.
-- All four go through scripts/shot.sh, which also posts a notification with
-- the capture as its thumbnail (Open, Edit with satty, Save).
local shot = scripts .. "shot.sh "
hl.bind("PRINT", hl.dsp.exec_cmd(shot .. "region copy"), { description = "screenshot an area to the clipboard" })
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(shot .. "region save"), { description = "screenshot an area to a file" })
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd(shot .. "window copy"), { description = "screenshot the window to the clipboard" })
hl.bind("CTRL + SHIFT + PRINT", hl.dsp.exec_cmd(shot .. "window save"), { description = "screenshot the window to a file" })

-- --------------------------------------------------------------- recording
-- SUPER makes it video. A toggle: press once to start, again to stop. Saved
-- to ~/Videos/Recordings by scripts/record.sh.
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd(scripts .. "record.sh region"), { description = "record an area (again to stop)" })
hl.bind("SUPER + CTRL + PRINT", hl.dsp.exec_cmd(scripts .. "record.sh screen"), { description = "record the monitor (again to stop)" })

-- Replay: SUPER+Z keeps the last two minutes in RAM, SUPER+SHIFT+Z writes
-- them out to ~/Videos/replay (scripts/replay-ctrl.sh, gpu-screen-recorder).
hl.bind("SUPER + Z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh toggle"), { description = "replay buffer on / off" })
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd(scripts .. "replay-ctrl.sh save"), { description = "save the last two minutes" })

-- ------------------------------------------------------------ colour, camera
-- Next to SUPER+C, the clipboard, which is where the colour lands.
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker --autocopy --no-fancy"), { description = "pick a colour to the clipboard" })
hl.bind("SUPER + CTRL + C", hl.dsp.exec_cmd(scripts .. "droidcam-ctrl.sh toggle"), { description = "phone camera on / off" })
