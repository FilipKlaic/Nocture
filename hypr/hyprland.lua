------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@144",
    position = "-1920x0",
    scale    = "1",
    vrr      = 1,
})

hl.monitor({
    output   = "eDP-2",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = "1.2",
})

-------------------------
---- ENVIRONMENT VAR ----
-------------------------
hl.config({
    env = {
        "ELECTRON_OZONE_PLATFORM_HINT,auto", -- For Discord/Electron
        "IDE_JDK_RUNTIME_FEATURE,wayland",   -- For Rider/IntelliJ
        "_JAVA_AWT_WM_NONREPARENTING,1",     -- Fix Java menu issues
        "GDK_BACKEND,wayland,x11,*",         -- Prefer Wayland for GTK
        "QT_QPA_PLATFORM,wayland;xcb",       -- Prefer Wayland for Qt
        "QT_QPA_PLATFORMTHEME,qt6ct",        -- Tell Qt apps to use qt6ct
    }
})

---------------------
---- MY PROGRAMS ----
-------------------------------------
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "/home/filip/.config/rofi/launchers/type-1/launcher.sh"
local browser     = "zen-browser"

-------------------
---- AUTOSTART ----
-------------------
package.loaded["borders"] = nil
local borders = require("borders")

hl.on("hyprland.start", function ()
    hl.exec_cmd("qs")
    hl.exec_cmd("waypaper --restore")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hypridle")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,
        border_size = 2,
        resize_on_border = true,
        extend_border_grab_area = 15,
        col = {
            active_border   = borders.active_border,
            inactive_border = borders.inactive_border,
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size    = 6,
            passes  = 3,
            new_optimizations = true,
        },
        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 2,
            color        = "0x99000000",
        },
    },
    animations = {
        enabled = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
    windowrulev2 = {
        "float, class:(waypaper)",
        "size 900 600, class:(waypaper)",
        "center, class:(waypaper)",
        "opacity 0.9 0.8, class:(waypaper)",
        "opacity 0.92 0.87, class:(thunar)",
    },
    xwayland = {
        force_zero_scaling = true,
    }
})

------------------------
---- ANIMATIONS ----
------------------------

-- Bezier curves
hl.curve("overshot",   { type = "bezier", points = { {0.05, 0.9}, {0.1,  1.05} } })
hl.curve("undershot",  { type = "bezier", points = { {0.9, -0.05}, {0.95, 0.1} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.36, 0},   {0.66, -0.56} } })
hl.curve("smoothIn",  { type = "bezier", points = { {0.25, 1},   {0.5,  1} } })
hl.curve("linear",    { type = "bezier", points = { {0, 0},      {1, 1} } })

-- Spring curve for windows (snappy, slight bounce)
hl.curve("snappy", { type = "spring", mass = 1, stiffness = 120, dampening = 18 })

-- Windows open/close/move
hl.animation({ leaf = "windows",       enabled = true, speed = 6,  bezier = "smoothIn" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 8,  spring = "snappy",   style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 6,  bezier = "smoothIn" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 7,  bezier = "smoothIn",  style = "slide" })

-- Borders
hl.animation({ leaf = "border",        enabled = true, speed = 8,  bezier = "overshot" })
hl.animation({ leaf = "borderangle",   enabled = true, speed = 8,  bezier = "linear",    style = "loop" })

-- Fade
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 6,  bezier = "smoothIn" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 5,  bezier = "smoothIn" })
hl.animation({ leaf = "fadeSwitch",    enabled = true, speed = 6,  bezier = "smoothIn" })

-- Workspaces
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 8,  bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 7,  bezier = "smoothOut", style = "slide" })

-- Layers (waybar, swaync, rofi)
hl.animation({ leaf = "layersIn",      enabled = true, speed = 6,  bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 5,  bezier = "smoothOut", style = "slide" })

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "se",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
            scroll_factor  = 0.5,
        },
    },
})

-- Gestures (3-finger swipe to switch workspaces)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

--------------------------
---- WORKSPACE LAYOUT ----
--------------------------
-- Workspaces 1-3 → laptop (eDP-2), workspaces 4-6 → external (HDMI-A-1)
-- When HDMI-A-1 is disconnected, workspaces 4-6 fall back to eDP-2 automatically
-- Only the per-monitor anchor workspace (1 and 4) is persistent, so it's always
-- there as a fallback. The rest must NOT be persistent, or Hyprland never destroys
-- them when empty and waybar keeps showing them as open until a manual reload.
hl.workspace_rule({ workspace = "1", monitor = "eDP-2",   default = true,  persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-2" })
hl.workspace_rule({ workspace = "3", monitor = "eDP-2" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", default = true,  persistent = false })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1" })

--------------------
---- LAYER RULES ----
--------------------
-- Quickshell status bar + rofi both get real compositor blur behind their
-- translucent backgrounds. The status bar's own slide is client-side
-- (margin Behavior in StatusBarWindow.qml, same pattern as SidebarApp),
-- so no "animation" is set here -- it would double up with that.
hl.layer_rule({ match = { namespace = "quickshell-statusbar" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "quickshell-statusbar-sysmon" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "rofi" },   blur = true, ignore_alpha = 0.2 })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Core Apps
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close()) -- Kill active window
hl.bind(mainMod .. " + M",      hl.dsp.exit())        -- Logout
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload")) -- Reload Config
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd("waypaper"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("waypaper --random"))
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("qs ipc call statusbar toggle")) -- Toggle Quickshell status bar
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())

-- Workspace Management (1-6)
for i = 1, 6 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end


-- Laptop Multimedia Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                         { locked = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                         { locked = true })

-- Display Power
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/refresh-toggle.sh")) -- Toggle 144/60 Hz

-- Screenshots (Hyprshot)
hl.bind("PRINT",                hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + PRINT",  hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"))

-- Hyprspace Overview
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("hyprctl dispatch overview:toggle"))

-- Mouse Binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
