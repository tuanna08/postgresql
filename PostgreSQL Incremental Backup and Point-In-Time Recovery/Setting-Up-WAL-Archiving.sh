#!/bin/bash
echo "==========Setting up WAL Archiving============"

time_zone = "Asia/Ho_Chi_Minh"
timedatectl set-timezone $time_zone && date

mkdir /wal_archive
chown -R postgres.postgres /wal_archive

read -s -p "Enter version postgresql (12): " my_version

sed -i "s/^timezone = .*/timezone = '$time_zone'/g" /etc/postgresql/$my_version/main/postgresql.conf
sed -i "s/^log_timezone = .*/log_timezone = '$time_zone'/g" /etc/postgresql/$my_version/main/postgresql.conf

sed -i 's/^archive_mode =.*/archive_mode = on/g' /etc/postgresql/$my_version/main/postgresql.conf
sed -i "s/^archive_command =.*/archive_command = 'test ! -f /wal_archive/%f && cp %p /wal_archive/%f'/g" /etc/postgresql/$my_version/main/postgresql.conf
sed -i 's/^wal_level =.*/wal_level = replica/g' /etc/postgresql/$my_version/main/postgresql.conf

systemctl postgresql postgres
su postgres

read -s -p "Enter password for replication: " my_password
psql -c "CREATE USER replication REPLICATION LOGIN CONNECTION LIMIT 10 ENCRYPTED PASSWORD '$my_password';"

echo "========Base Backup========="

pg_basebackup -Ureplication -h127.0.0.1 --progress -D /basebackup/ -p$my_password

ssh-keygen -N ""

echo "please edit crontab:  crontab -e"
echo "add script "
echo "* * * * * rsync -avz /wal_archive/ postgres@pg-slave:/wal_archive/"
echo "* * * * * rsync -avz /basebackup/ postgres@pg-slave:/basebackup/"

exit

echo "==========Completed============"