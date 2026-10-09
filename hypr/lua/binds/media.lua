-- Laptop multimedia keys: volume, mic, brightness, transport.
-- `locked` keeps them working over the lock screen.

-- Volume and brightness repeat when held.
local held = { locked = true, repeating = true }

-- wpctl rather than `fluxo vol`, which goes up to 150%; `-l 1` stops at 100%.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("fluxo vol mute"), held)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("fluxo mic mute"), held)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +10%"), held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), held)

-- Transport. Requires playerctl.
local locked = { locked = true }

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
