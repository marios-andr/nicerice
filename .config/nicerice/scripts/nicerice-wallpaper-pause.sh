#!/usr/bin/env bash
# awww-workspace-pause.sh — pauses awww's gif animation whenever the
# active workspace has an occupying window, resumes when it's empty.

# Set to 1 to ignore floating windows (wallpaper stays playing if only
# floating windows are open). Set to 0 to treat any window as occupying.
EXCEPT_FLOATING=1

is_occupied() {
    local wsid
    wsid=$(hyprctl activeworkspace -j | jq '.id')

    if [ "$EXCEPT_FLOATING" -eq 1 ]; then
        hyprctl clients -j \
            | jq --argjson id "$wsid" \
                '[.[] | select(.workspace.id == $id and .floating == false)] | length > 0'
    else
        hyprctl clients -j \
            | jq --argjson id "$wsid" \
                '[.[] | select(.workspace.id == $id)] | length > 0'
    fi
}

sync_pause_state() {
    if [ "$(is_occupied)" = "true" ]; then
        awww pause
    else
        awww unpause
    fi
}

# Set correct initial state in case windows already exist when this starts
sync_pause_state

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do
    case "$line" in
        openwindow\>\>*|closewindow\>\>*|movewindow\>\>*|changefloatingmode\>\>*|workspace\>\>*|focusedmon\>\>*)
            sync_pause_state
            ;;
    esac
done
