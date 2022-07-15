<!-- ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
``` -->

```diff
+ text in green
# Two database machines into one using Docker

+Goal: Come up with a way to unite two database machines into one.
+Details:

+1. Use docker to create two containers of PostgreSQL database.
+2. In each container, create a database and fill it with some data of your choosing.
+3. Create a script (using bash/python/other) that will transfer all data from one database
+   container to the other.

+Notes:

+1. Please provide all scripts/configuration files you use, so we can repeat the process,
+   including the setup.
+2. PostgreSQL supports multiple databases in the same instance, so at the end, we want
+   to have one PostgreSQL instance with two separate databases, instead of two PostgreSQL
+   instances with one database each.
+3. If you use extra tools, not found by default on a standard Linux distribution, please
+   explain how to set them up.
```
# Here are the steps:

1. ### Install Docker on 2 db machines on Linux (local host Ubuntu 22.04 Container OS Debian)

sudo apt-get update
sudo apt-get upgrade -y

sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version

2.  ### Create PostgresSQL container :
sudo docker pull postgres

sudo docker run -d --name tmp_postgres_sql_db -d --restart=unless-stopped -p 5432:5432 -e 'POSTGRES_PASSWORD=docker' postgres

sudo docker run -d --name main_postgres_sql_db_ -d --restart=unless-stopped -p 5433:5433 -e 'POSTGRES_PASSWORD=docker' postgres

sudo docker ps

3. ### Go inside your container and add additional database:

sudo docker exec -it {container ID} bash
psql -U postgres

- create table with parameters:
CREATE DATABASE db_first_db_0;
\l


- Connect to database
\c db_first_db_0
create table student ( rolINo int,name varchar (10) ,primary key(rolINo));
\d
insert into student(rolINo, name) values (101, 'brijen');
SELECT * FROM student;

4. ### install ssh on both containers

passwd root
% docker

apt-get update
apt-get install nano
apt-get install openssh-client openssh-server -y
nano /etc/ssh/sshd_config 

- Change the line "PermitRootLogin yes" after line:#PermitRootLogin 

service ssh restart
service --status-all

- With this command you can see that you have valid port to ssh connection : 0.0.0.0:22
apt-get install net-tools
root@cebf20657667:/# netstat -tupan

- ssh to tmp container
- to see ip address of a container
sudo docker inspect {container name} | grep IPAddress
ssh root@{ipAddress}

- #--on host install to make connection to container via script
apt-get install expect -y


5. ### run script to transfer db from one database container machine to another
- create file "dbImporter.sh" inside db container of postgresSQL, insert the code below.
- run script by this command bash ./dbImporter.sh
- Please notice that you can change variables like: IP, database's names, name of the files etc. for your need.
- Also here you will see dummy password, and it is very recommend to change to strong passwords

```bash
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#% script that moves one db to another , ,
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
6. ###  commands to check that db has been transferred
root@423eac21b4c1:/# psql -U postgres
postgres=# \c postdata
postdata=# \d
postdata=# SELECT * FROM student;

7. ### remove unused container db
sudo docker rm -f <Container_ID> 
sudo docker rm -f 423eac21b4c1

-- Commands for additional operations:

-  Stop all running containers
docker stop $(docker ps -aq)
-  Remove all containers
docker rm $(docker ps -aq)
-  remove all images (by force) from vm to start clean
sudo docker rmi $(sudo docker images -aq) --force