#!/bin/sh

if [ -z "$DBUS_SERVICE" ]; then
  echo 'dbus service name ($DBUS_SERVICE) is not set set!'
  exit 1
fi
if [ -z "$DBUS_PATH" ]; then
  echo 'dbus path name ($DBUS_PATH) is not set set!'
  exit 1
fi
if [ -z "$QDBUS" ]; then
  export QDBUS=qdbus
fi

###
# Basic functions
###

dbus_path_append() {
  first="$1"
  echo "${first%/}$2"
}

mpris_command() {
  "$QDBUS" "$DBUS_SERVICE" "$DBUS_PATH" "$@"
}

###
# Player control
###

mpris_play() {
  [ $(mpris_playback_status) != Playing ] && mpris_togglepause
}

mpris_pause() {
  mpris_command org.freedesktop.MediaPlayer2.Pause
}

mpris_togglepause() {
  mpris_command org.freedesktop.MediaPlayer2.PlayPause
}

mpris_stop() {
  mpris_command org.mpris.MediaPlayer2.Player.Stop
}

mpris_next() {
  mpris_command org.freedesktop.MediaPlayer2.Next
}

mpris_previous() {
  mpris_command org.freedesktop.MediaPlayer2.Previous
}

mpris_shuffle() {
  if [ "x$1" = "x" ] || [ "x$1" = "xtrue" ] || [ "x$1" = "xon" ]; then
    mpris_command org.mpris.MediaPlayer2.Player.Shuffle true
  else
    mpris_command org.mpris.MediaPlayer2.Player.Shuffle false
  fi
}

mpris_quit() {
  mpris_command org.freedesktop.MediaPlayer2.Quit
}

###
# Extended player control
###

mpris_play_uri() {
  [ -z "$1" ] && return 1
  mpris_command org.freedesktop.MediaPlayer2.OpenUri "$1"
}

###
# Player status
###

mpris_is_running() {
  if mpris_command org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1; then
    echo yes
    return 0
  else
    echo no
    return 1
  fi
}

mpris_playback_status() { # TODO: Spotify does it this way. Is this standard?
  DBUS_PATH=$(dbus_path_append "$DBUS_PATH" /org/mpris/MediaPlayer2) mpris_command org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus
}

###
# Metadata
###

mpris_track_metadata() {
  mpris_command org.freedesktop.MediaPlayer2.GetMetadata
}

mpris_track_metadata_field() {
  [ -z "$1" ] && return 1
  mpris_track_metadata | grep "$1" | cut -d' ' -f2-
}
