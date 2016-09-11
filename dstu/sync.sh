#/sbin/ifdown eth1
#/sbin/ifup   eth1

/usr/bin/rsync -e ssh -vrukKpgotD --delete --exclude='/www/mysql' root@10.2.0.10:/www /
mysqldump -uroot -pTrash447 -h10.2.0.10 --all-databases --compress | mysql -uroot -pTrash447 
/usr/bin/rsync -e ssh -vrukKpgotD --delete root@10.2.0.10:/etc/httpd/hosts /etc/httpd/
/sbin/service httpd restart
