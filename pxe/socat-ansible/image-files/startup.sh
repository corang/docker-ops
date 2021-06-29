#!/bin/bash

# Check for ENC_KEY existence
[ -z "${SSH_PASSWORD}" ] && echo "The SSH_PASSWORD variable must be set." && exit 1

# Start socat runner on port 54321
socat -u tcp-l:54321,fork system:/scripts/socat-provision.sh