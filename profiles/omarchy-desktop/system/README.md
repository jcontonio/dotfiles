# Anker PowerConf C200 camera settings

The C200 does not persist its settings across power cycles — every time it re-enumerates
it comes back at factory defaults. This setup reapplies a saved profile automatically
whenever the camera is plugged in.

## How it works

```
camera plugged in
  └─ udev  /etc/udev/rules.d/99-anker-c200.rules       matches 291a:3369, index 0
      └─ systemd  /etc/systemd/system/anker-c200.service   oneshot, 2s settle delay
          └─ ~/.config/anker/c200-settings.sh              writes each control
              └─ /usr/local/bin/anker-powerconf-c200-linux-tools
```

Only the settings script is managed by chezmoi (it lives in `dot_config/anker/`, applied to
`~/.config/anker/`). The udev rule and service unit live here in `system/`, which the
profile's `.chezmoiignore` excludes from `chezmoi apply` — they are root-owned files
outside `$HOME`, so they are installed explicitly via `install.sh`.

## Prerequisites

The CLI is not packaged; build it from source:

```bash
git clone https://github.com/erans/anker-powerconf-c200-linux-tools
cd anker-powerconf-c200-linux-tools
make
sudo install -m 0755 build/anker-powerconf-c200-linux-tools /usr/local/bin/
```

## Install

```bash
chezmoi apply                                    # places ~/.config/anker/c200-settings.sh
./profiles/omarchy-desktop/system/install.sh     # places the rule + unit, reloads both
```

`install.sh` substitutes the absolute path to the settings script into the unit at install
time, so the same source works for any user or machine.

Verify:

```bash
sudo systemctl start anker-c200.service
systemctl status anker-c200.service
```

## Changing the settings

Tune the camera live until it looks right, then read the values back and update the script:

```bash
for c in fov hdr zoom_absolute pan_absolute tilt_absolute brightness sharpness \
         contrast saturation hue gamma power_line_frequency auto_exposure \
         exposure_time_absolute; do
  printf '%-24s ' "$c"
  anker-powerconf-c200-linux-tools --device /dev/video0 get "$c"
done
```

Then edit via chezmoi so the change is tracked:

```bash
chezmoi edit ~/.config/anker/c200-settings.sh
chezmoi apply
```

Editing `~/.config/anker/c200-settings.sh` directly works too — follow it with
`chezmoi re-add ~/.config/anker/c200-settings.sh`.

`v4l2-ctl -d /dev/video0 -L` lists every control with its min/max/default, which is the
quickest way to see what has drifted from factory.

## Notes

- **Device resolution.** The script resolves the camera through
  `/dev/v4l/by-id/usb-Anker_PowerConf_C200_*-video-index0` rather than `/dev/video0`, since
  node numbering depends on probe order and any other camera can take `video0`. The glob
  omits the serial, so it matches any C200. `index1` is the metadata node and cannot take
  control writes.
- **Control ordering.** `auto_exposure 1` (manual) must be written before
  `exposure_time_absolute`; the exposure control is inactive while auto exposure is on.
  The script writes controls in listed order for this reason.
- **Two controls are deliberately unset.** `white_balance_temperature` and `focus_absolute`
  are `inactive` while auto white balance and continuous autofocus are enabled, and read
  back junk values (WB temp reports 168, below its own 2300 minimum). Setting either
  requires first disabling the corresponding auto mode.
- **The 2s `ExecStartPre` delay** is load-bearing: the camera enumerates before its control
  interface is ready, and writes issued immediately after `add` are silently dropped.
