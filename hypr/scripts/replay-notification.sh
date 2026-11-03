#!/bin/sh
# Called by gpu-screen-recorder after it writes a file: $1 is the path, $2 is
# "replay" or "regular". Answers with a notification that can open the clip
# or its folder.

file=$1
case "$2" in
    replay) title="Replay saved" ;;
    regular) title="Recording saved" ;;
    *)
        echo "usage: $0 FILE replay|regular" >&2
        exit 2
        ;;
esac

(
    choice=$(notify-send -a Replay --action=open=Open --action=folder=Folder \
        "$title" "${file#"$HOME"/}") || exit 0
    case "$choice" in
        open) xdg-open "$file" ;;
        folder) xdg-open "$(dirname "$file")" ;;
    esac
) >/dev/null 2>&1 &
