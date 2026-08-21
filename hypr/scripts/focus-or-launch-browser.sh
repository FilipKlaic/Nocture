#!/bin/sh
if hyprctl clients -j | grep -q '"class": "firefox"'; then
    hyprctl dispatch focuswindow class:firefox
else
    firefox
fi
