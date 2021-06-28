#!/bin/bash

# Check for ENC_KEY existence
[ -z "$ENC_KEY" ] && echo "The ENC_KEY variable must be set." && exit 1

# Check that encryption key is correct
if [ ! cat /scripts/password.enc | openssl aes-256-cbc -pbkdf2 -iter 100000 -d -a -pass pass:${ENC_KEY} ]; then
  echo "ENC_KEY is incorrect."
fi

