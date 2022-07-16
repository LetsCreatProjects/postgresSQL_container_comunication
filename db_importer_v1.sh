#!/bin/bash
# # # ---------------Load config values
source config.conf
# # ---------------Connection and creation of .sql file + close the connection---Working
/usr/bin/expect -c ' 
set f [open "config.conf"]
gets $f user
gets $f host
gets $f pw
gets $f sql_file_name
gets $f db_imported_name
gets $f db_new_name
close $f

spawn ssh -o StrictHostKeyChecking=no $user@$host
sleep 1
send $pw\n;
expect "*#" 
sleep 1
send "pg_dump -U postgres > $sql_file_name $db_imported_name\n" 
sleep 1
send "exit\n"
'
sleep 3
# # ---------------Connection via sftp and fetch .sql file + close the connection
/usr/bin/expect -c ' 
set f [open "config.conf"]
gets $f user
gets $f host
gets $f pw
gets $f sql_file_name
gets $f db_imported_name
gets $f db_new_name
close $f

spawn sftp -o StrictHostKeyChecking=no $user@$host
sleep 1
send $pw\n;
expect "sftp>"
send "get $sql_file_name\r"
expect "sftp>"
send "exit\r"
interact
'
sleep 3
# # ---------------works create db in postgrase
/usr/bin/expect -c ' 

set f [open "config.conf"]
gets $f user
gets $f host
gets $f pw
gets $f sql_file_name
gets $f db_imported_name
gets $f db_new_name
close $f

spawn psql -U postgres
expect "postgres=#"
send "CREATE DATABASE $db_new_name;\r"
sleep 1
expect "CREATE DATABASE"
send "\\\q\n"
sleep 1
'
# # ---------------restores from .sql to that db
sleep 3
psql -U postgres -d $DB_NEW_NAME -f $SQL_FILE_NAME
echo "input psql -U postgres -d $DB_NEW_NAME -f $SQL_FILE_NAME"