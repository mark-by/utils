#!/bin/bash

if [ "$1" = "" ]; then
    echo "Usage: --db <db_name> --user <username> [[if new user] --new <password>]"
    exit 1
fi

user() {
    db_username=$1
}

db() {
    db_name=$1
}

password() {
    pass=$1
}

err() {
    echo "Usage: --db <db_name> --user <username> [[if new user] --new <password>]" >&2
}

optspec=":-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
            case "${OPTARG}" in
                user)
                    user $val;;
                db)
                    db $val;;
                new)
                    password $val;;

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

echo "db: " $db_name
echo "user: " $db_username
echo "password: " $pass

sudo -u postgres createdb --encoding UNICODE $db_name --username postgres

if [ ! "$pass" = "" ]; then
    sudo -u postgres psql -c "create user $db_username with password '$pass';"
    sudo -u postgres psql -c "alter user $db_username createdb;"
fi
sudo -u postgres psql -c "grant all privileges on database $db_name to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all tables in schema public to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all sequences in schema public to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all functions in schema public to $db_username;"
exit
