#!/bin/sh -e

ENV_FILE="$HOME/dev/bin/env"
URL='showcasr-frontend.ravern.co'
#PID_FILE="/tmp/kiosk.pid"

KILL_CHROME_FLAG=0

main() {
    if [ -e "${ENV_FILE}" ]; then
        log "Found ENV FILE"
        . "${ENV_FILE}"
    else
        log "DID NOT FIND ENV FILE"
    fi
    check_internet_connection
    open_ping_terminal
    open_log_terminal
    disable_screen_saver
    disable_chromium_warnings
    launch_chromium

    while true; do
        if ping -c1 google.com >/dev/null 2>&1; then
            KILL_CHROME_FLAG=0
        else
            log "Check Internet connectivity"
            KILL_CHROME_FLAG=1
        fi

        if [ $KILL_CHROME_FLAG = 0 ]; then
            # Check if chrome already running if not
            if ! pgrep chromium >/dev/null 2>&1; then
                launch_chromium
            fi
        else
            if pgrep chromium >/dev/null 2>&1; then
                killall chromium-browser-v7 || true
            fi
        fi
        sleep 5
    done

}

check_internet_connection() {
    log "Checking Internet conection"

    if ! ping -c1 google.com >/dev/null 2>&1; then
        log "Internet connection failed"
        exit 1
    else
        log "Internet connection available"
    fi
}

open_ping_terminal() {
    # if [ -e "${PID_FILE}" ]; then
    # log "Found PID FILE"
    # curPID=$(<"$PIDFile")

    # if kill -0 "$curPID"; then
    # echo "Terminal Already Running"
    # return
    # else
    # rm -f "${PID_FILE}"
    # fi
    # else
    # log "DID NOT FIND ENV FILE"
    # fi
    lxterminal -l -e "ping -i 60 google.com" &
    # pid=$!
    # echo "${pid}" > "{PID_FILE}"

}

open_log_terminal() {
    lxterminal -l -e "journalctl -f -u kiosk --boot" &
}

disable_screen_saver() {
    log "Disabling screensaver"
    xset s noblank || true
    xset s off || true
    xset -dpms || true
    if ! pgrep -x "unclutter" >/dev/null; then
        log "Launching unclutter"
        unclutter -idle 0.5 -root &# Hides mouse
    else
        log "unclutter already running"
    fi
}

disable_chromium_warnings() {
    log "Disabling chromium warnings"
    sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
    sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences
}

launch_chromium() {
    log "Launching chromium"
    /usr/bin/chromium-browser --noerrdialogs --disable-infobars --kiosk "${URL}" >/dev/null 2>&1 &

    if [ -n "${USERNAME}" -a -n "${PASSWORD}" -a -n "${URL}" ]; then
        sleep 30
        do_login
    fi
}

do_login() {
    log "Logging into the website"

    xdotool click 1
    sleep 1
    xdotool key "Tab"
    sleep 1
    xdotool type "${USERNAME}"
    sleep 1
    xdotool key "Tab"
    sleep 1
    xdotool type "${PASSWORD}"
    sleep 1
    xdotool key "Return"
}

log() {
    echo "$@"
}

main
