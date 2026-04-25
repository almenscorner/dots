#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/illogical-impulse/config.json"
JSON_PATH=".screenRecord.savePath"

CUSTOM_PATH=$(jq -r "$JSON_PATH" "$CONFIG_FILE" 2>/dev/null)

if [[ -n "$CUSTOM_PATH" ]]; then
    RECORDING_DIR="$CUSTOM_PATH"
else
    RECORDING_DIR="$HOME/Videos"
fi

getdate() {
    date '+%Y-%m-%d_%H.%M.%S'
}
getactivemonitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

mkdir -p "$RECORDING_DIR"
cd "$RECORDING_DIR" || exit

ARGS=("$@")
MANUAL_REGION=""
SOUND_FLAG=0
FULLSCREEN_FLAG=0
for ((i=0;i<${#ARGS[@]};i++)); do
    if [[ "${ARGS[i]}" == "--region" ]]; then
        if (( i+1 < ${#ARGS[@]} )); then
            MANUAL_REGION="${ARGS[i+1]}"
        else
            notify-send "Recording cancelled" "No region specified for --region" -a 'Recorder' & disown
            exit 1
        fi
    elif [[ "${ARGS[i]}" == "--sound" ]]; then
        SOUND_FLAG=1
    elif [[ "${ARGS[i]}" == "--fullscreen" ]]; then
        FULLSCREEN_FLAG=1
    fi
done

LOCKFILE="/tmp/gsr-recording.pid"

if [[ -f "$LOCKFILE" ]] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
    notify-send "Recording Stopped" "Stopped" -a 'Recorder' &
    kill -SIGINT "$(cat "$LOCKFILE")"
    rm -f "$LOCKFILE"
    exit 0
fi
rm -f "$LOCKFILE"

FILENAME='recording_'"$(getdate)"'.mp4'

if [[ $FULLSCREEN_FLAG -eq 1 ]]; then
    notify-send "Starting recording" "$FILENAME" -a 'Recorder' & disown
    if [[ $SOUND_FLAG -eq 1 ]]; then
        gpu-screen-recorder -w "$(getactivemonitor)" -f 60 -a default_output -o "./$FILENAME" &
    else
        gpu-screen-recorder -w "$(getactivemonitor)" -f 60 -o "./$FILENAME" &
    fi
else
    if [[ -n "$MANUAL_REGION" ]]; then
        region="$MANUAL_REGION"
    else
        if ! region="$(slurp 2>&1)"; then
            notify-send "Recording cancelled" "Selection was cancelled" -a 'Recorder' & disown
            exit 1
        fi
    fi
    # slurp returns "X,Y WxH", gpu-screen-recorder -region wants "WxH+X+Y"
    read -r xy wh <<< "$region"
    IFS=',' read -r rx ry <<< "$xy"
    region_fmt="${wh}+${rx}+${ry}"

    notify-send "Starting recording" "$FILENAME" -a 'Recorder' & disown
    if [[ $SOUND_FLAG -eq 1 ]]; then
        gpu-screen-recorder -w region -region "$region_fmt" -f 60 -a default_output -o "./$FILENAME" &
    else
        gpu-screen-recorder -w region -region "$region_fmt" -f 60 -o "./$FILENAME" &
    fi
fi

echo $! > "$LOCKFILE"
