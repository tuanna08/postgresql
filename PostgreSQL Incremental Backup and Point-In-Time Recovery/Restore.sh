#!/bin/bash
echo "==========Restore from WAL============"

time_zone = "Asia/Ho_Chi_Minh"
timedatectl set-timezone $time_zone && date
systemctl stop postgres
read -s -p "Enter version postgresql (12): " my_version

chown -R postgres.postgres /wal_archive
chown -R postgres.postgres /basebackup

su postgres


rm -rf /var/lib/postgresql/$my_version/main/*
cp -r /basebackup/* /var/lib/postgresql/$my_version/main/
rm -rf /var/lib/postgresql/$my_version/main/pg_wal/*

sed -i "s/^timezone = .*/timezone = '$time_zone'/g" /etc/postgresql/$my_version/main/postgresql.conf
sed -i "s/^log_timezone = .*/log_timezone = '$time_zone'/g" /etc/postgresql/$my_version/main/postgresql.conf

sed -i "s/^timezone = .*/timezone = '$time_zone'/g" /etc/postgresql/$my_version/main/postgresql.conf
sed -i "s/^restore_command = .*/restore_command = 'cp /wal_archive/%f %p'/g" /etc/postgresql/$my_version/main/postgresql.conf
sed -i "s/^recovery_target_timeline =.*/recovery_target_timeline = 'latest'/g" /etc/postgresql/$my_version/main/postgresql.conf

touch /var/lib/postgresql/$my_version/main/recovery.signal

systemctl start postgres

exit

echo "==========Completed============"