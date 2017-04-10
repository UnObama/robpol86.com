#!/bin/bash

# Print filtered journalctl info and greater entries from the past hour.
# https://github.com/Robpol86/robpol86.com/blob/master/docs/_static/past_hour_journalctl.sh
# Save as (chmod +x): /usr/local/bin/past_hour_journalctl

set -e  # Exit script if a command fails.
set -u  # Treat unset variables as errors and exit immediately.
set -o pipefail  # Exit script if pipes fail instead of just the last program.

declare -A json

# Iterate journalctl lines.
journalctl --since="1 hour ago" --priority=info -o json |while read -r line; do
    # Read JSON into bash associative array.
    json=()
    (jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" <<< "$line") |while IFS="=" read -r key value; do
        json["$key"]="$value"
    done

    # Print.
    output=${json["__REALTIME_TIMESTAMP"]}
    output+=""
    echo "$output"
done
