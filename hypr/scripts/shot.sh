#!/bin/sh
# Screenshots with a receipt: every capture lands on the clipboard and comes
# back as a notification with its own thumbnail, so a keypress that used to
# vanish silently now shows what it took.
#
#   shot.sh region copy    pick an area, copy it
#   shot.sh region save    pick an area, save it to ~/Pictures/Screenshots
#   shot.sh window copy    the focused window, copy it
#   shot.sh window save    the focused window, save it
#
# A copy is kept in $XDG_RUNTIME_DIR only so the notification has a picture
# to show; its Save action moves it into ~/Pictures/Screenshots. Edit opens
# satty when it is installed. Cancelling the region picker does nothing.

set -eu

target=${1:-region}
mode=${2:-copy}

dir="$HOME/Pictures/Screenshots"
stamp=$(date +'%Y-%m-%d_%H-%M-%S')

case "$target" in
    region)
        geometry=$(slurp) || exit 0
        name="$stamp.png"
        ;;
    window)
        info=$(hyprctl activewindow -j)
        geometry=$(printf '%s' "$info" | jq -r 'if .at then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else empty end')
        if [ -z "$geometry" ]; then
            notify-send -a Screenshot "Screenshot" "No window is focused."
            exit 1
        fi
        app=$(printf '%s' "$info" | jq -r '.class // "unknown"' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/_/g')
        name="${app}_$stamp.png"
        ;;
    *)
        echo "usage: shot.sh region|window copy|save" >&2
        exit 2
        ;;
esac

if [ "$mode" = save ]; then
    mkdir -p "$dir"
    file="$dir/$name"
else
    file="${XDG_RUNTIME_DIR:-/tmp}/shot-$name"
fi

grim -g "$geometry" "$file"
wl-copy --type image/png < "$file"

title=$([ "$mode" = save ] && echo "Screenshot saved" || echo "Screenshot copied")
body=$([ "$mode" = save ] && echo "${file#"$HOME"/}" || echo "On the clipboard")

set -- --action=open=Open
command -v satty >/dev/null 2>&1 && set -- "$@" --action=edit=Edit
[ "$mode" = copy ] && set -- "$@" --action=save=Save

# notify-send waits for the notification to close and prints the action
# that was chosen, so run it in the background and act on the answer.
(
    choice=$(notify-send -a Screenshot -i "$file" -h "string:image-path:$file" \
        "$@" "$title" "$body") || exit 0
    case "$choice" in
        open) xdg-open "$file" ;;
        edit) satty --filename "$file" --output-filename "$dir/edited_$name" --copy-command wl-copy ;;
        save) mkdir -p "$dir" && mv "$file" "$dir/$name" \
                && notify-send -a Screenshot -i "$dir/$name" -h "string:image-path:$dir/$name" \
                    "Screenshot saved" "${dir#"$HOME"/}/$name" ;;
    esac
) >/dev/null 2>&1 &
