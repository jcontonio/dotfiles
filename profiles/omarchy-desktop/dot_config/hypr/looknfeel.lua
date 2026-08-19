-- Change the default Omarchy look'n'feel.

-- 1. every new window opens floating at your size
-- hl.window_rule({
--  match = { class = ".*" },
--  float = true,
--  size = "1325 1000",
--  center = true,
-- })

-- 2. sizes you set by hand stick for the session
hl.window_rule({
	float = true,
	match = { class = ".*" },
	persistent_size = true,
})

-- 2b. Omarchy's default "floating-window" tag hardcodes size=875x600 for
-- 1Password (apps/1password.lua + apps/system.lua). That fixed size rule
-- always overwrites persistent_size on every open, so clear it here to let
-- persistent_size actually control 1Password's size. Must also match on
-- tag = "floating-window" (not just class) so this rule gets re-applied in
-- the same recheck pass that reapplies Omarchy's tag-matched size rule --
-- otherwise Omarchy's rule wins the race and this override is silently lost.
hl.window_rule({
	match = { tag = "floating-window", class = "^1[pP]assword$" },
	size = "",
})

-- open Steam's main window at a fixed size (already floats via rule above)
hl.window_rule({
	match = { class = "^steam$", title = "^Steam$" },
	size = "1600 1000",
	center = true,
})

-- 3. make all default floating windows taller (1Password, etc)
-- hl.window_rule({
-- match = { tag = "floating-window" },
-- size = "1325 1000",
-- })

-- 4. make sure chrome opens floating (overrides Omarchy's default tile=true for browsers)
hl.window_rule({
	match = { tag = "chromium-based-browser" },
	float = true,
})

-- 4b. force workspace 1 to tiled mode, overriding all the float rules above
-- (rules are evaluated top to bottom and the last match wins, so this must
-- stay below every other float=true rule to take precedence on workspace 1)
hl.window_rule({
	match = { workspace = "1" },
	tile = true,
})
-- hl.window_rule({
--  match = { tag = "chromium-based-browser" },
--  float = true,
--  size = "1325 1000",
--  center = true,
--})

-- 5. 1Password tiny frekaing window (covers the small SSH-auth popup too)
-- hl.window_rule({
--  match = { class = "^1[pP]assword$" },
--  no_max_size = true,
--  min_size = "1200 800",
-- })
--
-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
