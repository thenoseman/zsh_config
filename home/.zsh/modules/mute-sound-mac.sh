#!/bin/bash
# Mute sound
# Acticate with
# sudo defaults write com.apple.loginwindow LogoutHook $(pwd)/mute-sound-mac.sh
if [[ "$1" == "unmute" ]]; then
  osascript -e 'set volume without output muted'
else
  osascript -e 'set volume with output muted'
fi
