RAILS_ROOT = "/home/deploy/beenthere/current"
rails_env = ENV['RAILS_ENV'] || 'production'

rails_env == 'production' ? 6 : 2
worker_processes num_workers

working_directory RAILS_ROOT

listen 8001

timeout 300

pid "/tmp/unicorn.pid"

stderr_path "#{RAILS_ROOT}/log/unicorn.stderr.log"
stdout_path "#{RAILS_ROOT}/log/unicorn.stdout.log"

preload_app true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

check_client_connection false

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{RAILS_ROOT}/Gemfile"
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

   old_pid = "#{server.config[:pid]}.oldbin"
   if old_pid != server.pid
     begin
       sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
       Process.kill(sig, File.read(old_pid).to_i)
     rescue Errno::ENOENT, Errno::ESRCH
     end
   end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
