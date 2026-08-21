#!/usr/bin/env bash
# Toggle the internal panel between 144 Hz and 60 Hz.
# 60 Hz saves roughly 1-2 W of panel draw and lightens the compositing load.
#
# The Lua config uses Hyprland's non-legacy parser, so `hyprctl keyword` is
# rejected -- monitor changes have to go through `hyprctl repl` / hl.monitor().
set -euo pipefail

MON=eDP-2
HIGH=144
LOW=60

new=$(hyprctl repl "
    local m = hl.get_monitor('${MON}')
    if not m then return 'ERR' end
    local new = (m.refresh_rate > 100) and ${LOW} or ${HIGH}
    hl.monitor({
        output   = '${MON}',
        mode     = string.format('%dx%d@%d', m.width, m.height, new),
        position = string.format('%dx%d', m.x, m.y),
        scale    = string.format('%.4f', m.scale),
    })
    return new
" 2>&1 | tr -d '[:space:]')

if [[ "$new" != "$HIGH" && "$new" != "$LOW" ]]; then
    notify-send -u critical -a Display "Refresh rate" "Toggle failed: ${new}"
    exit 1
fi

notify-send -a Display -i video-display "Refresh rate" "${MON} → ${new} Hz"
