if status is-interactive
    # Commands to run in interactive sessions can go here
end
# set SPACESHIP_PROMPT_ADD_NEWLINE false
# set SPACESHIP_TIME_SHOW false
# set SPACESHIP_USER_SHOW always
# set SPACESHIP_HOST_SHOW true
# set SPACESHIP_CHAR_SYMBOL ""
# set SPACESHIP_CHAR_SYMBOL=" "
# set SPACESHIP_VI_MODE_INSERT 
# set SPACESHIP_VI_MODE_NORMAL 
# Set the cursor shapes for the different vi modes.
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual block
starship init fish | source
fish_vi_key_bindings
if test -e ~/.cache/wal/colors.fish
    source ~/.cache/wal/colors.fish
end
zoxide init --cmd cd fish | source
set -gx PATH /home/niru/.local/bin $PATH
