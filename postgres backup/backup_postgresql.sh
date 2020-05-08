#!/bin/bash
echo "<=========================== Program by Nguyễn Anh Tuấn========================>"

#0 11 * * * bash $HOME/backup_mysql/backup.sh

DATE_STR=$(date '+%d-%b-%Y')
DATE_TIME_STR=$(date +"%d-%b-%YT%T")

# backup database
# db name
#DB_NAME[0]="cinder"
#DB_NAME[1]="glance"
#DB_NAME[2]="keystone"
#DB_NAME[3]="neutron_ml2"
#DB_NAME[4]="nova"
#DB_NAME[5]="nova_api"
#DB_NAME[6]="nova_cell0"
#DB_NAME[7]="nova_placement"

#for i in "${DB_NAME[@]}"
#do     
#       mkdir -p $HOME/backup_mysql/$DATE_STR/
#       mysqldump --databases $i > $HOME"/backup_mysql/"$DATE_STR"/"$i".sql"
        
#done

mkdir -p $HOME/backup_mysql/$DATE_STR/

for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    if [[ $DB != "information_schema" ]] && [[ $DB != "performance_schema" ]]
    then
        mysqldump $DB > $HOME"/backup_mysql/"$DATE_STR"/"$DB".sql";
    fi
done

echo "Backup dữ liệu openstack thành công: "$DATE_TIME_STR >> $HOME/backup_mysql/log_backup.out