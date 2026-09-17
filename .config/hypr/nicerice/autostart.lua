hl.on("hyprland.start", function ()

    -- Export variables to systemd
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Restart portals so they catch the environment
    hl.exec_cmd("systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland xdg-desktop-portal")

    -- awww daemon
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww img /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/pixel_sakura.gif")

    -- Listener scripts
    hl.exec_cmd("~/.config/nicerice/scripts/nicerice-wallpaper-pause.sh")
    hl.exec_cmd("~/.config/nicerice/scripts/nicerice-battery-warn.sh")

    -- Load cursor
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")

    -- Start polkit daemon
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Start QuickShell
    hl.exec_cmd("qs")

    -- Load GTK settings
    hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")

    -- Start hypridle
    hl.exec_cmd("hypridle")

    -- Start fcitx
    hl.exec_cmd("fcitx5 -d")

    -- Load cliphist history
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
