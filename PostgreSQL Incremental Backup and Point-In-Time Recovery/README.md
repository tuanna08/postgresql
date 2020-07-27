# Tutorial setup 

### Setting up WAL Archiving

- PostgreSQL stores all modifications in form of Write-Ahead Logs (WAL). These files can be used for replication, but they can also be used for PITR. First of all, we need to setup WAL archiving. We’ll start with creating a directory in which the WAL files will be stored. This can be in any location: on disk, on NFS mount, anywhere - as long as PostgreSQL can write to it, it’ll do.
```
mkdir /wal_archive
chown -R postgres.postgres /wal_archive
```

- We’ll create a simple directory and make sure it’s owned by ‘postgres’ user. Once this is done, we can start editing the PostgreSQL configuration.

    ```
    archive_mode = on  # enables archiving; off, on, or always # (change requires restart)
    archive_command = 'test ! -f /wal_archive/%f && cp %p /wal_archive/%f' 
    #command to use to archive a logfile segment
    wal_level = replica     # minimal, replica, or logical
    ```

- The settings above have to be configured - you want to enable archiving (archive_mode = on), you want also to set wal_lever to archive. Archive_command requires more explanation. PostgreSQL doesn’t care where you will put the files, as long as you’ll tell it how to do it. This command will be used to copy the files to their destination. It can be a simple one-liner, as in the example above, it can be a call to a complex script or binary. What’s important is that this command should not overwrite existing files. It also should return zero exit status only when it managed to copy the file. If the return code will be different than 0, PostgreSQL will attempt to copy that file again. In our case, we verify if the file already exists or not. If not, we will copy it to the destination. ‘%p’ represents full path to the WAL file to be copied while ‘%f’ represents the filename only.

- Once we are done with those changes, we need to restart PostgreSQL:
```
service postgresql restart
```

### Base Backup
- base backup

    ```
    psql -c "CREATE USER replication REPLICATION LOGIN CONNECTION LIMIT 10 ENCRYPTED
    PASSWORD 'YOUR_PASSWORD';"

    pg_basebackup -Umyuser -h127.0.0.1 --progress -D /basebackup/
    ```


### Restore

- Once you have a base backup done and WAL archiving configured, you are good to go. First of all, you need to figure out the point at which you should restore your data. Ideally, you’ll be able to give an exact time. Other options are: a named restore point (pg_create_restore_point()), transaction ID or WAL location LSN. You can try to use the pg_waldump utility to parse WAL files and print them in human-readable format, but it’s actually far from being human-readable so it can still be tricky to pinpoint the exact location.
```
rmgr: Transaction len (rec/tot):     34/    34, tx:     801534, lsn: 3/726587F0, prev 3/726587A8, desc: COMMIT 2017-11-30 12:39:05.086674 UTC
rmgr: Standby     len (rec/tot):     42/    42, tx:     801535, lsn: 3/72658818, prev 3/726587F0, desc: LOCK xid 801535 db 12938 rel 16450
rmgr: Storage     len (rec/tot):     42/    42, tx:     801535, lsn: 3/72658848, prev 3/72658818, desc: CREATE base/12938/16456
rmgr: Heap        len (rec/tot):    123/   123, tx:     801535, lsn: 3/72658878, prev 3/72658848, desc: UPDATE off 7 xmax 801535 ; new off 9 xmax 0, blkref #0: rel 1663/12938/1259 blk 0
```

- When you know at which point you need to restore to, you can proceed with the recovery. First, you should stop the PostgreSQL server:
```
service postgresql stop
```

- Then you need to remove all of the data directory, restore the base backup and then remove any existing WAL files. PostgreSQL will copy the data from our WAL archive directory.
```
rm -rf /var/lib/postgresql/12/main/*
cp -r /basebackup/* /var/lib/postgresql/12/main/
rm -rf /var/lib/postgresql/12/main/pg_wal/*
```

- Now, it’s time to prepare the recovery.conf file, which will define how the recovery process will look like.

- postgrsql 12
```
touch /var/lib/postgresql/12/main/recovery.signal
```

- postgresl 11
```
touch /var/lib/postgresql/12/main/recovery.conf
```

- edit config
```
restore_command = 'cp /wal_archive/%f "%p"'
#recovery_target_lsn = '3/72658818'
recovery_target_timeline = 'latest'
```

- Postgrsql 11
```
restore_command = 'cp /wal_archive/%f "%p"'
#recovery_target_lsn = '3/72658818'
recovery_target_time = '2020-07-24 11:19:00+07'
recovery_target_inclusive = true
recovery_target_action = promote
#hot_standby = on
```

- In the example above, we defined a restore command (simple cp from our /wal_archive directory into PostgreSQL pg_wal directory). We also should decide where to stop - we decided to use a particular LSN as a stop point, but you can also use:
```
recovery_target_name
recovery_target_time
recovery_target_xid
```

- for a named restore point, timestamp and transaction ID.

- Finally, make sure that all of the files in the PostgreSQL data directory have the correct owner:
```
chown -R postgres.postgres /var/lib/postgresql/
```

- Once this is done, we can start PostgreSQL:
```
service postgresql start
```

- In the log you should see entries like this:
```
2017-12-01 10:45:56.362 UTC [8576] LOG:  restored log file "000000010000000300000034" from archive
2017-12-01 10:45:56.401 UTC [8576] LOG:  restored log file "00000001000000030000001D" from archive
2017-12-01 10:45:56.419 UTC [8576] LOG:  redo starts at 3/1D9D5408
2017-12-01 10:45:56.464 UTC [8576] LOG:  restored log file "00000001000000030000001E" from archive
2017-12-01 10:45:56.526 UTC [8576] LOG:  restored log file "00000001000000030000001F" from archive
2017-12-01 10:45:56.583 UTC [8576] LOG:  restored log file "000000010000000300000020" from archive
2017-12-01 10:45:56.639 UTC [8576] LOG:  restored log file "000000010000000300000021" from archive
2017-12-01 10:45:56.695 UTC [8576] LOG:  restored log file "000000010000000300000022" from archive
2017-12-01 10:45:56.753 UTC [8576] LOG:  restored log file "000000010000000300000023" from archive
2017-12-01 10:45:56.812 UTC [8576] LOG:  restored log file "000000010000000300000024" from archive
```

- After recovery is complete, recovery.conf file will be renamed to recovery.done. Please keep in mind that this won’t happen with:
```
recovery_target_action = ‘shutdown’
```