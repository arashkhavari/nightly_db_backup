# nightly_db_backup
MongoDB and MySQL nightly backup sequentialy

Dump from MySQL and MongoDB with mysqldump and mongodump command with example syntax:

```bash
mysqldump -u <username> -p<password> -h<db_hostname> --routines <db_name> <table_name> > /export/data/path

mongodump --quiet --host <db_hostname> --u<username> -p<password> --db <db_name> --out=/export/data/path --authenticationDatabase <auth_db_name>
```

compress data with example command syntax:
```bash
gzip -9 /export/data/path/file.dump
```
