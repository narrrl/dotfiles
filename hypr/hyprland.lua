-- narls hyprland dotfiles
--
-- Hyprland 0.55+ reads this file instead of hyprland.conf. Every part lives in
-- lua/, and each require() is its own scope: an error in one file does not stop
-- the others from loading.
--
-- Order matters only in three places: palette must exist before anything
-- paints with it, monitors must exist before the lid handler binds to them,
-- and game mode reads the look and the animations as configured. All three are
-- handled by the requires below, top to bottom.

-- what the desktop looks like
require("lua/palette")
require("lua/look")
require("lua/animations")

-- what it runs on
require("lua/env")
require("lua/monitors")
require("lua/lid")
require("lua/input")

-- what it runs
require("lua/apps")
require("lua/autostart")

-- how windows behave
require("lua/rules/windows")
require("lua/rules/layers")

-- after look and animations: it reads their values to put back
require("lua/gamemode")

-- how it is driven
require("lua/binds/apps")
require("lua/binds/windows")
require("lua/binds/workspaces")
require("lua/binds/shell")
require("lua/binds/media")
require("lua/binds/capture")
