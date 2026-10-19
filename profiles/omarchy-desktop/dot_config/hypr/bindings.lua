-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Remove the HEY web app bindings (not used).
hl.unbind("SUPER + SHIFT + E") -- was: Email (https://app.hey.com)
hl.unbind("SUPER + SHIFT + ALT + E") -- was: New email (https://app.hey.com)
hl.unbind("SUPER + SHIFT + C") -- was: Calendar (https://app.hey.com/calendar)

-- Remove the remaining default web app bindings (not used).
hl.unbind("SUPER + SHIFT + A") -- was: ChatGPT
hl.unbind("SUPER + SHIFT + ALT + A") -- was: Grok
hl.unbind("SUPER + SHIFT + Y") -- was: YouTube
hl.unbind("SUPER + SHIFT + ALT + G") -- was: WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G") -- was: Google Messages
hl.unbind("SUPER + SHIFT + P") -- was: Google Photos
hl.unbind("SUPER + SHIFT + S") -- was: Google Maps
hl.unbind("SUPER + SHIFT + X") -- was: X
hl.unbind("SUPER + SHIFT + ALT + X") -- was: X Post

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
o.bind("SUPER + SHIFT + E", "Email", "omarchy-launch-or-focus com.fastmail.Fastmail fastmail")
o.bind("SUPER + SHIFT + ALT + E", "Email compose", 'fastmail "mailto:"')

-- Personal terminal: links clicked in it, and URLs opened by commands run in
-- it, go to Firefox (see ~/.local/bin/link-router).
o.bind("SUPER + SHIFT + P", "Personal terminal", "uwsm-app -- ghostty-personal")

-- Personal herdr session, attached in Personal Ghostty. Its server inherits
-- BROWSER_PROFILE=personal from the first client, so every pane routes to
-- Firefox. SUPER+CTRL+RETURN stays the default (work) session.
o.bind("SUPER + CTRL + SHIFT + P", "Personal herdr", "uwsm-app -- ghostty-personal -e herdr --session personal")

-- SUPER+W closes the window, except games (tagged "game" in hypr/hyprland.lua),
-- so a stray SUPER+W can't kill a game. Dynamic tags carry a trailing "*".
local function active_window_is_game()
  local window = hl.get_active_window()
  for _, tag in ipairs((window and window.tags) or {}) do
    if tag:gsub("%*$", "") == "game" then
      return true
    end
  end
  return false
end

hl.unbind("SUPER + W") -- was: Close window
o.bind("SUPER + W", "Close window (not games)", function()
  if not active_window_is_game() then
    hl.dispatch(hl.dsp.window.close())
  end
end)
