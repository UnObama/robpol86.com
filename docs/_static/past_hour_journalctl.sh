#!/bin/bash

# Print filtered journalctl info and greater entries from the past hour.
# https://github.com/Robpol86/robpol86.com/blob/master/docs/_static/past_hour_journalctl.sh
# Save as (chmod +x): /usr/local/bin/past_hour_journalctl

set -e  # Exit script if a command fails.
set -u  # Treat unset variables as errors and exit immediately.
set -o pipefail  # Exit script if pipes fail instead of just the last program.

# Iterate journalctl lines.
journalctl -o json "$@" |while read -r line; do
    declare -A json  # Scoped in piped while loop.
    comm=
    json=()  # Clear array in case "shopt -s lastpipe" is set by the user.
    message=

    # Read JSON into bash associative array.
    while IFS="=" read -r key value; do
        if [ "$key" == "MESSAGE" ]; then
            message="$value"
        elif [ "$key" == "_COMM" ]; then
            comm="$value"
        else
            json["$key"]="$value"
        fi
    done < <(jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" <<< "$line")

    # Filter influxdb statements.
    if [ "${json['CONTAINER_NAME']:-}" == "influxdb" ] && [ "${message:0:3}" == "[I]" ]; then
        continue
    fi

    # Handle comm column.
    if [ -z "$comm" ]; then
        comm="${json['SYSLOG_IDENTIFIER']}"
    else
        comm+="[${json['_PID']}]"
    fi

    # Print.
    echo -n $(date -d @${json['__REALTIME_TIMESTAMP']:0:-6} '+%b %d %T')
    echo " ${json['_HOSTNAME']} $comm: $message"
done
