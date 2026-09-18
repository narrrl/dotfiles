# Mocha — matched to ~/.config/quickshell/config/Theme.qml,
# ~/.config/alacritty/catppuccin-mocha.toml and ~/.config/nvim/lua/takemi.lua.
#
# Catppuccin Mocha's own fish theme (themes/Catppuccin Mocha.theme), with the
# selection and pager rows carried over from the Takemi layout: a solid accent
# block with crust punched out of it, rather than a tinted surface. The shell
# selects with a blue slab; the prompt should not disagree.
#
# Note that `fish_config` writing a theme from the web UI will recreate
# fish_frozen_theme.fish, which sorts before this file and so would lose.

set --global fish_color_normal cdd6f4
set --global fish_color_command 89b4fa
set --global fish_color_keyword f38ba8
set --global fish_color_param f2cdcd
set --global fish_color_option a6e3a1
set --global fish_color_quote a6e3a1
set --global fish_color_escape eba0ac
set --global fish_color_operator f5c2e7
set --global fish_color_redirection f5c2e7
set --global fish_color_end fab387
set --global fish_color_comment 7f849c --italics
set --global fish_color_error f38ba8 --bold
set --global fish_color_cancel f38ba8
set --global fish_color_gray 6c7086
set --global fish_color_autosuggestion 6c7086
set --global fish_color_selection 11111b --background=89b4fa
set --global fish_color_search_match 11111b --background=f5c2e7
set --global fish_color_match 11111b --background=89b4fa
set --global fish_color_history_current --bold
set --global fish_color_valid_path --underline
set --global fish_color_cwd f9e2af --bold
set --global fish_color_cwd_root f38ba8 --bold
set --global fish_color_user 94e2d5
set --global fish_color_host 89b4fa --bold
set --global fish_color_host_remote a6e3a1
set --global fish_color_status f38ba8

set --global fish_pager_color_progress 6c7086 --background=313244
set --global fish_pager_color_background
set --global fish_pager_color_prefix f5c2e7 --bold
set --global fish_pager_color_completion cdd6f4
set --global fish_pager_color_description 6c7086
set --global fish_pager_color_secondary_background --background=181825
set --global fish_pager_color_secondary_completion cdd6f4
set --global fish_pager_color_secondary_description 6c7086
set --global fish_pager_color_secondary_prefix f5c2e7 --bold
set --global fish_pager_color_selected_background --background=89b4fa
set --global fish_pager_color_selected_completion 11111b
set --global fish_pager_color_selected_description 11111b
set --global fish_pager_color_selected_prefix 11111b --bold
