# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

set :application, 'blog'
set :repo_url, 'git@github.com:waynels/blog.git'
set :user, 'www'
set :puma_threads, [2, 8]
set :puma_workers, 1

set :pty,             false
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}_#{fetch(:stage)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true # Change to true if using ActiveRecord

# set :sidekiq_config, 'config/sidekiq.yml'
set :init_system, :systemd

# DB tasks
set :db_local_clean, false
set :db_remote_clean, true
set :disallow_pushing, true
# set :assets_dependencies, %w(app/assets app/frontend lib/assets vendor/assets config/webpack)

## Linked Files & Directories (Default None):
append :linked_files, 'config/database.yml', 'config/master.key'

set :linked_dirs, %w[log tmp/pids tmp/cache tmp/async_import tmp/sockets public/system storage]

namespace :deploy do
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        warn "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        warn 'Sync changes before deploy.'
        exit
      end
    end
  end

  before :starting, :check_revision
end
