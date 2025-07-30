function batdiff --description 'batdiff function'
    git diff --name-only --diff-filter=d $argv | bat --diff
end
