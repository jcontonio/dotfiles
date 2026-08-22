#!/bin/sh
# Apply preferred Anker PowerConf C200 settings.
# Invoked by anker-c200.service, which is triggered by udev when the camera appears.
set -e

TOOL=/usr/local/bin/anker-powerconf-c200-linux-tools

# Resolve the camera by name rather than trusting /dev/video0, which depends on
# probe order. index0 is the capture node; index1 is metadata. The glob skips the
# serial number so this works with any C200, not just the one it was written on.
DEV=""
for link in /dev/v4l/by-id/usb-Anker_PowerConf_C200_*-video-index0; do
	[ -e "$link" ] || continue
	DEV="$link"
	break
done

if [ -z "$DEV" ]; then
	echo "anker-c200: no PowerConf C200 capture device found" >&2
	exit 1
fi

set -- \
	fov 78 \
	hdr on \
	zoom_absolute 175 \
	pan_absolute 10800 \
	tilt_absolute -10800 \
	brightness 35 \
	sharpness 50 \
	contrast 30 \
	saturation 44 \
	hue 0 \
	gamma 380 \
	power_line_frequency 2 \
	auto_exposure 1 \
	exposure_time_absolute 156

# auto_exposure must land before exposure_time_absolute: the exposure control is
# inactive until the camera is in manual mode.
while [ "$#" -gt 0 ]; do
	"$TOOL" --device "$DEV" set "$1" "$2"
	shift 2
done
