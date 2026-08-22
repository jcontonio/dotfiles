# NAS Access & Backups (UniFi UNAS Pro 4)

The home NAS is a Ubiquiti UNAS Pro 4. This doc covers how SMB access and
encrypted Kopia backups are set up, why it's built this way, and how to
onboard a new machine.

This repo is public — real IPs, hostnames, and internal NAS paths are
**not** included below. Substitute your own values wherever you see a
`<PLACEHOLDER>`. Keep the actual values (NAS IP, export paths, Kopia
repository password) in a private notes file or password manager, not in
this repo.

- [Background: why this is more complicated than it should be](#background-why-this-is-more-complicated-than-it-should-be)
- [Shares on the NAS](#shares-on-the-nas)
- [NAS-side one-time setup](#nas-side-one-time-setup)
- [Per-machine setup: SMB access (Personal-Drive)](#per-machine-setup-smb-access-personal-drive)
- [Per-machine setup: Kopia backups (Backups share, NFS)](#per-machine-setup-kopia-backups-backups-share-nfs)
- [Per-machine setup: Media (NFS, plain mount)](#per-machine-setup-media-nfs-plain-mount)
- [New machine checklist](#new-machine-checklist)
- [Troubleshooting](#troubleshooting)

---

## Background: why this is more complicated than it should be

The UNAS Pro 4's SMB implementation has a real, NAS-side bug: directory
listings (not file transfers — `tar` extraction over SMB is fast) can hang
or take tens of seconds. Reproduced across the Linux kernel `cifs.ko`
client, `smbnetfs`, GVFS/`gio mount`, and even macOS's own SMB client on
large directories. This is documented on Ubiquiti's community forums as a
known issue, not something specific to this machine.

NFS does not have this problem — directory listings are fast and reliable.
The catch: **UNAS Pro NFS only supports unencrypted Shared Drives.**
Personal Drives cannot be NFS-exported at all (not a toggle we're missing —
they simply don't appear as an option in the NAS's "Add NFS Connections"
UI), and encrypted drives aren't eligible either.

So the split is:

- **`Personal-Drive`** (encrypted, contains sensitive personal files) —
  stuck on SMB. Encryption is worth keeping given what's on it.
- **`Backups`** (deliberately unencrypted Shared Drive) — accessed over
  NFS, with Kopia providing client-side encryption instead. This sidesteps
  both the SMB bug and the need for NAS-level encryption on that share.

## Shares on the NAS

| Share | Encrypted | Protocol used | Purpose |
| --- | --- | --- | --- |
| `Personal-Drive` | Yes | SMB (GVFS) | Personal files |
| `Shared_Drive` | No | SMB or NFS | General shared files |
| `Backups` | No (Kopia encrypts instead) | NFS | Kopia repository, multi-machine |
| `Media` | No | NFS | Bulk media library, direct read/write access |

## NAS-side one-time setup

Already done; documented here for reference / disaster recovery.

1. **File Services → NFS**: enabled globally in NAS Settings.
2. **Add NFS Connections** (per share you want exported): add each client
   machine's **static/reserved IP** to the allowlist (hostname does not
   resolve — the NAS can't do reverse DNS for arbitrary LAN hostnames,
   only IPs work).
3. **Squash Mode**: set to **Collaborative** (maps all NFS clients to one
   shared identity server-side — avoids UID-mismatch permission errors).
4. **NFS Write Mode**: `sync` for integrity, `async` for speed. Currently
   using `sync` on `Backups`.
5. Only **Shared Drives** can be added under "Shared Drives Permissions" in
   the NFS connection dialog — Personal Drives are not eligible, encrypted
   or not.

Each machine needs its own entry in the NFS allowlist with its current
static IP. Whenever a new machine is added, go back into **Add NFS
Connections** on the NAS and add its IP.

## Per-machine setup: SMB access (Personal-Drive)

Standard `mount -t cifs` (the kernel client) reliably hangs against this
NAS — confirmed via packet capture, unrelated to firewall/MTU/ACL/mount
options. `smbnetfs` also doesn't work well (it does live network browsing
on every `stat()`, which fights with shell prompt integrations like
`mise`). The working approach is GVFS (`gio mount`), same backend Nautilus
uses, kept alive with a systemd timer so it doesn't depend on Nautilus
being open.

Replace `<NAS_IP>` below with your NAS's LAN IP.

**1. Mount via GVFS:**

```bash
gio mount smb://<NAS_IP>/personal-drive
gio mount smb://<NAS_IP>/shared_drive
```

Mounts appear at:

```
/run/user/$(id -u)/gvfs/smb-share:server=<NAS_IP>,share=personal-drive
/run/user/$(id -u)/gvfs/smb-share:server=<NAS_IP>,share=shared_drive
```

**2. Friendly symlinks:**

```bash
mkdir -p ~/.local/share/smb
ln -sfn "/run/user/$(id -u)/gvfs/smb-share:server=<NAS_IP>,share=personal-drive" ~/.local/share/smb/personal-drive
ln -sfn "/run/user/$(id -u)/gvfs/smb-share:server=<NAS_IP>,share=shared_drive" ~/.local/share/smb/shared-drive
```

**3. Keep-alive systemd user timer** (GVFS mounts can silently drop if
idle/unreferenced):

`~/.local/bin/smb-keepalive.sh`:

```bash
#!/usr/bin/env bash
set -u

NAS_IP="<NAS_IP>"

SHARES=(
  "smb://${NAS_IP}/personal-drive"
  "smb://${NAS_IP}/shared_drive"
)

for uri in "${SHARES[@]}"; do
  gio mount "$uri" >/dev/null 2>&1
done

for path in "/run/user/$(id -u)/gvfs/smb-share:server=${NAS_IP},share="*; do
  [ -d "$path" ] && ls "$path" >/dev/null 2>&1
done
```

`~/.config/systemd/user/smb-keepalive.service`:

```ini
[Unit]
Description=Mount and keep alive SMB shares (personal-drive, shared_drive)

[Service]
Type=oneshot
ExecStart=%h/.local/bin/smb-keepalive.sh
```

`~/.config/systemd/user/smb-keepalive.timer`:

```ini
[Unit]
Description=Periodically mount and keep alive SMB shares

[Timer]
OnBootSec=30s
OnUnitActiveSec=3min
Persistent=true

[Install]
WantedBy=timers.target
```

Enable:

```bash
chmod +x ~/.local/bin/smb-keepalive.sh
systemctl --user daemon-reload
systemctl --user enable --now smb-keepalive.timer
```

This is a plain oneshot service, not a sleep inhibitor — it has no effect
on suspend.

**Expect occasional slowness.** Large directory listings can still take
several seconds to ~30s due to the NAS-side bug. The timer only fixes
*dropped* connections, not *slow-but-alive* ones — that part isn't fixable
client-side.

## Per-machine setup: Kopia backups (Backups share, NFS)

Replace `<NAS_IP>` and `<NFS_EXPORT_PATH>` below with your actual values
(get the export path from `showmount -e <NAS_IP>` once your machine's IP
is in the NAS's NFS allowlist).

**1. Static IP.** Set a DHCP reservation for the machine in the UniFi
Network app (Clients → select device → Settings → "Use Fixed IP Address").
Add that IP to the NAS's NFS allowlist for the `Backups` share (see
[NAS-side setup](#nas-side-one-time-setup)).

**2. Mount via NFS**, persisted in `/etc/fstab`:

```
<NAS_IP>:<NFS_EXPORT_PATH> /mnt/backups nfs vers=3,_netdev,x-systemd.automount,noauto 0 0
```

```bash
sudo mkdir -p /mnt/backups
sudo chown $USER:$USER /mnt/backups
echo '<NAS_IP>:<NFS_EXPORT_PATH> /mnt/backups nfs vers=3,_netdev,x-systemd.automount,noauto 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
ls /mnt/backups  # triggers automount
```

**3. Install Kopia** (AUR): `kopia-bin` (precompiled, CLI only — no need
for `kopia-ui-bin` for a headless scheduled setup).

**4. Connect to the existing repository** — the repository was created
once (`kopia repository create filesystem --path=/mnt/backups`) and is
shared across all machines for cross-host deduplication. New machines
**connect**, they don't create:

```bash
kopia repository connect filesystem --path=/mnt/backups
```

It'll prompt for the repository password — get this from the password
manager entry, never from this repo. It is not stored anywhere in this
dotfiles repo.

**5. Set a per-host policy** (adjust the source path/exclusions per
machine — this example matches a typical dev-machine home directory
policy, reuse or tweak as needed):

```bash
kopia policy set /home/<user> \
  --add-ignore ".cache/**" \
  --add-ignore ".local/share/mise/installs/**" \
  --add-ignore ".local/share/Trash/**" \
  --add-ignore "**/node_modules/**" \
  --add-ignore "**/.venv/**" \
  --add-ignore "**/venv/**" \
  --add-ignore "**/__pycache__/**" \
  --add-ignore "**/target/**" \
  --add-ignore "**/dist/**" \
  --add-ignore "**/build/**" \
  --add-ignore ".npm/**" \
  --add-ignore ".cargo/registry/**" \
  --add-ignore ".rustup/**" \
  --add-ignore "go/pkg/mod/**" \
  --add-ignore ".docker/**" \
  --compression=zstd \
  --keep-latest 10 \
  --keep-hourly 24 \
  --keep-daily 14 \
  --keep-weekly 8 \
  --keep-monthly 6 \
  --keep-annual 0
```

**6. First snapshot (manual, sanity check):**

```bash
kopia snapshot create /home/<user>
kopia snapshot list /home/<user>
```

**7. Automate with a systemd user timer:**

`~/.local/bin/kopia-snapshot.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ls /mnt/backups >/dev/null

kopia snapshot create /home/<user>
kopia maintenance run
```

`~/.config/systemd/user/kopia-snapshot.service`:

```ini
[Unit]
Description=Kopia snapshot of home directory to NAS backups share
After=network-online.target

[Service]
Type=oneshot
ExecStart=%h/.local/bin/kopia-snapshot.sh
```

`~/.config/systemd/user/kopia-snapshot.timer`:

```ini
[Unit]
Description=Hourly Kopia snapshot of home directory

[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
```

Enable:

```bash
chmod +x ~/.local/bin/kopia-snapshot.sh
systemctl --user daemon-reload
systemctl --user enable --now kopia-snapshot.timer
```

`Persistent=true` means a missed run (machine asleep/off) fires as soon as
it's back. Neither this nor the SMB keepalive timer holds a suspend
inhibitor — verify with `systemd-inhibit --list` if ever in doubt.

## Per-machine setup: Media (NFS, plain mount)

Same idea as `Backups` — a Shared Drive, exported over NFS, mounted on
demand — but with no Kopia layer on top; it's just a plain NFS mount for
direct read/write access (e.g. a media library).

Replace `<NAS_IP>` and `<NFS_EXPORT_PATH>` below with your actual values
(get the export path from `showmount -e <NAS_IP>` once your machine's IP
is in the NAS's NFS allowlist for `Media`).

```bash
sudo mkdir -p /mnt/media
echo '<NAS_IP>:<NFS_EXPORT_PATH> /mnt/media nfs vers=3,_netdev,x-systemd.automount,noauto 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo systemctl start mnt-media.automount
ls /mnt/media  # triggers the automount on first access
```

No keepalive timer needed — `x-systemd.automount` handles mount-on-access
and stays out of the way (no boot delay) the same way `/mnt/backups` does.

Requires the machine's static IP to already be in the NAS's NFS allowlist
for `Media` (see [NAS-side setup](#nas-side-one-time-setup) — same process,
just add the IP under the `Media` share's "Add NFS Connections" instead of
`Backups`).

## New machine checklist

Onboarding a new machine for backups:

1. Set a DHCP reservation for it in the UniFi Network app.
2. Add its static IP to the NAS's NFS allowlist for `Backups`.
3. Install `kopia-bin`.
4. Add the `/mnt/backups` fstab entry, mount it.
5. `kopia repository connect filesystem --path=/mnt/backups` (password
   from the password manager).
6. `kopia policy set /home/<user> ...` — copy the policy above, adjust
   exclusions for what's actually on that machine.
7. Manual first snapshot to sanity check.
8. Set up `kopia-snapshot.sh` + the service/timer, enable it.

For SMB access to `Personal-Drive`/`Shared_Drive` on a new machine, repeat
the [SMB access setup](#per-machine-setup-smb-access-personal-drive)
section — GVFS mount, symlinks, keepalive timer.

## Troubleshooting

- **`ls` hangs on a Personal-Drive/Shared_Drive SMB path** — known NAS-side
  bug, not fixable client-side. Check `systemctl --user status
  smb-keepalive.timer` to confirm the mount itself hasn't dropped; if it's
  mounted but slow, just wait it out or retry.
- **`showmount -e <NAS_IP>` returns nothing** for a share you expect — the
  requesting machine's IP isn't in that share's NFS allowlist yet, or its
  IP changed (DHCP reservation not actually applied/renewed).
- **NFS mount permission errors** — check Squash Mode is Collaborative on
  the NAS side for that share.
- **`kopia repository connect` fails** — confirm `/mnt/backups` is
  actually mounted (`mountpoint -q /mnt/backups`) before connecting.
- **`kopia` commands fail with `BLOB not found` / "unable to read format
  blob"** — this almost always means `/mnt/backups` isn't actually mounted
  (Kopia is reading an empty local directory, not a corrupted repository).
  Check with `mountpoint -q /mnt/backups`. The data itself lives on the
  NAS and isn't affected by the client-side mount dropping.
- **The NFS automount unit (`mnt-<path>.automount`) goes fully inactive**
  (not just idle-unmounted — the watcher itself stops). Observed once,
  cause unconfirmed. Recover with:
  ```bash
  sudo systemctl daemon-reload
  sudo systemctl restart mnt-backups.automount
  ```
  If this recurs, consider folding the NFS mount into a keepalive systemd
  timer (same pattern as `smb-keepalive.timer` above) so it self-heals
  instead of silently going dark.
