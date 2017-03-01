#!/bin/bash

# Show Btrfs estimated free space.
#
# https://github.com/Robpol86/robpol86.com/blob/master/docs/_static/dfree_btrfs.sh
#
# Samba by default uses "df" to get free space of a volume. However with Btrfs
# that value isn't what the user may expect. Running "btrfs fi usage" instead.
# Save as (chmod +x): /usr/local/bin/dfree_btrfs

set -e  # Exit script if a command fails.
set -u  # Treat unset variables as errors and exit immediately.
set -o pipefail  # Exit script if pipes fail instead of just the last program.

# TODO
df $1 | tail -1 | awk '{print $2" "$4}'
