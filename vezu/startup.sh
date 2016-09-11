export GEM_HOME=/home/s74/ruby/gems:/usr/lib/ruby/gems/1.8
export GEM_PATH=/home/s74/ruby/gems:/usr/lib/ruby/gems/1.8

export PROJECT=/home/s74/rails_apps/vezu
export BUNDLE=/home/s74/ruby/gems/bin/bundle
export RAILS_ENV=production
export PID=$PROJECT/tmp/pid.txt
export RR=$PROJECT/tmp/restart.txt

# If server needs to be restarted 
if [ -f $RR ];
then
	# Kill the old process
	if [ -f $PID ];
	then
	  kill `cat $PID` || /bin/true
	  rm $PID
	  sleep 5
	fi
	
	# Run the new one
	cd $PROJECT
	$BUNDLE exec unicorn -l 12003 > $PROJECT/log/unicorn.log 2>&1 &
	echo $! > $PROJECT/tmp/pid.txt
	
	# Remove restart file
	rm $RR
fi