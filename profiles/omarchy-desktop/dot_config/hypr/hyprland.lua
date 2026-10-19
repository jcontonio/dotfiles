-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Save screen recordings in ~/Videos/Screencasts instead of ~/Videos.
hl.env("OMARCHY_SCREENRECORD_DIR", os.getenv("HOME") .. "/Videos/Screencasts")

-- Save screenshots in ~/Pictures/Screenshots instead of ~/Pictures.
hl.env("OMARCHY_SCREENSHOT_DIR", os.getenv("HOME") .. "/Pictures/Screenshots")

-- World of Warcraft: always fullscreen, ignore the game's requests to leave
-- fullscreen, keep it fully opaque, and don't let the screen idle while playing.
o.window({ title = "^World of Warcraft$" }, {
  fullscreen = true,
  suppress_event = "fullscreen maximize",
  tag = "-default-opacity",
  opacity = "1 1",
  idle_inhibit = "fullscreen",
})

-- Tag games so SUPER+W won't close them (see hypr/bindings.lua). Covers
-- Proton/Steam games (incl. Battle.net + WoW) and anything run in gamescope.
o.window("^(steam_app_.*|gamescope)$", { tag = "+game" })
o.window({ title = "^World of Warcraft$" }, { tag = "+game" })

-- Personal Ghostty has its own class (so link-router can spot it), which the
-- default terminal rule doesn't match. Tag it so terminal bindings and theme
-- rules still apply.
o.window("com.mitchellh.ghostty-personal", { tag = "+terminal" })
