Password is encrypted via `echo "password to be encrypted" | openssl aes-256-cbc -pbkdf2 -iter 100000 -a -salt -pass pass:password for encryption`

Password is decrypted via `echo "encrypted string to be decrypted" | openssl aes-256-cbc -pbkdf2 -iter 100000 -d -a -pass pass:password for decryption`