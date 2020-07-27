# install postgresql 12 by script

### Step 1: Run file script

[Script here](https://github.com/tuanna08/postgresql/blob/master/setup.sh)
    ```
        # git clone https://github.com/tuanna08/postgresql.git
        # cd postgresql
        # chmod +x ./setup.sh
        # ./setup.sh
    ```

### Step 2: Config remote connect
- find path to file

    ```
        ## [root@node01 postgresql]# find / -name "postgresql.conf"
        ## /var/lib/pgsql/12/data/postgresql.conf
        ## [root@node01 postgresql]# find / -name "pg_hba.conf"
        ## /var/lib/pgsql/12/data/pg_hba.conf
    ```
- edit ip listening in postgresql.conf

	Open postgresql.conf file, uncomment and replace line
    ```
        listen_addresses = 'localhost'
    ```
	with

    ```
        listen_addresses = '*'

    ```

- edit pg_hba.conf In order to fix it, open pg_hba.conf and add following entry at the very end.

    ```
    host    all             all              0.0.0.0/0                       md5
    host    all             all              ::/0                            md5
    ```
- restart postgresql

    ```
        systemctl restart postgresql-12
    ```
##### thanks you!