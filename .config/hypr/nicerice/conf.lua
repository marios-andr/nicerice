require("nicerice.autostart")
require("nicerice.input")
require("nicerice.window-rules")

-------------------
-- CONFIGURATION --
-------------------


-----------------------------
-- Animation Master Switch --
-----------------------------
hl.config({
    animations = {
        enabled = true,
    }
})

require("nicerice.animations-end4")

primary = "rgba(a5c8ffff)"
on_primary = "rgba(00315eff)"

hl.config({
    -------------
    -- WINDOWS --
    -------------
    general = {
        gaps_in  = 2,
        gaps_out = 0,
        border_size = 1,
        col = {
            active_border   = { colors = {primary, on_primary}, angle = 90 },
            inactive_border = on_primary,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    ------------
    -- LAYOUT --
    ------------
    dwindle = {
        preserve_split = true,
    },
    
    master = {
        -- new_status = "master" -- Commented out due to compatibility reasons
    },

    binds = {
        workspace_back_and_forth = false,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },

    ----------------
    -- DECORATION --
    ----------------
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        fullscreen_opacity = 1.0,
        rounding_power = 2,

        shadow = {
            enabled = true,
            range = 32,
            render_power = 2,
            color = "rgba(00000050)",
        },

        blur = {
            enabled   = true,
            size      = 4,
            passes    = 4,
            new_optimizations = on,
            ignore_opacity = true,
            xray = true,
            vibrancy  = 0.1696,
        },
    },

    ----------
    -- MISC --
    ----------
    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
        disable_splash_rendering = true,
        initial_workspace_tracking = 1,
        on_focus_under_fullscreen = 1,
        allow_session_lock_restore = true
    },
})

-- Wayland variables
hl.env("OZONE_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("DESKTOP_SESSION", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Qt related environment variables
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- GDK
hl.env("GDK_SCALE", "1")

-- Toolkit Backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")

-- Mozilla
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Set the cursor size for xcursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- SDL version
hl.env("SDL_VIDEODRIVER", "wayland")

-- Quickshell debug
hl.env("QS_NO_RELOAD_POPUP", "1")

-- fcitx (Input Method Editor)
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")

-- Force zero scaling for XWayland
hl.config({
  xwayland = {
    force_zero_scaling = true
  }
})