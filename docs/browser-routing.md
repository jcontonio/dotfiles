# Browser Routing (Personal vs. Work)

On the Omarchy desktop, personal links open in Firefox and everything else
opens in Chromium, the default (work) browser. The point is to stop auth
flows (Claude, Railway, GitHub) and links clicked in personal apps from
landing in the wrong browser.

- [What goes where](#what-goes-where)
- [How it works](#how-it-works)
- [Files](#files)
- [Personal Ghostty](#personal-ghostty)
- [Personal herdr session](#personal-herdr-session)
- [New machine setup](#new-machine-setup)
- [Limitations](#limitations)
- [Common changes](#common-changes)
- [Troubleshooting](#troubleshooting)

---

## What goes where

A link opens in **Firefox** when any of these is true:

| Rule | Covers |
| --- | --- |
| URL is under `github.com/jcontonio` or `github.com/GETSET-FM` (case-insensitive) | Personal repos, clicked from anywhere |
| The focused window is Fastmail (`com.fastmail.Fastmail`) | Links clicked in email |
| The focused window is Personal Ghostty (`com.mitchellh.ghostty-personal`) | Links clicked in that terminal, including the personal herdr session |
| `BROWSER_PROFILE=personal` is set in the environment | URLs opened by CLI tools: `claude-personal`, and anything run in Personal Ghostty or the personal herdr session |

Everything else opens in **Chromium**, through Omarchy's normal
`omarchy-launch-browser` (which hands the link to the running browser and
focuses it). That includes the normal terminal (`SUPER + RETURN`), the
default herdr session (`SUPER + CTRL + RETURN`), `claude-work`, and Omarchy
web apps.

Entry points at a glance:

| Keys / command | Profile |
| --- | --- |
| `SUPER + RETURN` | Work terminal |
| `SUPER + SHIFT + P` | Personal terminal |
| `SUPER + CTRL + RETURN` | Work herdr session (`default`) |
| `SUPER + CTRL + SHIFT + P` | Personal herdr session (`personal`) |
| `claude-work` | Work Claude account (`~/.claude-work`), auth in Chromium |
| `claude-personal` | Personal Claude account (`~/.claude`), auth in Firefox |

## How it works

Omarchy sends every link, from `xdg-open` and from the desktop portal,
through one desktop entry, `omarchy-browser.desktop`, listed in
`~/.config/hyprland-mimeapps.list`. That entry's `Exec` is changed from
`omarchy-launch-browser` to `link-router`, which applies the rules above.

```
app / CLI ──► xdg-open or portal ──► omarchy-browser.desktop ──► link-router
                                                                   ├─► firefox                (personal)
                                                                   └─► omarchy-launch-browser (work → Chromium)
```

CLI tools that read `$BROWSER` (`gh`, Rust and Python tools) skip `xdg-open`,
so `~/.bashrc` sets `BROWSER=link-router` too. It's set after Omarchy's
`default/bash/rc`, which would otherwise set it to `omarchy-launch-browser`.

The router checks its rules in this order: `BROWSER_PROFILE`, then the URL,
then the focused window (`hyprctl activewindow`). Firefox is launched
detached through `systemd-run` and `uwsm-app`, the same way Omarchy launches
browsers, then focused.

**Why the router checks the focused window:** Ghostty runs `xdg-open` for a
clicked link from its own process, and its `env` setting is *not* passed to
it (per Ghostty's docs). A Personal terminal's environment never reaches the
router for clicks, so the router identifies the window instead. Fastmail is
handled the same way, which also works when an app uses the desktop portal
and its environment is lost.

**Why the router isn't a new handler in `hyprland-mimeapps.list`:**
`omarchy-cmd-default-browser` reads that list to find the real browser,
skipping only `omarchy-browser.desktop`. A new entry there would be treated
as the default browser, and the router's fallback to
`omarchy-launch-browser` would call the router again in a loop. Editing
`omarchy-browser.desktop` keeps Chromium as the default for web apps and
Omarchy's browser settings. `~/.config/mimeapps.list` still lists
`chromium.desktop` as the http/https default and is not changed.

## Files

All tracked in `profiles/omarchy-desktop` (desktop only; the laptop profile
doesn't have this):

| File | Purpose |
| --- | --- |
| `~/.local/bin/link-router` | The routing rules |
| `~/.local/share/applications/omarchy-browser.desktop` | Omarchy's link handler, `Exec` changed to `link-router %U`. Omarchy owns this file and a migration can overwrite it. |
| `~/.bashrc` | `export BROWSER=link-router`; `claude-personal` alias sets `BROWSER_PROFILE=personal` |
| `~/.local/bin/ghostty-personal` | Launches Personal Ghostty (all its flags live here) |
| `~/.local/share/applications/ghostty-personal.desktop` | "Ghostty (Personal)" in the app launcher |
| `~/.config/hypr/bindings.lua` | `SUPER + SHIFT + P` → Personal Ghostty; `SUPER + CTRL + SHIFT + P` → personal herdr session |
| `~/.config/hypr/hyprland.lua` | Tags the Personal Ghostty class as a terminal |
| `~/.config/omarchy/hooks/theme-set.d/ghostty-personal-tint` | Regenerates the Personal tint on theme change |

`~/.config/ghostty/personal.conf` is generated by the tint hook and is not
tracked.

## Personal Ghostty

`SUPER + SHIFT + P` (or "Ghostty (Personal)" in the launcher) runs
`ghostty-personal`, which opens a Ghostty window that differs from the normal
one (`SUPER + RETURN`) in three ways:

- **Its own window class**, `com.mitchellh.ghostty-personal`
  (`--class`), so the router can recognise it. A different class also makes
  it a separate Ghostty instance from the normal one.
- **`BROWSER_PROFILE=personal`** in its shells (`--env`), so `claude`,
  `gh auth login`, `railway login` and the like open Firefox.
- **A tinted background** from `--config-file=?~/.config/ghostty/personal.conf`
  (the `?` means a missing file isn't an error). The tint hook writes the
  current theme's background with 6% of the theme's magenta (palette 5) mixed
  in, then sends `SIGUSR2` so open Ghostty windows reload. Omarchy runs the
  hook after every theme change, so the tint follows the theme. On
  Catppuccin it's `#2a2739` against the normal `#1e1e2e`. (12% was too
  purple to read comfortably.)

Omarchy's terminal rule (`default/hypr/apps/terminals.lua`) matches
Ghostty's class exactly, so `hyprland.lua` adds a rule giving the Personal
class the `terminal` tag. Without it, the Personal window would lose the
terminal clipboard shortcuts and theme rules.

## Personal herdr session

`SUPER + CTRL + SHIFT + P` runs `ghostty-personal -e herdr --session personal`:
a herdr session named `personal`, attached inside Personal Ghostty.
`SUPER + CTRL + RETURN` is still Omarchy's binding for the `default` session
in a normal terminal, which is the work session.

Each named herdr session runs its own server, and the panes get their
environment from the client that first started that server. Started by the
keybinding, the `personal` server inherits `BROWSER_PROFILE=personal`, so
every pane routes to Firefox. Clicked links work because the session is in a
Personal Ghostty window.

**Catch:** if the `personal` session is ever started some other way (for
example `herdr session attach personal` from a work terminal while it's
stopped), its panes won't have `BROWSER_PROFILE`. Fix it with
`herdr session stop personal`, then reopen it with the keybinding. The same
applies the other way: don't start `default` from Personal Ghostty.

## New machine setup

Needs Firefox and Chromium installed, with Chromium as the default browser
(Omarchy's default).

1. `chezmoi apply`. chezmoi sets the scripts' executable bits (`executable_`
   prefix in the source).
2. Generate the tint once, since the hook only runs on theme changes:
   ```bash
   ~/.config/omarchy/hooks/theme-set.d/ghostty-personal-tint
   ```
3. Open a new terminal so `.bashrc` takes effect, then run the checks under
   [Troubleshooting](#troubleshooting).

Hyprland reloads its config on save; run `hyprctl configerrors` to confirm
the bindings loaded.

## Limitations

- **Links clicked inside a browser stay in that browser.** The router only
  sees links that other apps hand off. A personal GitHub link clicked in
  Chromium opens in Chromium.
- **"Focused window" means focused when the link opens.** If a background
  app opens a URL, the router judges it by whatever window has focus at that
  moment. Clicks are always in the focused window, so this only matters for
  apps opening links on their own.
- **Environment only flows to child processes.** `BROWSER_PROFILE` reaches
  CLIs run from a personal shell, but not apps launched outside it.
- **GitHub matching is by owner only**, at the start of the path:
  `github.com/jcontonio/...` matches; `gist.github.com` and other GitHub
  hosts don't.

## Common changes

**Add a personal GitHub owner:** edit `personal_github` in `link-router`
(`|`-separated).

**Add a personal app:** find its class with `hyprctl activewindow` while it's
focused, then add it to `personal_classes` in `link-router`.

**Change the tint:** edit `strength` (percent) or the `palette = 5` color
number in the tint hook (3 is the theme's yellow/orange), then run it:
`~/.config/omarchy/hooks/theme-set.d/ghostty-personal-tint`.

After any of these, `chezmoi re-add` to save the change.

## Troubleshooting

**Every link opens in Chromium again.** An `omarchy update` migration
probably replaced `omarchy-browser.desktop`. Check with:

```bash
grep ^Exec ~/.local/share/applications/omarchy-browser.desktop
```

If it says `omarchy-launch-browser`, run `chezmoi apply` to restore it.

**A CLI tool opens the wrong browser.** Check that `echo $BROWSER` prints
`link-router` (and `echo $BROWSER_PROFILE` prints `personal` in personal
shells), then test the rules directly:

```bash
link-router https://github.com/jcontonio                   # Firefox
BROWSER_PROFILE=personal link-router https://example.com   # Firefox
link-router https://example.com                            # Chromium
```

**A herdr pane opens the wrong browser.** Check `echo $BROWSER_PROFILE` in
the pane. If it's empty in the personal session, the server was started from
outside Personal Ghostty; see [the catch above](#personal-herdr-session).

**Personal Ghostty has no tint.** Run the tint hook once to generate
`personal.conf`. Windows opened with older launch flags keep their old
config, so close them and reopen.
