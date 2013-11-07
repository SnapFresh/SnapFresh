set :stages, %w[
                local
                development
                staging
                testing 
                production
                ci
              ]
set :default_stage, "local"

require 'capistrano/ext/multistage'
require 'highline/import'
require 'bundler/capistrano'
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :use_sudo, false
set :scm, "git"
set :git_enable_submodules, 1
set :git_shallow_clone, 1
set :scm_verbose, true
set :keep_releases, 1

set :default_shell, "/bin/bash"
set :application, "allincomefoods"
set :deploy_to, "/data/apps/allincomefoods"
set :deploy_via, :remote_cache

set :repository, "git@github.com:davidx/AllIncomeFoods.git"


set :branch, "master"


default_environment["PATH"] = %w[ /bin
                                  /sbin
                                  /usr/bin
                                  /usr/sbin
                                  /usr/local/bin
                                  /usr/local/sbin
                                 ].join(":")
role :app, "localhost"

namespace :deploy do
  task :restart do 
    # passenger
    run "touch tmp/restart.txt"
   # or 
   # sudo "/etc/init.d/apache2 restart"
  end
end
