#!/bin/bash
for arg in "$@"
do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ] || [ "$#" -ne 2 ]
    then
        echo "Usage: ./ssl_script.sh <tar_name> <dir_name>"
        exit 1
    fi
done


#$1  - tar-name
#$2 - dir_name
mkdir ssl_temp_dir
tar -C ssl_temp_dir -xf "$1"
mkdir -p "$2"
find ssl_temp_dir -type f -exec mv {} "$2" \;
rm -rf ssl_temp_dir
rm -rf "$1"
exit 0
