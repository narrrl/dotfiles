function make_screenshot --wraps='grim' --description 'makes screenshot'
    set image "$(date).png"
    grim $GRIM_DEFAULT_DIR/$image
    notify-send "Screenshot made!" -i $GRIM_DEFAULT_DIR/$image
end
