-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Steam's UI is CEF, which has no Wayland backend -- it runs on XWayland, where
-- the only DPI signal is Xft.dpi on the X root window. Hyprland doesn't set one,
-- so Steam renders at 96dpi/1x (tiny on this 4K panel). Native Wayland clients
-- (Chromium et al) read wl_output scale instead and are unaffected by this.
-- 192 = 96 * 2. Steam multiplies this by its own stored DesktopUIScale (0.7 in
-- config.vdf), landing at ~1.4 effective -- what GDK_SCALE=2 used to give it.
-- Deliberately NOT monitor_scale/GDK_SCALE, which would scale every Wayland
-- client too. Retries because XWayland may not be up yet at hyprland.start.
o.exec_on_start(
  [[sh -c 'for i in 1 2 3 4 5 6 7 8 9 10; do ]]
    .. [[xprop -root -f RESOURCE_MANAGER 8s -set RESOURCE_MANAGER "Xft.dpi:	192" ]]
    .. [[2>/dev/null && exit 0; sleep 1; done']]
)
