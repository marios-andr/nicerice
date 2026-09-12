------------------
-- WINDOW RULES --
------------------

hl.window_rule({
    match = {
        fullscreen = true
    },
    border_size = 0,
    rounding = 0,
})

-- btop
hl.window_rule({
    name = "btop",
    match = { title = "btop" },
    float = true,
    center = true,
    size = {1600, 1000}
})

-- Blueman Manager
hl.window_rule({
    name = "blueman-manager",
    match = {class = "blueman-manager"},
    float = true,
    center = true,
    size = "800 600"
})

-- Pavucontrol??
hl.window_rule({
    name = "pavucontrol",
    match = {class = "org.pulseaudio.pavucontrol"},
    float = true,
    center = true,
    size = "1000 700"
})

-- fcitx configuration
hl.window_rule({
    name = "fcitx5-configtool",
    match = {class = "org.fcitx.fcitx5-config-qt"},
    float = true,
    center = true,
    size = "1000 700"
})

-- nm-connection-editor
hl.window_rule({
    name = "nm-connection-editor",
    match = {class = "nm-connection-editor"},
    float = true,
    center = true,
    size = "800 700"
})

-- nwg-look
hl.window_rule({
    name = "nwg-look",
    match = {class = "nwg-look"},
    float = true,
    center = true,
    size = "700 600"
})

-- nwg-displays
hl.window_rule({
    name = "nwg-displays",
    match = {class = "nwg-displays"},
    float = true,
    center = true,
    size = "900 600"
})

-- GTK File and Folder Picker
hl.window_rule({
    name = "xdg-desktop-portal-gtk",
    match = {class = "xdg-desktop-portal-gtk"},
    float = true,
    center = false,
    size = "800 600"
})

-- Hyprland Share Picker
hl.window_rule({
    name = "hyprland-share-picker",
    match = {class = "hyprland-share-picker"},
    float = true,
    pin = true,
    center = true,
    size = "600 400"
})

-- Hyprmod
hl.window_rule({
    name = "io.github.bluemancz.hyprmod",
    match = {class = "io.github.bluemancz.hyprmod"},
    float = true,
    center = true,
    size = "1000 700"
})

-- Gnome Calculator
hl.window_rule({
    name = "gnome-calculator",
    match = {class = "org.gnome.Calculator"},
    float = true,
    center = true,
    size = "700 600"
})

-- GalaxyBudsClient
hl.window_rule({
    name = "GalaxyBudsClient",
    match = { class = "GalaxyBudsClient" },
    float = true,
    center = true,
    size = {1600, 1000}
})


-- Quickshell Configuration
hl.window_rule({
    name = "Khal Configuration",
    match = { class="org.quickshell", title = "Khal Configuration" },
    float = true,
    center = true,
    size = "700 600"
})

hl.window_rule({
    name = "Add Calendar Event",
    match = { class="org.quickshell", title = "Add Event" },
    float = true,
    center = true,
    size = "700 600"
})

-- Picture-in-Picture
hl.window_rule({
    name = "Picture-in-Picture",
    match = {
        title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]]
    },
    float = true,
    pin = true,
    focus_on_activate = false,
    no_initial_focus = true,
    suppress_event = "activate"
})