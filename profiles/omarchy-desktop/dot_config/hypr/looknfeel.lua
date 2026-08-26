-- Personal overrides on top of Omarchy's defaults.
--
-- Window rules are evaluated top to bottom and the LAST match wins, so the
-- order of everything below is load-bearing. Omarchy's own rules
-- (/usr/share/omarchy/default/hypr/apps/*.lua) all run before this file.

-- 1. Float every window by default, and remember sizes set by hand.
--
--    persistent_size only restores a size when a new window has the same
--    class AND title as the one that was resized. That works for apps with a
--    stable title, but never for browsers -- their title is the page title,
--    so every window is a "new" one and it opens at whatever size the app
--    asks for. Those apps need an explicit size rule instead (section 2).
hl.window_rule({
	match = { class = ".*" },
	float = true,
	persistent_size = true,
})

-- 2. Explicit open sizes for apps persistent_size can't help.

-- Chromium: also overrides Omarchy's tile = true for chromium-based browsers.
hl.window_rule({
	match = { tag = "chromium-based-browser" },
	float = true,
	size = { 1850, 1400 },
	center = true,
})

-- Firefox: without this it opens at whatever geometry it saved in its own
-- session store, which is where the squashed window after a reboot came from.
hl.window_rule({
	match = { tag = "firefox-based-browser" },
	size = { 1850, 1400 },
	center = true,
})

hl.window_rule({
	match = { class = "^steam$", title = "^Steam$" },
	size = { 1600, 1000 },
	center = true,
})

-- 3. Restore Omarchy's picture-in-picture geometry. PiP windows are chromium
--    windows, so the browser rules above match them too and would blow their
--    size up to a full browser window.
hl.window_rule({
	match = { tag = "pip" },
	size = { 600, 338 },
	move = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

-- Google Meet's PiP is titled with the meeting name rather than
-- "Picture-in-Picture", so Omarchy matches it separately -- and so must this.
hl.window_rule({
	match = { tag = "chromium-based-browser", title = "^Meet - .+" },
	size = { 600, 338 },
	move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})

-- 4. Omarchy's "floating-window" tag hardcodes size 875x600 (see
--    default/hypr/apps/system.lua), which overwrites persistent_size on every
--    1Password open. Clearing the size lets persistent_size take over. This
--    must also match on tag = "floating-window", not just class, so it is
--    re-applied in the same recheck pass as Omarchy's tag-matched size rule --
--    otherwise Omarchy's rule wins the race and this override is lost.
hl.window_rule({
	match = { tag = "floating-window", class = "^1[pP]assword$" },
	size = "",
})

-- 5. Workspace 1 stays tiled. Keep this below every float rule above so it
--    takes precedence there.
hl.window_rule({
	match = { workspace = "1" },
	tile = true,
})
