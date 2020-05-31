#!/bin/bash

if [ "$1" = "" ]; then
    echo "Usage: --db <db_name>"
    exit 1
fi

db() {
    db_name=$1
}

optspec=":-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
            case "${OPTARG}" in
                db)
                    db $val;;

                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                        echo "Usage: --db <db_name> --user <username>" >&2
                    fi
                    ;;
            esac;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Usage: --db <db_name> --user <username>" >&2
            fi
            ;;
    esac
done
sudo -u postgres psql -c "drop database $db_name;"
exit
