export GEM_HOME=/home/s74/ruby/gems:/usr/lib/ruby/gems/1.8
export GEM_PATH=/home/s74/ruby/gems:/usr/lib/ruby/gems/1.8

if [ -f /home/s74/www/controversialmatter.com/tmp/restart.txt ];
then
  rm /home/s74/www/controversialmatter.com/tmp/restart.txt
  
  kill -9 `/usr/bin/pgrep -u s74 ruby`

  cd /home/s74/www/controversialmatter.com/
  RAILS_ENV=production /home/s74/ruby/gems/bin/unicorn -l 12002 > /home/s74/www/controversialmatter.com/log/worker.log 2>&1

fi
