PGPASSWORD=metro pg_dump -Fc --no-acl --no-owner -h localhost -U metro metro > updb.dump
scp updb.dump s74@lapwing.arvixe.com:/home/s74/www/
heroku pgbackups:restore HEROKU_POSTGRESQL_YELLOW_URL 'http://s74.org/updb.dump' --confirm arcane-fjord-2940
rm updb.dump

