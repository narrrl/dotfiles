# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_enqs_jail_global_optspecs
    string join \n h/help V/version
end

function __fish_enqs_jail_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_enqs_jail_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_enqs_jail_using_subcommand
    set -l cmd (__fish_enqs_jail_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -s V -l version -d 'Print version'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "register" -d 'Register a directory as a jail'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "unregister" -d 'Remove a registration'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "list" -d 'Show the registered jails'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "show" -d 'Show the settings a jail would run under'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "check" -d 'Check the prerequisites'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "allow" -d 'Re-open one path inside a jail'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "escape" -d 'Let one command run outside the sandbox, leaving the jail'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "revoke" -d 'Take a grant back'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "grants" -d 'Show the exceptions in force for a jail'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "completions" -d 'Print a tab completion script for a shell'
complete -c enqs-jail -n "__fish_enqs_jail_needs_command" -f -a "run" -d 'Start a session in a registered jail'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l name -d 'The name of the jail; the directory name by default' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l toolchain -d 'Toolchain whose caches stay readable; detected from the project when not given' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l deny-read -d 'Path hidden inside the jail; replaces the default list' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l allow-read -d 'Path that stays readable inside the jail (repeatable)' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l allow-write -d 'Path that stays writable inside the jail (repeatable)' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l add-dir -d 'Additional working directory inside the jail (repeatable)' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l claude-config-dir -d 'Claude profile the session runs under, e.g. ~/.claude-work' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l no-git -d 'Do not release the git configuration'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l no-default-deny -d 'Do not use the default deny list'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -l force -d 'Overwrite an existing registration of this name'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand register" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand unregister" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand list" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand show" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand check" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand allow" -l for -d 'How long it should last, e.g. 30m, 2h, 7d' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand allow" -l reason -d 'Why it was needed, kept with the grant' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand allow" -l jail -d 'The jail; the current directory when left out' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand allow" -l write -d 'Make it writable as well as readable'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand allow" -l once -d 'Only for the next session'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand allow" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand escape" -l for -d 'How long it should last, e.g. 30m, 2h, 7d' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand escape" -l reason -d 'Why it was needed, kept with the grant' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand escape" -l jail -d 'The jail; the current directory when left out' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand escape" -l once -d 'Only for the next session'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand escape" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand revoke" -l jail -d 'The jail; the current directory when left out' -r
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand revoke" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand grants" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand completions" -s h -l help -d 'Print help'
complete -c enqs-jail -n "__fish_enqs_jail_using_subcommand run" -s h -l help -d 'Print help'
