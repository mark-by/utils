#!/bin/bash

err() {
    echo "Usage: --db <db_name>" 
    echo "--user <username>     Имя пользователя бд. Если указать этот тэг, то будет создаваться/пересоздаваться бд"
    echo ""
    echo "--new <password>      Создать нового пользователя с указанным паролем"
    echo ""
    echo "--dump <dump_file>    При создании, бд будет конструироватья по указанному dump файлу."
    echo "                      В ином случае [без опции --user] будет создаваться dump в указанном файле"
    echo ""
    echo "----- Указывать последними"
    echo ""
    echo "--recreate            Пересоздать [drop и create]" 
    echo ""
    echo "--drop                Только удалить базу"
}

if [ "$1" = "" ]; then
    err
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
                recreate)
                    recreate="true";;
                dump)
                    dump_file=$val;;
                drop)
                    dbdrop="true";;
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

drop() {
    sudo -u postgres psql -c "drop database $db_name;"
}

if [ ! "$dbdrop" = "" ]; then
    if [ ! "$dbdrop" = "true" ]; then
        echo "Error: --drop должен быть последним"
    fi
    if [ "$db_name" = "" ]; then
        echo "Error: Укажите, какую базу данных удалить (--db <db_name>)"
    fi
    drop
    exit 0
fi

if [ "$db_name" = "" ]; then
    err
    exit 1
fi


if [ "$db_username" = "" ]; then
    if [ "$dump_file" = "" ]; then
        err
        exit 1
    fi
    sudo -u postgres pg_dump $db_name > $dump_file
    exit 0
fi

if [ ! "$recreate" = "" ]; then
    if [ ! "$recreate" = "true" ]; then
        echo "Error: --recreate должен быть последним"
    fi
    drop
fi

sudo -u postgres createdb --encoding UNICODE $db_name --username postgres

if [ ! "$dump_file" = "" ]; then
    sudo -u postgres psql $db_name < $dump_file
fi

if [ ! "$pass" = "" ]; then
    sudo -u postgres psql -c "create user $db_username with password '$pass';"
    sudo -u postgres psql -c "alter user $db_username createdb;"
fi

sudo -u postgres psql -c "grant all privileges on database $db_name to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all tables in schema public to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all sequences in schema public to $db_username;"
sudo -u postgres psql -d $db_name -c "grant all on all functions in schema public to $db_username;"
exit
