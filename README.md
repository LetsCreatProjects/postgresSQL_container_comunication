<!-- ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
``` -->

# Creating 2 containers of PostgresSQL, creating data and merging 2 PostgresSQL instances into one.

```diff
+ Creation of two database containers using Docker 
+ Filling data to 2 Instances of PostgresSQL
+ Running script that merge two PostgresSQL Instances into one
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

sudo docker run -d --name main_postgres_sql_db -d --restart=unless-stopped -p 5432:5432 -e 'POSTGRES_PASSWORD=docker' postgres

sudo docker run -d --name tmp_postgres_sql_db -d --restart=unless-stopped -p 5433:5433 -e 'POSTGRES_PASSWORD=docker' postgres

sudo docker ps

3. ### Go inside your container and add additional database:

sudo docker exec -it {container ID} bash
<!-- 
sudo docker exec -it 26bcce618c33 bash
sudo docker exec -it 9a0cd89f3768 bash -->

psql -U postgres

### Creating table on tmp PostgresSQL Instance (with values):

CREATE DATABASE db_passengers;
\l

- Connect to database
\c db_passengers
<!-- create table student ( rolINo int,name varchar (10) ,primary key(rolINo)); -->
- create table with parameters:

create table passengers(
Id int primary key not null,
Name varchar (100) not null,
Email varchar (255) unique not null,
Age int not null,
Travel_to varchar (255) not null,
Paymentv int not null,
Travel_date date not null
);

\d
<!-- insert into student(rolINo, name) values (101, 'brijen'); -->
INSERT INTO passengers ("id", "name", "email", "age", "travel_to", "paymentv", "travel_date")
VALUES
(1, 'Jack', 'jack12@gmail.com', 20, 'Paris', 79000, '2018-1-1'),
(2, 'Anna', 'anna@gmail.com', 19, 'NewYork', 405000, '2019-10-3'),
(3, 'Wonder', 'wonder2@yahoo.com', 32, 'Sydney', 183000, '2012-8-5'),
(4, 'Stacy', 'stacy78@hotmail.com', 28, 'Maldives', 29000, '2017-6-9'),
(5, 'Stevie', 'stevie@gmail.com', 49, 'Greece', 56700, '2021-12-12'),
(6, 'Harry', 'harry@gmail.com', 22, 'Hogwarts', 670000, '2020-1-17');

SELECT * FROM passengers;

### Creating table ont main PostgresSQL Instance (with values):
CREATE DATABASE db_china_vs_india_population;
\l
_

- Connect to database
\c db_china_vs_india_population
<!-- create table student ( rolINo int,name varchar (10) ,primary key(rolINo)); -->
- create table with parameters:

CREATE TABLE ChinaVsIndia(
"Index" int primary key not null,
"China" int not null,
"India" int not null,
"Year"  int not null
);

\d
<!-- insert into student(rolINo, name) values (101, 'brijen'); -->
INSERT INTO ChinaVsIndia ("Index", "China", "India", "Year")
VALUES
(1,2021,1444216102,1393409033),
(2,2020,1439323774,1380004385),
(3,2019,1433783692,1366417756),
(4,2018,1427647789,1352642283),
(5,2017,1421021794,1338676779),
(6,2016,1414049353,1324517250),
(7,2015,1406847868,1310152392),
(8,2010,1368810604,1234281163),
(9,2005,1330776380,1147609924),
(10,2000,1290550767,1056575548),
(11,1995,1240920539,963922586),
(12,1990,1176883681,873277799),
(13,1985,1075589363,784360012),
(14,1980,1000089228,698952837),
(15,1975,926240889,623102900),
(16,1970,827601385,555189797),
(17,1965,724218970,499123328),
(18,1960,660408054,450547675),
(19,1955,612241552,409880606);

SELECT * FROM ChinaVsIndia;

- Command to delete db if needed:
postgres=# DROP DATABASE IF EXISTS {dbName};
<!-- DROP DATABASE IF EXISTS db_china_vs_india_population; _-->

_4. ### install ssh on both containers

- Declare password for ssh connection
passwd root
% docker

apt-get update
apt-get install nano
apt-get install openssh-client openssh-server -y
nano /etc/ssh/sshd_config 

- Change the line "PermitRootLogin yes" after line:#PermitRootLogin 

service ssh restart
service --status-all

- ssh to tmp container
- to see ip address of a container
sudo docker inspect {container name} | grep IPAddress
ssh root@{ipAddress}

- #--on host install to make connection to container via script
apt-get install expect -y



<!-- 
tmp_postgres_sql_db
sudo docker inspect 26bcce618c33 | grep IPAddress
ssh root@172.17.0.3
sudo docker exec -it 26bcce618c33 bash

main_postgres_sql_db_
sudo docker inspect 9a0cd89f3768 | grep IPAddress
ssh root@172.17.0.2 
sudo docker exec -it 9a0cd89f3768 bash

-->

### Network troubleshooting:

sudo docker network create web_server --driver bridge
docker inspect web_server
sudo docker inspect -f '{{range $key, $value := .NetworkSettings.Networks}}{{$key}} {{end}}' [container]
sudo docker inspect {my-container-name}
docker network create {network_name}
sudo docker network ls
- To check if two containers (or more) are on a network together: 
docker network inspect [networkName] -f "{{json .Containers }}"
- To see what network(s) your container is on:
sudo docker inspect [container_name] -f "{{json .NetworkSettings.Networks }}"
- For troubleshooting connection use this command, you can see that you have valid port to ssh connection : 0.0.0.0:22
apt-get install net-tools
root@cebf20657667:/# netstat -tupan
- Attention: if you want to ssh from localhost to containers, you need to install and configure ssh dependencies too.

5. ### run script to transfer db from one database container machine to another

- create file "db_importer.sh" inside db container of postgresSQL, insert the code in file "db_importer.sh":
nano db_importer.sh
- run script
bash db_importer.sh
- Please notice that you can change variables like: IP, database's names, name of the files etc. for your need.
- Also here you will see dummy password, and it is very recommend to change to strong passwords

```bash

# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# #% script that moves one db to another , ,
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# #!/bin/bash
# # # ---------------Connection and creation of .sql file + close the connection---Working
# /usr/bin/expect -c ' 
# spawn ssh root@172.17.0.2
# sleep 1
# send docker\n;
# expect "*#" 
# sleep 1
# send "pg_dump -U postgres > postgres_backup.sql db_passengers\n" 
# sleep 1
# send "exit\n"
# '
# sleep 3
# # # ---------------Connection via sftp and fetch .sql file + close the connection
# /usr/bin/expect -c ' 
# spawn sftp root@172.17.0.2 
# sleep 1
# send docker\n;
# expect "sftp>"
# send "get postgres_backup.sql\r"
# expect "sftp>"
# send "exit\r"
# interact
# '
# sleep 3
# # # ---------------works create db in postgrase
# /usr/bin/expect -c ' 
# spawn psql -U postgres
# expect "postgres=#"
# send "CREATE DATABASE postdata_12;\r"
# sleep 1
# expect "CREATE DATABASE"
# send "\\\q\n"
# '
# # # ---------------restores from .sql to that db
# sleep 3
# psql -U postgres -d postdata_12 -f postgres_backup.sql 

# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
6. ###  commands to check that db has been transferred
root@423eac21b4c1:/# psql -U postgres
\l
\c postdata
\d
SELECT * FROM {table_name};

7. ### remove unused container db
sudo docker rm -f <Container_ID> <Container_ID> 
<Container_ID> 

-- Commands for additional operations:

-  remove all images (by force) from vm to start clean
sudo docker rmi $(sudo docker images -aq) --force
sudo docker images