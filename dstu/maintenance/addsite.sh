echo 'adding new site '$1' identified by '$2' on port '$3
mkdir /www/$1
echo $1"'s main page">/www/$1/index.html 
cat support/addsite.sql|sed 's/RNAME/'$1'/g' | sed 's/RPASS/'$2'/g' | mysql -u root -pTrash447
cat support/site.conf | sed 's/RNAME/'$1'/g' | sed 's/RPORT/'$3'/g' > /etc/httpd/hosts/$1.conf
cat support/samba.conf | sed 's/replace/'$1'/g' >> /etc/samba/smb.conf
useradd $1
passwd $1
passwd -l $1
smbpasswd -a $1
usermod -a -G $1 apache
chown -R $1:$1 /www/$1 
chmod -R 0755 /www/$1
service smb restart
service httpd restart
echo $1' '$2' '$3 >> support/addsite.log
