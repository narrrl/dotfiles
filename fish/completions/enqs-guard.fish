# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_enqs_guard_global_optspecs
    string join \n h/help V/version
end

function __fish_enqs_guard_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_enqs_guard_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_enqs_guard_using_subcommand
    set -l cmd (__fish_enqs_guard_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -s V -l version -d 'Print version'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "hook" -d 'Answer as a PreToolUse hook; reads the event from stdin (Claude Code)'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "session-start" -d 'Answer as a SessionStart hook (Claude Code)'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "status" -d 'Show the current guard state'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "init" -d 'Create a configuration template'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "mode" -d 'Set what the guard does'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "add" -d 'Put a project on one of the lists'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "remove" -d 'Take a project off one of the lists'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "check" -d 'Check whether a path is blocked'
complete -c enqs-guard -n "__fish_enqs_guard_needs_command" -f -a "completions" -d 'Print a tab completion script for a shell'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand hook" -s h -l help -d 'Print help'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand session-start" -s h -l help -d 'Print help'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand status" -s h -l help -d 'Print help'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand init" -s h -l help -d 'Print help'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand mode" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand add" -s h -l help -d 'Print help'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand remove" -s h -l help -d 'Print help'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand check" -s h -l help -d 'Print help'
complete -c enqs-guard -n "__fish_enqs_guard_using_subcommand completions" -s h -l help -d 'Print help'
