#!/usr/bin/env sh

# env vars -
# LINKDING_BASE_URL: <your linkding service url>; eg. links.abc.io
# APP_DIR: <directory to save the backed up .json in>; eg. "$HOME/backups"
# LINKDING_API_KEY: <your linkding API key; This is a secret!
# LINKDING_FORCE_LOCAL: <true / false>; false by default. set to true if you do not want to upload to an external cloud storage provider.

BACKUP_FILE_NAME='bookmarks.json'
API_PATH="${LINKDING_BASE_URL}/api"
LINKDING_FORCE_LOCAL="${LINKDING_FORCE_LOCAL:=false}"

function get_bookmarks() {
    local NOW="$(date -u +"%FT%H%M")"
    local AUTH_HEADER="Authorization: Token ${LINKDING_API_KEY}"
    BACKUP_FILE_NAME="${APP_DIR}/bookmarks-${NOW}.json"

    curl --verbose --location "${API_PATH}/bookmarks" --header "${AUTH_HEADER}" --output "${BACKUP_FILE_NAME}"
}

function has_rclone() {
    if ! command -v rclone &>/dev/null; then
        echo "rclone could not be found. Falling back to local storage."
        return 1
    else
        return 0
    fi
}

function rclone_upload() {
    REMOTE=$(echo "${RCLONE_REMOTE_NAME}:${RCLONE_REMOTE_DIR}")
    rclone --config="$APP_DIR/rclone.conf" copy "${BACKUP_FILE_NAME}" "${REMOTE}"
}

function backup() {

    if "$LINKDING_FORCE_LOCAL"; then
        get_bookmarks
        echo "Bookmarks saved at $BACKUP_FILE_NAME"
        return
    fi

    if has_rclone; then
        if get_bookmarks; then
            if rclone_upload; then
                echo "Upload successful."
                rm -f "$BACKUP_FILE_NAME"
                return
            else
                echo "Upload failed. Saved bookmarks backup to local storage."
                return 1
            fi
        else
            echo "Failed to retrieve bookmarks from '$API_PATH'"
            return 1
        fi
    else
        get_bookmarks
        echo "Bookmarks saved at $BACKUP_FILE_NAME"
    fi
}

backup
