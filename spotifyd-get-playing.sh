# Author: Tim Smith <tim14smith@gmail.com> - tim14smith on GitHub
# Usage: add this script as --on-song-change-hook /path/to/spotifyd-get-playing.sh
#   when running spotifyd then read the current playing/paused track from $HOME/.spotifyd-playing,
#   for example, in a status bar view (like i3status, polybar, etc).
#   Requires sqlite3 CLI because TRACK_NAME is not provided on "pause" or "start" events
#   and I'm way too lazy to try looking up the track from the API or doing weird file I/O.
#   It doesn't show the artist or anything fancy because again, that API tho.
#   If you ctrl-C spotifyd while running --no-daemon it'll still show the last track.
#   This is a wontfix. I made this script for me, enjoy if you want.
#   Some tracks might now show a name...IDK why. ¯\_(ツ)_/¯
# License: MIT

#!/usr/bin/env bash

spotifyd_db=${SPOTIFYD_DB:-"$HOME/.spotifyd.db"}
spotifyd_playing_file=${SPOTIFYD_PLAYING_FILE:-"$HOME/.spotifyd-playing"}
sqlite3 "$spotifyd_db" "CREATE TABLE IF NOT EXISTS spotifyd (
    track_id TEXT PRIMARY KEY,
    track_name TEXT
);"
sqlite3 "$spotifyd_db" "CREATE TABLE IF NOT EXISTS spotifyd_last (id text primary key, track_name TEXT);"

get_track_info() {
    echo "TRACK_NAME is $TRACK_NAME"
    # Sanitize TRACK_NAME for sqlite3 insertion (escape single quotes)
    TRACK_NAME=$(echo "$TRACK_NAME" | sed "s/'/''/g")
    sqlite3 "$spotifyd_db" "INSERT OR REPLACE INTO spotifyd (track_id, track_name) VALUES ('$TRACK_ID', '$TRACK_NAME');"
    sqlite3 "$spotifyd_db" "INSERT OR REPLACE INTO spotifyd_last (id, track_name) VALUES ('1', '$TRACK_NAME');"
    spotify_show "$1"
}

spotify_show() {
    TRACK_NAME=$(sqlite3 "$spotifyd_db" "SELECT track_name FROM spotifyd WHERE track_id = '$TRACK_ID';")
    # Fallback if TRACK_NAME is empty, sometimes it has a different ID between change and pause/start
    if [[ -z "$TRACK_NAME" || "$TRACK_NAME" =~ ^[[:space:]]*$ ]]; then
        TRACK_NAME=$(sqlite3 "$spotifyd_db" "SELECT track_name FROM spotifyd_last LIMIT 1;")
        echo "$1 $TRACK_NAME 🎵" > "$spotifyd_playing_file"
    else
        echo "$1 $TRACK_NAME 🎵" > "$spotifyd_playing_file"
    fi
}

spotify_stop() {
    sqlite3 "$spotifyd_db" "DELETE FROM spotifyd;" # Clear history on stop
    echo "" > "$spotifyd_playing_file"
}

main() {

    echo "Event: $PLAYER_EVENT"
    if [[ "$PLAYER_EVENT" == "change" ]];
    then
        echo "Show playing with $TRACK_ID"
        get_track_info "▶"
    elif [[ "$PLAYER_EVENT" == "pause" ]];
    then
        echo "Show pause with $TRACK_ID"
	spotify_show '⏸'
    elif [[ "$PLAYER_EVENT" == "start" ]];
    then
	echo "Show playing with $TRACK_ID"
	spotify_show '▶'
    elif [[ "$PLAYER_EVENT" == "stop" ]];
    then
        echo "Stop event."
        spotify_stop
    else
        echo "Unused event."
    fi
}

main
