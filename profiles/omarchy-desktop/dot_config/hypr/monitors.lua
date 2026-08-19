-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
-- bitdepth = 10 enables the 10-bit signal HDR needs. cm stays pinned to
-- "srgb" (not "auto") so the desktop keeps normal colors -- at 10bpc, "auto"
-- resolves to "wide" gamut full-time, which washes out SDR content. Hyprland's
-- render:cm_auto_hdr (on by default) still auto-switches to real HDR when a
-- fullscreen app (e.g. a game) requests it, independent of this baseline.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale, bitdepth = 10, cm = "srgb" })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
