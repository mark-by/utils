#!/bin/bash

err() {
    echo "Usage: --db <db_name> --user <username> [[if by dump] --dump <dump_file>]"
}

if [ "$1" = "" ]; then
    err
    exit 1
fi

optspec=":-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
            case "${OPTARG}" in
                user)
                    db_username=$val;;
                db)
                    db_name=$val;;
                dump)
                    dump_file=$val;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                        err
                    fi
                    ;;
            esac;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                err
            fi
            ;;
    esac
done
sudo -u postgres psql -c "drop database $db_name;"
sudo -u postgres createdb --encoding UNICODE $db_name --username postgres
if [ ! "$dump_file" = "" ]; then
    sudo -u postgres psql $db_name < $dump_file
fi
sudo -u postgres psql -c "grant all privileges on database $db_name to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all tables in schema public to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all sequences in schema public to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all functions in schema public to $db_username;"
exit
