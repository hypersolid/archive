scp -r 10.2.0.14:/www/$1 /www
scp 10.2.0.14:/etc/httpd/sites/$1.conf /etc/httpd/hosts/
chown -R $1:$1 /www/$1/
mysqldump -h10.2.0.14 -uroot -p3175br $1 | mysql -uroot -pTrash447 $1
