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
# starship init fish | source
fish_vi_key_bindings
if test -e ~/.cache/wal/colors.fish
    source ~/.cache/wal/colors.fish
end
zoxide init --cmd cd fish | source
set -gx PATH ~/.local/bin $PATH
# if not pgrep --full ssh-agent | string collect > /dev/null
#   eval (ssh-agent -c)
#   set -Ux SSH_AGENT_PID $SSH_AGENT_PID
#   set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
# end
# Set SSH_AUTH_SOCK for GNOME Keyring / systemd
# The socket path is predictable
set -l GCR_SSH_SOCK $XDG_RUNTIME_DIR/gcr/ssh
if test -S "$GCR_SSH_SOCK"
    set -gx SSH_AUTH_SOCK "$GCR_SSH_SOCK"
end
if uwsm check may-start && uwsm select
	exec uwsm start default
end
