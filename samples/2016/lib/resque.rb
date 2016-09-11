module Eye::Dsl::Ext
  def include_resque(queue  = '*', resque_numbers)
    # @@resque_number ||= 0
    # @@resque_number += 1

    resque_numbers.each do |resque_number|
      process_title = "resque-#{resque_number}"
      process(process_title) do
        env('QUEUE' => queue, 'JOBS_PER_FORK' => 1_000_000)

        pid_file "#{PID_PATH}/#{process_title}.pid"

        daemonize true
        start_command 'bundle exec rake environment resque:work'
        stop_signals [:USR1, 0, :TERM, 10.seconds, :KILL]

        start_grace 120.seconds
        stop_grace 30.seconds
        restart_grace 150.seconds

        stdout "#{LOG_PATH}/#{process_title}.stdout.log"
        stderr "#{LOG_PATH}/#{process_title}.stderr.log"

        monitor_children do
          stop_command 'kill {PID}'
        end
      end
    end
  end
end

Eye::Dsl::ApplicationOpts.send(:prepend, Eye::Dsl::Ext)
Eye::Dsl::GroupOpts.send(:prepend, Eye::Dsl::Ext)
