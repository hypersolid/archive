#!/bin/sh
/usr/bin/rsync -e ssh -vrukKpgotD --delete root@10.2.0.18:/www /
export folder=/var/www/backup/`date +%Y/%B/%d_%Hh_%Mm`
mkdir -p $folder

cd /www
for dir in *

do
    mkdir -p $folder/$dir
    echo `date` > $folder/$dir/timelog
    tar -czf $folder/$dir/backup.tar.gz /www/$dir 
    echo `date` >> $folder/$dir/timelog
    /usr/bin/mysqldump -uroot -pTrash447 -h10.2.0.18 --compress $dir > $folder/$dir/backup.sql
    echo `date` >> $folder/$dir/timelog
done

echo `date` > $folder/finished
exit 0
