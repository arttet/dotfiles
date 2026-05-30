local mod = "SUPER"

local function app(cmd)
    return "uwsm app -- " .. cmd
end

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("SDL_VIDEODRIVER", "wayland")

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm finalize")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user restart elephant.service walker.service mako.service")
    hl.exec_cmd(app("hyprpaper"))
    hl.exec_cmd(app("hypridle"))
end)

hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
        },
    },
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
    },
    decoration = {
        rounding = 6,
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
        },
        shadow = {
            enabled = true,
            range = 10,
            render_power = 2,
        },
    },
    animations = {
        enabled = true,
        bezier = "smooth, 0.05, 0.9, 0.1, 1.05",
        animation = {
            { name = "windows",    speed = 6,  curve = "smooth" },
            { name = "windowsOut", speed = 5,  curve = "default", style = "popin 80%" },
            { name = "fade",       speed = 7,  curve = "default" },
            { name = "workspaces", speed = 6,  curve = "default" },
        },
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- Applications
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(app("ghostty")))
hl.bind(mod .. " + R", hl.dsp.exec_cmd(app("walker")))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(app("zen")))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(app("thunar")))
hl.bind(mod .. " + A", hl.dsp.exec_cmd(app("pavucontrol")))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd(app("ghostty -e yazi")))

-- Window management
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float())

-- Window focus (arrow keys)
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mouse window management
hl.bindm(mod .. " + mouse:272", hl.dsp.window.move())
hl.bindm(mod .. " + mouse:273", hl.dsp.window.resize())

-- Resize submap (Ctrl+Super+R to enter, Escape/Return to exit)
hl.bind(mod .. " + CTRL + R", hl.dsp.submap("resize"))
hl.submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x = 20,  y = 0 }),  { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -20, y = 0 }),  { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x = 0,   y = -20 }), { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x = 0,   y = 20 }),  { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
end)

-- Window rules (always float)
hl.windowrule({ class = "pavucontrol",               float = true })
hl.windowrule({ class = "xdg-desktop-portal-gtk",    float = true })
hl.windowrule({ class = "hyprpicker",                float = true })
hl.windowrule({ class = "thunar", title = ".*Confirm.*", float = true })
hl.windowrule({ class = "thunar", title = ".*Progress.*", float = true })

-- Session
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + L", hl.dsp.exec_cmd(app("hyprlock")))
hl.bind(mod .. " + Backspace", hl.dsp.exec_cmd(app("wlogout")))
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd(app("workstation-session-menu")))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Media & brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshots
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(app("hyprshot -m region --clipboard")))
hl.bind("Print", hl.dsp.exec_cmd(app("hyprshot -m output --clipboard")))
