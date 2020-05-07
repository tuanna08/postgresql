#!/bin/bash

echo "Create by Openstack Company"

#Install the repository RPM:
yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

#Install the client packages:
yum install postgresql12

#Install the client packages:
yum install postgresql12-server

#Optionally initialize the database and enable automatic start
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable postgresql-12
systemctl start postgresql-12
systemctl status postgresql-12

echo "Done job!"