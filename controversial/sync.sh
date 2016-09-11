rsync -va --delete  --exclude .git --exclude tmp/ --exclude schema.rb --exclude public/system --exclude log/ /home/sol/i-dev/controversial/ s74@s74.org:/home/s74/www/controversialmatter.com
rsync -va --delete --exclude upload/ /var/www/ s74@s74.org:/home/s74/www/media_controversialmatter
ssh s74@s74.org touch /home/s74/www/controversialmatter.com/tmp/restart.txt