APP_CONFIG = YAML.load_file("config/config.yml")[rails_env]
# --------------------------------------------------
# Bundler integration - supplies bundle:install task
# --------------------------------------------------
require "bundler/capistrano"

# --------------------------------------------------
# RVM settings
# -------------------------------------------
require "rvm/capistrano"
set :rvm_ruby_string, "1.9.3-p327"

# -------------------------------------------
# Stages settings - allows cap [stage] deploy
# -------------------------------------------
set :stages, %w(production)
set :default_stage, :production
require 'capistrano/ext/multistage'


# -------------------------------------------
# Git and deploytment details
# -------------------------------------------
set :application, "been_there"
set :repository,  "git@github.com:shaiker/been_there.git"
set :scm, :git
set :deploy_to, '/home/deploy/beenthere'
set :user, "deploy"
set(:rails_env) { stage }

# set :deploy_via, :remote_cache
# set :branch, fetch(:branch, "master")
# set :use_sudo, false
# set :cleanup_threshold, 75
# set(:deploy_current_version) { ENV['DEPLOY_CURRENT_VERSION'] == 'true' }
# ssh_options[:paranoid] = false
# default_run_options[:on_no_matching_servers] = :continue
# -------------------------------------------



server "kokavo.com", :app, :web

before 'deploy:assets:precompile', 'bundle:install', 'deploy:fail_on_pending_migrations'
after  'deploy:assets:precompile', 'deploy:restart', 'deploy:cleanup'


namespace :unicorn do
  desc "Restart Unicorn processes"
  task :restart, roles: :web do
    run "kill -s USR2 `cat /tmp/unicorn.pid`"
  end

  task :start, roles: :web do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec god -c config/god/unicorn.rb"
  end

  desc "Stops unicorn processes on server"
  task :stop, roles: :web do
    run "kill -s QUIT `cat /tmp/unicorn.pid`"
  end
end


namespace :deploy do

  task :quick do
    namespace :assets do
      task :precompile do
        puts "Assets precompile skipped"
      end
    end
    default
  end
 

  task :start do
    unicorn.start
  end

  task :restart do
    unicorn.restart
  end


  desc "Fail a deploy if there are pending migrations and did not run with deploy:migrations"
  task :fail_on_pending_migrations, :roles => :app do
    deployed_with_migrations = !!fetch(:migrate_target, false)
    if !deployed_with_migrations
      run "cd #{release_path} && bundle exec rake db:abort_if_pending_migrations RAILS_ENV=#{rails_env}", once: true
    end
  end

  desc "Override default migrate task (by default requires a db roles which we don't have)"
  task :migrate, :roles => :app do
    run "cd #{latest_release} && bundle exec rake db:migrate RAILS_ENV=#{rails_env}", once: true
  end
  
end


namespace :god do
  desc "Stops all god processes" 
  task :stop do
    run "ps aux | grep god | grep -v grep | awk {'print $2'} | xargs -r kill -s QUIT"
  end
end


# ssh_options[:paranoid] = false
# set :deploy_via, :remote_cache

# role :web, "kokavo.com"                          # Your HTTP server, Apache/etc
# role :app, "kokavo.com"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
