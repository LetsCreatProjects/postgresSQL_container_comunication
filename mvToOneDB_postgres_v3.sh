#!/bin/bash
# # ---------------Connection and creation of .sql file + close the connection---Working
/usr/bin/expect -c ' 
spawn ssh root@172.17.0.2
sleep 1
send docker\n;
expect "*#" 
sleep 1
send "pg_dump -U postgres > postgres_backup.sql db_first_db_0\n" 
sleep 1
send "exit\n"
'
sleep 3
# # ---------------Connection via sftp and fetch .sql file + close the connection
/usr/bin/expect -c ' 
spawn sftp root@172.17.0.2 
sleep 1
send docker\n;
expect "sftp>"
send "get postgres_backup.sql\r"
expect "sftp>"
send "exit\r"
interact
'
sleep 3
# # ---------------works create db in postgrase
/usr/bin/expect -c ' 
spawn psql -U postgres
expect "postgres=#"
send "CREATE DATABASE postdata_12;\r"
sleep 1
expect "CREATE DATABASE"
send "\\\q\n"
'
# # ---------------restores from .sql to that db
sleep 3
psql -U postgres -d postdata_12 -f postgres_backup.sql 

