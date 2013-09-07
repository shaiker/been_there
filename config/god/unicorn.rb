rails_root = "/home/deploy/beenthere/current"
pid_path = "/tmp/unicorn.pid"
rails_env = ENV['RAILS_ENV'] || "production"

God.watch do |w|
  w.name = "unicorn"
  w.interval = 30.seconds # default
  
  # unicorn needs to be run from the rails root
  w.start = "cd #{rails_root} && BUNDLE_GEMFILE=#{rails_root}/Gemfile bundle exec unicorn -c #{rails_root}/config/unicorn.rb -E #{rails_env} -D"
 
  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat #{pid_path}`"
 
  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat #{pid_path}`"
 
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = pid_path
 
  w.behavior(:clean_pid_file)
 
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
 
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 600.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
 
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
 
  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

# This will ride alongside god and kill any rogue memory-greedy
# processes. Their sacrifice is for the greater good.

unicorn_worker_memory_limit = 400_000

Thread.new do
  loop do
    begin
      # unicorn workers
      #
      # ps output line format:
      # 31580 275444 unicorn_rails worker[15] -c /data/github/current/config/unicorn.rb -E production -D
      # pid ram command

      lines = `ps -e -www -o pid,rss,command | grep '[u]nicorn worker'`.split("\n")
      lines.each do |line|
        parts = line.split(' ')
        if parts[1].to_i > unicorn_worker_memory_limit
          # tell the worker to die after it finishes serving its request
          ::Process.kill('QUIT', parts[0].to_i)
        end
      end
    rescue Object
      # don't die ever once we've tested this
      nil
    end

    sleep 30
  end
end
