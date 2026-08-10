# Takemi — matched to ~/.config/quickshell/config/Theme.qml,
# ~/.config/alacritty/takemi.toml and ~/.config/nvim/lua/takemi.lua.
#
# Replaces the catppuccin fish_frozen_theme.fish that fish 4.3 generated on
# upgrade. Same content as themes/Takemi.theme — that copy exists only so
# `fish_config` can preview it; this one is what actually loads.
#
# Note that `fish_config` writing a theme from the web UI will recreate
# fish_frozen_theme.fish, which sorts before this file and so would lose.

set --global fish_color_normal ffffff
set --global fish_color_command ffffff --bold
set --global fish_color_keyword ff2d40
set --global fish_color_param c8c8ce
set --global fish_color_option 8d9bb8
set --global fish_color_quote 7f9b6a
set --global fish_color_escape 9db8bd
set --global fish_color_operator c8c8ce
set --global fish_color_redirection ff6b78
set --global fish_color_end 6b6b70
set --global fish_color_comment 6b6b70 --italics
set --global fish_color_error ff2d40 --bold
set --global fish_color_cancel ff2d40
set --global fish_color_gray 6b6b70
set --global fish_color_autosuggestion 4a4a52
set --global fish_color_selection 000000 --background=ff2d40
set --global fish_color_search_match 000000 --background=c8c8ce
set --global fish_color_match 000000 --background=ff2d40
set --global fish_color_history_current --bold
set --global fish_color_valid_path --underline
set --global fish_color_cwd ffffff --bold
set --global fish_color_cwd_root ff2d40 --bold
set --global fish_color_user c8c8ce
set --global fish_color_host ffffff --bold
set --global fish_color_host_remote ff6b78
set --global fish_color_status ff2d40

set --global fish_pager_color_progress 6b6b70 --background=141418
set --global fish_pager_color_background
set --global fish_pager_color_prefix ffffff --bold
set --global fish_pager_color_completion c8c8ce
set --global fish_pager_color_description 6b6b70
set --global fish_pager_color_secondary_background --background=0d0d10
set --global fish_pager_color_secondary_completion c8c8ce
set --global fish_pager_color_secondary_description 6b6b70
set --global fish_pager_color_secondary_prefix ffffff --bold
set --global fish_pager_color_selected_background --background=ff2d40
set --global fish_pager_color_selected_completion 000000
set --global fish_pager_color_selected_description 000000
set --global fish_pager_color_selected_prefix 000000 --bold
