function open -d "Open an application detached from the terminal"
    nohup $argv >/dev/null 2>&1 &
end