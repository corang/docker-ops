#!/bin/bash

# Safer bash script
set -euxo pipefail

# Read safe version of script into variable
SAFE_SCRIPT=$(<socat-provision.enc.sh)

# Read encrypted password into variable
ENC_PASSWORD=$(<password.enc)

# ENC_KEY is read from environment variable from docker scriptset

# Decrypt password and store it
DEC_PASSWORD=$(echo "${ENC_PASSWORD}" | openssl aes-256-cbc -pbkdf2 -iter 100000 -d -a -pass pass:${ENC_KEY})

# Replace occurences of {{ password }} with decrypted password and write to file
sed -e "s/{{ password }}/${DEC_PASSWORD}/g" ./socat-provision.enc.sh > ./socat-provision.dec.sh