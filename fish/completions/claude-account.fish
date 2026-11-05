# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_claude_account_global_optspecs
    string join \n h/help V/version
end

function __fish_claude_account_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_claude_account_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_claude_account_using_subcommand
    set -l cmd (__fish_claude_account_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c claude-account -n "__fish_claude_account_needs_command" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_needs_command" -s V -l version -d 'Print version'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "status" -d 'Show every account, every proxy, every name and everything that is wrong'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "list" -d 'List the accounts, one per line'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "switch" -d 'Make an account the one `claude` runs as'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "add" -d 'Register another account, with a profile and a proxy of its own'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "remove" -d 'Forget an account. Its profile directory is left where it is'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "current" -d 'Print the name of the active account'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "dir" -d 'Print the profile directory of an account, for `CLAUDE_CONFIG_DIR`'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "env" -d 'Print the shell lines that put this shell into an account'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "url" -d 'Print the address a name resolves to'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "setup" -d 'Install everything at once: the wrapper, a proxy per account, the router'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "adopt" -d 'Take over the proxy services that were written by hand'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "doctor" -d 'Report every problem and exit non-zero when there is one'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "shim" -d 'The `claude` wrapper in ~/.local/bin'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "headroom" -d 'The proxy of one account'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "router" -d 'The router that resolves <name>.headroom.localhost'
complete -c claude-account -n "__fish_claude_account_needs_command" -f -a "completions" -d 'Tab completion, with the account names in it'
complete -c claude-account -n "__fish_claude_account_using_subcommand status" -s v -l verbose -d 'Add the last lines each proxy logged'
complete -c claude-account -n "__fish_claude_account_using_subcommand status" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand list" -l names -d 'Print the names alone, for scripts and for tab completion'
complete -c claude-account -n "__fish_claude_account_using_subcommand list" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand switch" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand add" -l dir -d 'A profile directory elsewhere' -r -F
complete -c claude-account -n "__fish_claude_account_using_subcommand add" -l port -d 'A port for its proxy; the next free one by default' -r
complete -c claude-account -n "__fish_claude_account_using_subcommand add" -l switch -d 'Make it the account `claude` runs as straight away'
complete -c claude-account -n "__fish_claude_account_using_subcommand add" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand remove" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand current" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand dir" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand env" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand url" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand setup" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand adopt" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand doctor" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand shim; and not __fish_seen_subcommand_from install uninstall" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand shim; and not __fish_seen_subcommand_from install uninstall" -f -a "install" -d 'Write ~/.local/bin/claude'
complete -c claude-account -n "__fish_claude_account_using_subcommand shim; and not __fish_seen_subcommand_from install uninstall" -f -a "uninstall" -d 'Remove it again'
complete -c claude-account -n "__fish_claude_account_using_subcommand shim; and __fish_seen_subcommand_from install" -l force -d 'Overwrite a `claude` that this tool did not write'
complete -c claude-account -n "__fish_claude_account_using_subcommand shim; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand shim; and __fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -f -a "install" -d 'Write the service for an account and start it'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -f -a "start" -d 'Start the proxy of an account'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -f -a "stop" -d 'Stop it'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -f -a "restart" -d 'Stop and start it'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -f -a "uninstall" -d 'Stop it and remove its service'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -f -a "port" -d 'Give an account another port, and write it everywhere it is named'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and not __fish_seen_subcommand_from install start stop restart uninstall port logs" -f -a "logs" -d 'Print what one proxy logged'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from start" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from stop" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from restart" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from port" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from logs" -s n -l lines -d 'How many lines' -r
complete -c claude-account -n "__fish_claude_account_using_subcommand headroom; and __fish_seen_subcommand_from logs" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and not __fish_seen_subcommand_from serve install uninstall port list" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and not __fish_seen_subcommand_from serve install uninstall port list" -f -a "serve" -d 'Serve the names until stopped'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and not __fish_seen_subcommand_from serve install uninstall port list" -f -a "install" -d 'Install the router as a user service'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and not __fish_seen_subcommand_from serve install uninstall port list" -f -a "uninstall" -d 'Stop it and remove its service'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and not __fish_seen_subcommand_from serve install uninstall port list" -f -a "port" -d 'Move the router to another port'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and not __fish_seen_subcommand_from serve install uninstall port list" -f -a "list" -d 'List the names that resolve'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and __fish_seen_subcommand_from serve" -l port -r
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and __fish_seen_subcommand_from serve" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and __fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and __fish_seen_subcommand_from port" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand router; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c claude-account -n "__fish_claude_account_using_subcommand completions" -l install -d 'Write the file where the shell reads it, instead of printing it'
complete -c claude-account -n "__fish_claude_account_using_subcommand completions" -s h -l help -d 'Print help'

# The accounts as they are right now, asked for when Tab is pressed.
complete -c claude-account -n '__fish_seen_subcommand_from switch dir env url remove start stop restart logs install uninstall port' -f -a '(claude-account list --names)'
