function cpr
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 $argv
end
