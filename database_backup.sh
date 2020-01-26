#!/bin/bash

GRAYLOG_IP=<graylog_ip>
GRAYLOG_PORT=<graylog_port>

LOG_FILE=/var/log/backup/db_backup.log
BACKUP_CREATION_DATE=$(date +%F)

 
# <DB_TYPE> <USERNAME> <PASSWORD> <HOST> <DB> <TABLE/AUTH_DB>
declare -a BACKUP_TABLES
BACKUP_TABLES[1]='mysql,<username>,<password>,<host>,<DB>,<table>'
BACKUP_TABLESi[2]='mongo,<username>,<password>,<host>,<DB>,<AUTH_DB>'

# echo $HOSTN $DAT $1 | nc -w1 -u 172.24.4.44 1518
    
logger() {
	HOSTN=$(hostname)
    DAT=$(date +%F' '%T)
    echo $HOSTN $DAT $1 | nc -w1 -u $GRAYLOG_IP $GRAYLOG_PORT
    echo $HOSTN $DAT $1 >> $LOG_FILE
}

backup_mysql() {
	USERNAME=$1
	PASSWORD=$2
	HOST=$3
	DB=$4
	TABLE=$5

	DIR_PATH="/mnt/mysql/$HOST/$DB" 
	BACKUP_FILE=$DIR_PATH/$TABLE.sql-$BACKUP_CREATION_DATE

	mkdir -p $DIR_PATH

	mysqldump -u $USERNAME -p$PASSWORD -h$HOST --routines $DB $TABLE > $BACKUP_FILE
	gzip $BACKUP_FILE
}

backup_mongo() {
	USERNAME=$1
	PASSWORD=$2
	HOST=$3
	DB=$4
	AUTH_DB=$5

	DIR_PATH="/mnt/mongo/$HOST/$DB" 
	BACKUP_FILE=$DIR_PATH/$DB-$BACKUP_CREATION_DATE

	mkdir -p $DIR_PATH

	mongodump --quiet --host $HOST -u$USERNAME -p$PASSWORD --db $DB --out=$BACKUP_FILE --authenticationDatabase $AUTH_DB
	gzip -r $BACKUP_FILE
}


logger "start dump log"

for i in "${BACKUP_TABLES[@]}"
do
    IFS="," read -r -a DATAs <<< "${i}"

	DB_TYPE=${DATAs[0]}
	SOURCE="$DB_TYPE host:${DATAs[3]} database:${DATAs[4]} table:${DATAs[5]}"

	logger "start backup $SOURCE ..."

	if [[ $DB_TYPE = "mysql" ]]
    then
		backup_mysql ${DATAs[1]}  ${DATAs[2]}  ${DATAs[3]}  ${DATAs[4]} ${DATAs[5]}
    fi
	if [[ $DB_TYPE = "mongo" ]]
    then
		backup_mongo ${DATAs[1]}  ${DATAs[2]}  ${DATAs[3]}  ${DATAs[4]} ${DATAs[5]}
	fi

	logger "backup $SOURCE end"	
done


logger "end dump log"
