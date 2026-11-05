# YoRHa dark — matched to ~/.config/quickshell/config/Theme.qml and
# ~/.config/alacritty/yorha.toml.
#
# Commands are the planet light, arguments the sage text, strings moss,
# anything wrong the hull red. Selection and the pager's current row invert —
# a light slab with the void punched out of it, the same cursor the shell
# draws.
#
# Note that `fish_config` writing a theme from the web UI will recreate
# fish_frozen_theme.fish, which sorts before this file and so would lose.

set --global fish_color_normal ccd2cb
set --global fish_color_command eef1ea --bold
set --global fish_color_keyword c9b27c
set --global fish_color_param bcc1bf
set --global fish_color_option 9cbdb4
set --global fish_color_quote 8fa37e
set --global fish_color_escape c9b27c
set --global fish_color_operator 9fa7a2
set --global fish_color_redirection 9fa7a2
set --global fish_color_end 79847a
set --global fish_color_comment 545c52
set --global fish_color_error c8684f --bold
set --global fish_color_cancel c8684f
set --global fish_color_gray 545c52
set --global fish_color_autosuggestion 545c52
set --global fish_color_selection 0f110e --background=bcc1bf
set --global fish_color_search_match 0f110e --background=eef1ea
set --global fish_color_match 0f110e --background=bcc1bf
set --global fish_color_history_current --bold
set --global fish_color_valid_path --underline
set --global fish_color_cwd c9b27c --bold
set --global fish_color_cwd_root c8684f --bold
set --global fish_color_user 9cbdb4
set --global fish_color_host eef1ea --bold
set --global fish_color_host_remote 8fa37e
set --global fish_color_status c8684f

set --global fish_pager_color_progress 79847a --background=161915
set --global fish_pager_color_background
set --global fish_pager_color_prefix eef1ea --bold
set --global fish_pager_color_completion ccd2cb
set --global fish_pager_color_description 79847a
set --global fish_pager_color_secondary_background --background=0c0d0b
set --global fish_pager_color_secondary_completion ccd2cb
set --global fish_pager_color_secondary_description 79847a
set --global fish_pager_color_secondary_prefix eef1ea --bold
set --global fish_pager_color_selected_background --background=eef1ea
set --global fish_pager_color_selected_completion 0f110e
set --global fish_pager_color_selected_description 0f110e
set --global fish_pager_color_selected_prefix 0f110e --bold
