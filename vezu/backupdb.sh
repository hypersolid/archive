heroku pgbackups:capture --expire
curl -o latest.dump `heroku pgbackups:url`
pg_restore -O -c -d sol latest.dump